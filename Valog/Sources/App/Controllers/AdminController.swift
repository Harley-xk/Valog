//
//  AdminController.swift
//  App
//
//  Created by Harley-xk on 2020/3/1.
//

import Foundation
import Vapor
import Fluent

struct LogContent: Content {
    
    var content: String
    var time: String = Date().string()
}

class AdminGuradMiddleware: Middleware {
    func respond(to request: Request, chainingTo next: Responder) -> EventLoopFuture<Response> {
        guard let user = try? request.auth.require(User.self), user.roles.contains(.admin) else {
            return request.eventLoop.future(Response(status: .forbidden))
        }
        return next.respond(to: request)
    }
}

final class AdminController: RouteCollection {
    
    func boot(routes: RoutesBuilder) throws {
        let group = routes.grouped([Token.authenticator().middleware(), AdminGuradMiddleware()])
        group.get("logs", "application", use: getApplicationLogs)
        group.get("logs", "accesslog", use: getAccessLogs)
    }
    
    func getApplicationLogs(_ request: Request) throws -> LogContent {
        var path = Path("/var/log/supervisor/valog.log")
        #if Xcode
        path = Path(request.application.directory.storageDirectory + "/log/valog.log")
        #endif
        var encoding: String.Encoding = .utf8
        let content = try String(contentsOf: path.url, usedEncoding: &encoding)
        request.logger.info("Read log file from: \(path.string), used encoding: \(encoding.description)")
        return LogContent(content: content)
    }
        
    func getAccessLogs(_ request: Request) throws -> EventLoopFuture<Page<AccessLog>> {
        return AccessLog.query(on: request.db).sort(\.$createdAt, .descending).paginate(for: request)
    }
}
