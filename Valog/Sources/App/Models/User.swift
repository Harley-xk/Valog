//
//  User.swift
//  App
//
//  Created by Harley-xk on 2020/1/29.
//

import Fluent
import Vapor

final class User: ModelAuthenticatable {
    
    static let schema = "Users"
    
    enum Role: String, Codable, CaseIterable {
        case master
        case admin
        case normal
        case tourist
    }
    
    struct Contact: Codable {
        var email: String?
        var phone: String?
        var wechat: String?
        var twitter: String?
        var github: String?
    }
    
    @ID(custom: "id")
    var id: Int?
    
    @Field(key: "username")
    var username: String
        
    @Field(key: "password")
    var password: String

    @Field(key: "nickname")
    var nickname: String
    
    @Field(key: "avatar")
    var avatar: String?
    
    @Field(key: "contact")
    var contact: Contact?
    
    @Field(key: "roles")
    var roles: [Role]

    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?

    @Timestamp(key: "deleted_at", on: .delete)
    var deletedAt: Date?
    
    static var usernameKey: KeyPath<User, Field<String>> {
        return \.$username
    }
    
    static var passwordHashKey: KeyPath<User, Field<String>> {
        return \.$password
    }
    
    /// 初始化一个游客账号
    init() {
        username = UUID().uuidString
        password = ""
        nickname = username
        roles = [.tourist]
    }
    
    /// 指定昵称创建一个游客账号
    init(tourist name: String) {
        username = UUID().uuidString
        password = ""
        nickname = name
        roles = [.tourist]
    }
    
    /// 通过 email 新建账号
    init(email: String, pass: String) throws {
        username = email
        nickname = email.components(separatedBy: "@").first ?? email
        contact = Contact(email: email)
        password = try Bcrypt.hash(pass)
        roles = [.normal]
    }
    
    /// 通过 github 新建账号
    init(github: GithubUser.Response) {
        username = UUID().uuidString
        nickname = github.name ?? github.login
        contact = Contact(email: github.email, github: github.login)
        avatar = github.avatar_url
        password = ""
        roles = [.normal]
    }
    
    /// 验证密码
    func verify(password: String) throws -> Bool {
        return try Bcrypt.verify(password, created: self.password)
    }
    
    func generateToken() throws -> Token {
        try Token(userId: self.requireID())
    }
    
    func makePublic() -> Public {
        return Public(from: self)
    }
    
    /// 根据指定名称查询游客账户信息
    /// - Parameters:
    ///   - request: 请求数据
    ///   - name: 游客名称
    ///   - autoCreate: 如果不存在是否自动创建，默认 true
    /// - Throws: 不自动创建且指定用户不存在时，抛出 404 错误
    /// - Returns: 创建完毕的用户信息
    static func fetchTourist(on request: Request, for name: String, autoCreate: Bool = true) throws -> EventLoopFuture<User> {
        // 未登录用户，检查游客账户（不存在则创建）
        return User.query(on: request.db)
            .filter(\.$nickname == name).first().flatMapThrows({ (user) -> EventLoopFuture<User> in
                if let user = user {
                    return request.eventLoop.future(user)
                } else if autoCreate {
                    // 游客用户不存在，创建一个
                    let tourist = User(tourist: name)
                    return tourist.create(on: request.db).transform(to: tourist)
                } else {
                    throw Abort(.badRequest)
                }
            })
    }
}

extension User: ResponseEncodable {
    
    func encodeResponse(for request: Request) -> EventLoopFuture<Response> {
        let response = Response()
        do {
            let publicUser = Public(from: self)
            try response.content.encode(publicUser)
        } catch {
            return request.eventLoop.makeFailedFuture(error)
        }
        return request.eventLoop.makeSucceededFuture(response)
    }
    
    struct Public: Content {
        var nickname: String
        var avatar: String?
        var roles: [Role]
        var contact: Contact?
        
        init(from model: User) {
            nickname = model.nickname
            avatar = model.avatar
            roles = model.roles
        }
    }
}
