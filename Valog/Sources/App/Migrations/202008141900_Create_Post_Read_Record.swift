//
//  File.swift
//  
//
//  Created by Harley-xk on 2020/8/14.
//

import Foundation
import Vapor
import Fluent

final class Create_Post_Read_Record: Migration {
    
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        database.schema(PostReadRecord.schema)
            .field("id", .int, .identifier(auto: true))
            .field("post_id", .string, .required)
            .field("sender_id", .int)
            .field("access_log_id", .int, .required)
            .field("created_at", .datetime, .required)
            .create()
    }
    
    func revert(on database: Database) -> EventLoopFuture<Void> {
        database.schema(PostReadRecord.schema).delete()
    }
}


//@Parent(key: "post_id")
//var post: Post
//@OptionalParent(key: "sender_id")
//var reader: User?
//@Parent(key: "access_log_id")
//var accessLog: AccessLog
//@Timestamp(key: "created_at", on: .create)
//var createdAt: Date?
