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
        
        let passwordProtected = User.authenticator().middleware()
        routes.grouped(passwordProtected)
            .post("login", use: passwordLogin)
        routes.post("autoLogin", use: autoLogin)
        routes.post("signout", use: signOut)
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
}
