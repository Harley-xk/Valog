//
//  UserController.swift
//  App
//
//  Created by Harley-xk on 2020/3/4.
//

import Foundation
import Vapor
import Fluent

struct LoginResponse: Content {
    var user: User.Public
    var token: Token.Public
}

final class UserController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        
        let passwordProtected = User.authenticator()
        routes.grouped(passwordProtected)
            .post("login", use: passwordLogin)
        routes.post("autoLogin", use: autoLogin)
        routes.post("signout", use: signOut)
        routes.post("githubLogin", use: githubLogin)
    }
    
    func passwordLogin(_ request: Request) throws -> EventLoopFuture<LoginResponse> {
        let user = try request.auth.require(User.self)
        let token = try user.generateToken()
        return token.save(on: request.db).map {
            return LoginResponse(user: user.makePublic(), token: token.makePublic())
        }
    }
    
    func autoLogin(_ request: Request) throws -> EventLoopFuture<LoginResponse> {
        guard let bearer = request.headers.bearerAuthorization else {
            throw Abort(.unauthorized)
        }
        return Token.query(on: request.db).filter(\.$value == bearer.token).first().flatMapThrows { (token) -> EventLoopFuture<LoginResponse> in
            guard let t = token, t.isValid else {
                throw Abort(.unauthorized)
            }
            return t.$user.get(on: request.db).map { user in
                return LoginResponse(user: user.makePublic(), token: t.makePublic())
            }
        }
    }
    
    func signOut(_ request: Request) throws -> EventLoopFuture<HTTPStatus> {
        guard let bearer = request.headers.bearerAuthorization else {
            throw Abort(.unauthorized)
        }
        return Token.query(on: request.db).filter(\.$value == bearer.token).first().flatMapThrows { (token) -> EventLoopFuture<HTTPStatus> in
            guard let t = token, t.isValid else {
                throw Abort(.unauthorized)
            }
            return t.delete(on: request.db).transform(to: .noContent)
        }
    }
    
    // MARK: - Github
    func githubLogin(_ request: Request) throws -> EventLoopFuture<LoginResponse> {
        let githubController = GithubController()
        return try githubController.checkCode(request)
            .flatMapThrows { (u) -> EventLoopFuture<User> in
                // 查询用户是否存在
                GithubUser.query(on: request.db).with(\.$user).filter(\.$login == u.login)
                    .first().flatMapThrows { (gUser) -> EventLoopFuture<User> in
                        guard let gUser = gUser else {
                            // 用户不存在，创建
                            return try self.createUser(with: u, on: request.db)
                        }
                        return request.eventLoop.future(gUser.user)
                    }
            }.flatMapThrows({ (user) -> EventLoopFuture<LoginResponse> in
                let token = try user.generateToken()
                return token.save(on: request.db).map {
                    return LoginResponse(user: user.makePublic(), token: token.makePublic())
                }
            })
    }
    
    func createUser(with github: GithubUser.Response, on database: Database) throws -> EventLoopFuture<User> {
        let user = User(github: github)
        return user.save(on: database).flatMapThrows({ () -> EventLoopFuture<Void> in
            return GithubUser(from: github, user_id: user.id!).save(on: database)
        }).transform(to: user)
    }
}
