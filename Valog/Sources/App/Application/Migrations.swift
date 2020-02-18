//
//  Migrations.swift
//  App
//
//  Created by Harley-xk on 2020/1/29.
//

import Foundation
import Vapor
import Fluent

public func prepareMigrations(_ app: Application) throws {
        
    app.migrations.add(CreateTodo())
    app.migrations.add(CreateUser())
    app.migrations.add(CreateMaster())
    app.migrations.add(CreatePosts())
    
    try app.autoMigrate().wait()
}

