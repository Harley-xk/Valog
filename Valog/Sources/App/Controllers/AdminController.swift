//
//  AdminController.swift
//  App
//
//  Created by Harley-xk on 2020/3/1.
//

import Fluent
import Foundation
import Vapor

struct LogContent: Content {
    var content: String
    var time: String = Date().string()
}

struct StandardLogQuery: Content {
    var from: Date
    var to: Date?
}

struct PostReadRecordQuery: Content {
    var from: Date?
    var to: Date?
    var post_id: String?
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
        let group = routes.grouped([Token.authenticator(), AdminGuradMiddleware()])
        group.get("logs", "application", use: getApplicationLogs)
        group.get("logs", "accesslog", use: getAccessLogs)
        group.get("logs", "standard", use: getStandardLogs)
        group.get("logs", "standard", ":year", ":date", use: getStandardLogsByDate)
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
        let type = try request.query.get(String.self, at: "type")
        let query = AccessLog.query(on: request.db)
        if type == "normal" {
            query.filter(\.$page, .contains(inverse: true, .prefix), "/api/admin")
        }
        return query.sort(\.$createdAt, .descending).paginate(for: request)
    }
    
    func getStandardLogsByDate(_ request: Request) throws -> String {
        guard let year = request.parameters.get("year"),
            let date = request.parameters.get("date") else {
            throw Abort(.badRequest)
        }
        return try readLogsBy(year: year, date: date)
    }
    
    func getStandardLogs(_ request: Request) throws -> String {
        var result = ""
        
        let query = try request.content.decode(StandardLogQuery.self)
        var date = query.from.withoutTime
        let end = (query.to ?? Date()).withoutTime
        while date <= end {
            try result.append(
                contentsOf: readLogsBy(
                    year: date.string(format: "yyyy"),
                    date: date.string(format: "MM-dd")
                )
            )
            date = date + .day(1)
        }
        return result
    }
    
    private func readLogsBy(year: String, date: String) throws -> String {
        let path = Application.shared.directory.logsDirectory + "Standard/\(year)/\(date).log"
        guard FileManager.default.fileExists(atPath: path) else {
            return ""
        }
        let content = try String(contentsOfFile: path)
        return content
    }
    
    // MARK - Post Read Records
    
    func queryPostReadRecords(_ request: Request) throws -> EventLoopFuture<Page<PostReadRecord>> {
        var params = try request.query.decode(PostReadRecordQuery.self)
        let from = params.from ?? Date().beginTime
        let to = params.to ?? Date().endTime
        guard from < to else {
            throw Abort(.badRequest, reason: "开始时间必须小于结束时间")
        }
        var query = PostReadRecord.query(on: request.db)
            .filter(\.createdAt <= to)
            .filter(\.createdAt >= from)
            .with(\.$post)
            .with(\.$reader).first()
        
        return query
        
    }
}
