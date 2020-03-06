//
//  Token.swift
//  App
//
//  Created by Harley-xk on 2020/3/5.
//

import Foundation
import Vapor
import Fluent

final class Token: ModelUserToken {

    static let schema = "Token"
    
    typealias User = App.User
    
    @ID(key: "id")
    var id: Int?
    
    @Parent(key: "user_id")
    var user: User
    
    @Field(key: "value")
    var value: String
    
    @Field(key: "expire_at")
    var expireAt: Date
    
    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?
    
    static var valueKey: KeyPath<Token, Field<String>> {
        return \.$value
    }
    
    static var userKey: KeyPath<Token, Parent<User>> {
        return \.$user
    }
    
    var isValid: Bool {
        return expireAt > Date()
    }
    
    init(userId: User.IDValue, expireAt: Date? = nil) {
        self.$user.id = userId
        self.value = UUID().uuidString
        self.expireAt = expireAt ?? Date() + .month(1)
    }
    
    init() {}
    
    struct Public: Content {
        var value: String
        var expireAt: Date
    }
    
    func makePublic() -> Public {
        return Public(value: value, expireAt: expireAt)
    }
}
