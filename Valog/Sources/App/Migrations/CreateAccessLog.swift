//
//  CreateAccessLog.swift
//  App
//
//  Created by Harley-xk on 2020/3/10.
//

import Foundation
import Fluent

final class CreateAccessLog: Migration {
    
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        database.schema(AccessLog.schema)
            .field("id", .int, .identifier(auto: true))
            .field("ip", .string)
            .field("geo", .json)
            .field("createdAt", .datetime)
            .field("page", .string)
            .field("request",.string)
            .field("response", .string)
        .create()
    }
    
    func revert(on database: Database) -> EventLoopFuture<Void> {
        database.schema(AccessLog.schema).delete()
    }
}

/*
 @ID(key: "id")
 var id: Int?
 
 // 访问者的 ip 地址
 @Field(key: "ip")
 var ip: String?
 
 // ip 对应的物理地址
 @Field(key: "geo")
 var geoLocation: GeoLocation?
 
 // 访问时间
 @Timestamp(key: "createdAt", on: .create)
 var createdAt: Date?
 
 // 访问的页面
 @Field(key: "page")
 var page: String
 
 // http 请求的内容
 @Field(key: "request")
 var request: String
 
 // http 请求的内容
 @Field(key: "response")
 var response: String
 */
