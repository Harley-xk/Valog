//
//  WebhookController.swift
//  App
//
//  Created by Harley-xk on 2020/2/16.
//

import Foundation
import Vapor
import CryptoSwift

class WebhooksController: RouteCollection {
    
    func boot(routes: RoutesBuilder) throws {
        routes.post("webhook", use: pushAction)
    }
    
    func pushAction(_ request: Request) throws -> EventLoopFuture<HTTPStatus> {
        
        /// 验证签名
//        try verifySignature(from: request)

        let action = try request.content.decode(PushAction.self)
        
        // 校验是否是合法的钩子
        if action.repository.full_name == "Harley-xk/Posts" {
//            action.ref == "refs/heads/master",
//            action.sender.name == "Harley-xk" {
            return try updatePostsAndReload(from: request).transform(to: HTTPStatus.ok)
        } else if action.repository.full_name == "Harley-xk/nuxt-pages" {
            try updateNuxtSitesAndDepoly(from: request)
            let path = Path(request.application.directory.storageDirectory + "Posts")
            try MarkdownFileManager.copyResources(from: path, toPublicOf: request.application)
            return request.eventLoop.future(.ok)
        } else {
            // 抛出 404 错误，假装没有这个接口
            throw Abort(.badRequest, reason: "Unsupported action!")
        }
    }
    
    private func verifySignature(from request: Request) throws {
        
        let webhook_token = request.application.config.hook.token
        
        guard let payload = request.body.string?.bytes,
            let hub_sign = request.headers.first(name: "X-Hub-Signature")
            else {
                throw Abort(.badRequest)
        }
        
        let sign = try CryptoSwift.HMAC(key: webhook_token.bytes, variant: .sha1)
            .authenticate(payload).toHexString()
        guard "sha1=\(sign)" == hub_sign else {
            throw Abort(.badRequest, reason: "Signature not match!")
        }
    }
    
    private func updatePostsAndReload(from request: Request) throws -> EventLoopFuture<[Post.Public]> {
        try SimpleShell.runSynchronously(
            cmd: "git pull",
            on: request.application.directory.workingDirectory + "Storage/Posts"
        )
        return try PostController().reloadPosts(request)
    }
    
    private func updateNuxtSitesAndDepoly(from request: Request) throws {
        let filename = "update-website-\(request.application.environment.name).sh"
        let scriptPath: String = request.application.directory.workingDirectory + filename
        request.logger.info("Running script: \(scriptPath)")
        try SimpleShell.run(cmd: "bash \(scriptPath)")
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
    
    var ref: String?
    var before: String?
    var after: String?
    
    var repository: Repository
    
    var pusher: Pusher?
    
    var sender: Repository.User
    
    var commits: [Commit]?
    
    var head_commit: Commit?
}
