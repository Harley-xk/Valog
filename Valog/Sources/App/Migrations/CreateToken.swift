//
//  CreateToken.swift
//  App
//
//  Created by Harley-xk on 2020/3/5.
//

import Foundation
import Vapor
import Fluent

class CreateToken: Migration {
    
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        database.schema("Token")
            .field("id", .int, .identifier(auto: true))
            .field("user_id", .int, .required, .references("Users", "id"))
            .field("value", .string, .required)
            .field("expire_at", .datetime, .required)
            .field("created_at", .datetime)
            .create()
    }
    
    func revert(on database: Database) -> EventLoopFuture<Void> {
        database.schema("Token").delete()
    }
}
