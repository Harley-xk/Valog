//
//  File.swift
//  
//
//  Created by Harley-xk on 2020/7/13.
//

import Foundation
import Vapor
import Fluent

final class User_Add_Avatar_Migration: Migration {
    
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        database.schema(User.schema)
            .field("avatar", .string)
            .update()
    }
    
    func revert(on database: Database) -> EventLoopFuture<Void> {
        database.schema(User.schema)
            .deleteField("avatar")
            .update()
    }
}
