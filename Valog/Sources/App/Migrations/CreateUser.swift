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
            .field("email", .string, .required)
            .field("password", .string, .required)
            .field("nickname", .string, .required)
            .field("contact", .json)
            .field("roles", .array(of: .string), .required)
            .field("created_at", .datetime)
            .field("deleted_at", .datetime)
            .unique(on: "email")
            .create()
    }
}

struct CreateMaster: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        let master = User()
        master.email = "harley.gb@foxmail.com"
        let password = UUID().uuidString
        master.password = try! Bcrypt.hash(password)
        master.nickname = "Harley"
        master.contact = User.Contact(phone: "17625809396", wechat: "wx_8772836", twitter: nil)
        master.roles = User.Role.allCases
        return master.create(on: database).map { _ in 
            Logger(label: "Valog").info(
                """
                ==> master created
                -----------> email: \(master.email)
                -----------> password: \(password)
                -----------
                """
            )
        }
    }
    
    func revert(on database: Database) -> EventLoopFuture<Void> {
        return User.query(on: database).filter(\.$email == "harley.gb@foxmail.com").delete()
    }
}
