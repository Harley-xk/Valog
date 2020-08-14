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
        
    app.migrations.add(CreateUser())
    app.migrations.add(CreateMaster())
    app.migrations.add(CreatePosts())
    app.migrations.add(CreateToken())
    app.migrations.add(CreateAccessLog())
    
    app.migrations.add(Post_Add_Sections())
    
    app.migrations.add(CreatePostComment())
    app.migrations.add(Extra_AccessLog())
    app.migrations.add(CreateGithubUser())
    app.migrations.add(User_Add_Avatar_Migration())
    app.migrations.add(Create_Post_Read_Record())
    try app.autoMigrate().wait()
}

