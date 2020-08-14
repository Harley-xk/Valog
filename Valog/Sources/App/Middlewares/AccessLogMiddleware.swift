//
//  AccessLogMiddleware.swift
//  App
//
//  Created by Harley-xk on 2020/3/10.
//

import Foundation
import Vapor

final class AccessLogMiddleware: Middleware {
    
    func respond(to request: Request, chainingTo next: Responder) -> EventLoopFuture<Response> {
        return next.respond(to: request).always { (result) in
            self.saveLog(from: request, result: result)
        }
    }
    
    private func saveLog(from request: Request, result: Result<Response, Error>) {
        let log = AccessLog(request: request, response: result)
        _ = queryGeoLocation(for: request).flatMap { (location) -> EventLoopFuture<Void> in
            log.geoLocation = location
            return log.save(on: request.db).flatMap {
                guard request.route?.tag == .read_post,
                      let post_id = request.parameters.get("id"),
                      let log_id = try? log.requireID()
                else {
                    return request.eventLoop.future()
                }
                let record = PostReadRecord.make(
                    postId: post_id,
                    logId: log_id,
                    userId: nil
                )
                // 记录文章阅读日志
                return record.save(on: request.db)
            }
        }
    }
    
    private func queryGeoLocation(for request: Request) -> EventLoopFuture<GeoLocation?> {
        guard let address = request.remoteIP else {
            return request.eventLoop.future(nil)
        }
        return request.client.get(.init(string: "http://ip-api.com/json/\(address)?lang=zh-CN")).map({ (resp) -> GeoLocation? in
            return try? resp.content.decode(GeoLocation.self)
        }).flatMapErrorThrowing { (error) -> GeoLocation? in
            return nil
        }
    }
}

extension Request {
    
    var remoteIP: String? {
        if Application.shared.environment == .development {
            let random = { return Int.random(in: 1 ... 100) }
            return "\(random()).\(random()).\(random()).\(random())"
        } else {
            // 服务器通过 Caddy 转发，实际 IP 在这个字段（需要在 caddy 配置文件指定）
            return headers.first(name: "X-Real-Ip") ?? "Unknown"
        }
    }
}
