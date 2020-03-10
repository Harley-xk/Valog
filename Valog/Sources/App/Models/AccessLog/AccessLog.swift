//
//  AccessLog.swift
//  App
//
//  Created by Harley-xk on 2020/3/10.
//

import Foundation
import Vapor
import Fluent

final class AccessLog: Model {
    
    static var schema = "AccessLog"
    
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
    
    init() {}
    
    init(request req: Request, response res: Result<Response, Error>) {
        ip = req.remoteIP ?? "Unknown"
        page = req.url.description
        request = req.description
        /// 获取日志的接口不记录返回的日志信息，否则会造成无限嵌套
        if !page.contains("api/admin/logs") {
            do {
                response = try res.get().description
            } catch {
                response = error.localizedDescription
            }
        } else {
            response = "<Object>"
        }
    }
}

