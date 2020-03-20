//
//  202003200842_Extra_AccessLog.swift
//  App
//
//  Created by Harley-xk on 2020/3/20.
//

import Foundation
import Vapor
import Fluent

final class Extra_AccessLog: Migration {
    
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        database.schema(AccessLog.schema).delete().flatMap {
            database.schema(AccessLog.schema)
                .field("id", .int, .identifier(auto: true))
                .field("ip", .string)
                .field("geo", .json)
                .field("createdAt", .datetime)
                .field("page", .string)
                .field("request", .json)
                .field("response", .json)
            .create()
        }
    }
    
    func revert(on database: Database) -> EventLoopFuture<Void> {
        database.schema(AccessLog.schema).delete().flatMap {
            database.schema(AccessLog.schema)
                .field("id", .int, .identifier(auto: true))
                .field("ip", .string)
                .field("geo", .json)
                .field("createdAt", .datetime)
                .field("page", .string)
                .field("request", .string)
                .field("response", .string)
            .create()
        }
    }
}
