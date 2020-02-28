//
//  CreateUser.swift
//  App
//
//  Created by Harley-xk on 2020/1/29.
//

import Vapor
import Fluent

struct CreateUser: Migration {
    func revert(on database: Database) -> EventLoopFuture<Void> {
        return database.schema(User.schema).delete()
    }
    
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        return database.schema(User.schema)
            .field("id", .int, .identifier(auto: true))
            .field("username", .string, .required)
            .field("password", .string, .required)
            .field("nickname", .string, .required)
            .field("contact", .json)
            .field("roles", .array(of: .string), .required)
            .field("created_at", .datetime)
            .field("deleted_at", .datetime)
            .unique(on: "username")
            .create()
    }
}

struct CreateMaster: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        let password = UUID().uuidString
        let master = try! User(email: "harley.gb@foxmail.com", pass: password)
        master.nickname = "Harley-xk"
        master.contact?.phone = "17625809396"
        master.contact?.wechat = "wx_8772836"
        master.roles = User.Role.allCases
        return master.create(on: database).map { _ in
            Logger.timed(label: "Valog").info(
                """
                ==> master created
                -----------> username: \(master.username)
                -----------> password: \(password)
                -----------
                """
            )
        }
    }
    
    func revert(on database: Database) -> EventLoopFuture<Void> {
        return User.query(on: database).filter(\.$username == "harley.gb@foxmail.com").delete()
    }
}
