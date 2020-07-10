//
//  File.swift
//  
//
//  Created by Harley-xk on 2020/7/9.
//

import Foundation
import Fluent

final class CreateGithubUser: Migration {
    
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        database.schema(GithubUser.schema)
            .field("id", .int, .identifier(auto: true))
            .field("user_id", .int, .required)
            .field("login", .string, .required)
            .field("name", .string, .required)
            .field("email", .string, .required)
            .field("avatar_url", .string)
            .field("url", .string)
            .create()
    }
    
    func revert(on database: Database) -> EventLoopFuture<Void> {
        database.schema(AccessLog.schema).delete()
    }
}
