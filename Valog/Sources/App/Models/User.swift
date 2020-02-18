//
//  User.swift
//  App
//
//  Created by Harley-xk on 2020/1/29.
//

import Fluent
import Vapor

final class User: ModelUser {
    
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
    }
    
    @ID(key: "id")
    var id: Int?
    
    @Field(key: "username")
    var username: String
        
    @Field(key: "password")
    var password: String

    @Field(key: "nickname")
    var nickname: String
    
    @Field(key: "contact")
    var contact: Contact?
    
    @Field(key: "roles")
    private var _roles: [String]
    
    var roles: [Role] {
        get {
            return _roles.compactMap { Role(rawValue: $0) }
        }
        set {
            _roles = newValue.compactMap { $0.rawValue }
        }
    }
        
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
    
    /// 通过 email 新建账号
    init(email: String, pass: String) throws {
        username = email
        nickname = email.components(separatedBy: "@").first ?? email
        contact = Contact(email: email)
        password = try Bcrypt.hash(pass)
        roles = [.normal]
    }
    
    /// 验证密码
    func verify(password: String) throws -> Bool {
        return try Bcrypt.verify(password, created: self.password)
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
        var roles: [Role]
        
        init(from model: User) {
            nickname = model.nickname
            roles = model.roles
        }
    }
}
