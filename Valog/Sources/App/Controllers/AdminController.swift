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
    var time: Date = Date()
}

final class AdminController: RouteCollection {
    
    func boot(routes: RoutesBuilder) throws {
        routes.get("logs", use: getAppLogs)
    }
    
    func getAppLogs(_ request: Request) throws -> String {
        var path = Path("/var/log/supervisor/valog.log")
        #if Xcode
        path = Path(request.application.directory.storageDirectory + "/log/valog.log")
        #endif
        let content = try String(contentsOf: path.url)
        return content
//        return LogContent(content: content)
    }
}
