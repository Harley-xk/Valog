//
//  AdminController.swift
//  App
//
//  Created by Harley-xk on 2020/3/1.
//

import Foundation
import Vapor

struct LogContent: Content {
    
    enum LogType: String, Codable {
        case application
    }
    
    var type = LogType.application
    var content: String
    var time: String = Date().string()
}

final class AdminController: RouteCollection {
    
    func boot(routes: RoutesBuilder) throws {
        routes.get("logs", use: getAppLogs)
    }
    
    func getAppLogs(_ request: Request) throws -> LogContent {
        var path = Path("/var/log/supervisor/valog.log")
        #if Xcode
        path = Path(request.application.directory.storageDirectory + "/log/valog.log")
        #endif
        var encoding: String.Encoding = .utf8
        let content = try String(contentsOf: path.url, usedEncoding: &encoding)
        request.logger.info("Read log file from: \(path.string), used encoding: \(encoding.description)")
        return LogContent(content: content)
    }
}
