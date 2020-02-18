//
//  CreatePosts.swift
//  App
//
//  Created by Harley-xk on 2020/2/17.
//

import Foundation
import Fluent

struct CreatePosts: Migration {
    func revert(on database: Database) -> EventLoopFuture<Void> {
        return database.schema(Post.schema).delete()
    }
    
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        return database.schema(Post.schema)
            .field("id", .string, .identifier(auto: false))
            .field("title", .string, .required)
            .field("date", .string, .required)
            .field("intro", .string)
            .field("tags", .array(of: .string))
            .field("categories", .array(of: .string))
            .field("views", .int, .required)
            .field("comments", .int, .required)
            .field("likes", .int, .required)
            .field("file-path", .string, .required)
            .create()
    }
}
