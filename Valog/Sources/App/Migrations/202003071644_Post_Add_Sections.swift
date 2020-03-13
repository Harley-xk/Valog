//
//  202003071644_Post_Add_Sections.swift
//  App
//
//  Created by Harley-xk on 2020/3/7.
//

import Foundation
import Vapor
import Fluent

final class Post_Add_Sections: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        database.schema(Post.schema)
            .field("sections", .array(of: .json))
            .update()
    }
    
    func revert(on database: Database) -> EventLoopFuture<Void> {
        database.schema(Post.schema).deleteField("sections").update()
    }
    
    
}
