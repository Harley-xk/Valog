//
//  WebhookController.swift
//  App
//
//  Created by Harley-xk on 2020/2/16.
//

import Foundation
import Vapor

class WebhooksController: RouteCollection {
    
    func boot(routes: RoutesBuilder) throws {
        routes.post("webhook", use: pushAction)
    }
    
    func pushAction(_ request: Request) throws -> HTTPStatus {
        
        let action = try request.content.decode(PushAction.self)
        
//        print("== Headers ==")
//        request.headers.forEach { (name, value) in
//            print("\(name) : \(value)")
//        }
//        print("== Body ==")
//        print(request.body.string ?? "<empty body>")
        
        // 校验是否是合法的钩子
        guard action.repository.full_name == "Harley-xk/Posts",
            action.pusher.name == "Harley-xk",
            action.ref == "refs/heads/master"
            else {
                // 抛出 404 错误，假装没有这个接口
                throw Abort(.notFound)
        }
        
        try SimpleShell.runSynchronously(
            //            cmd: "git clone https://github.com/Harley-xk/MySite.git --branch=gh-pages",
            cmd: "git pull",
            on: request.application.directory.workingDirectory + "Storage/Posts"
        )
        
        _ = try PostController().cachePosts(request)
        
        return .ok
    }
    
}

struct PushAction: Content {
    
    struct Repository: Content {
        
        struct User: Content {
            var id: Int?
            var name: String?
            var email: String?
            var avatar_url: String?
            var html_url: String?
            var username: String?
        }
        
        var id: Int
        var node_id: String
        var name: String
        var full_name: String
        var owner: User
        var url: String
        var description: String
    }
    
    struct Pusher: Content {
        var name: String
        var email: String
    }
    
    struct Commit: Content {
        var id: String
        var tree_id: String
        var message: String
        var timestamp: String
        var author: Repository.User
        var committer: Repository.User
        var added: [String]
        var removed: [String]
        var modified: [String]
    }
    
    var ref: String
    var before: String
    var after: String
    
    var repository: Repository
    
    var pusher: Pusher
    
    var sender: Repository.User
    
    var commits: [Commit]
    
    var head_commit: Commit
}
