//
//  User.swift
//  App
//
//  Created by Harley-xk on 2020/1/29.
//

import Fluent
import Vapor

final class User: ModelUser, Content {
    
    static let schema = "Users"
    
    enum Role: String, Codable, CaseIterable {
        case master
        case admin
        case normal
        case tourist
    }
    
    struct Contact: Codable {
        var phone: String?
        var wechat: String?
        var twitter: String?
    }
    
    @ID(key: "id")
    var id: Int?
    
    @Field(key: "email")
    var email: String
    
    @Field(key: "password")
    var password: String

    @Field(key: "nickname")
    var nickname: String
    
    @Field(key: "contact")
    var contact: Contact?
    
    @Field(key: "roles")
    var roles: [Role]
        
    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?

    @Timestamp(key: "deleted_at", on: .delete)
    var deletedAt: Date?
    
    static var usernameKey: KeyPath<User, Field<String>> {
        return \.$email
    }
    
    static var passwordHashKey: KeyPath<User, Field<String>> {
        return \.$password
    }
    
    func verify(password: String) throws -> Bool {
        return try Bcrypt.verify(password, created: self.password)
    }
}

