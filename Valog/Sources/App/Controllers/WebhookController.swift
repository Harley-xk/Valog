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
        // 只有主分支的变化才会触发自动部署
        guard action.ref == "refs/heads/master" else {
            return request.eventLoop.future(.notModified)
        }
        // 校验是否是合法的钩子
        if action.repository.full_name == "Harley-xk/Posts" {
//            action.sender.name == "Harley-xk" {
            return try updatePostsAndReload(from: request).transform(to: HTTPStatus.ok)
        } else if action.repository.full_name == "Harley-xk/nuxt-pages" {
            try updateNuxtSitesAndDepoly(from: request)
            return request.eventLoop.future(.ok)
        } else if action.repository.full_name == "Harley-xk/Valog" {
            try rebuildServerAndDepoly(from: request)
            return request.eventLoop.future(.ok)
        } else {
            // 抛出 404 错误，假装没有这个接口
            throw Abort(.badRequest)
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
        request.logger.warning("Running script: \(scriptPath)")
        try SimpleShell.run(cmd: "zsh \(scriptPath)") { _ in
            /// 网站生成完毕后尝试重新拷贝公共资源到网站根目录
            let path = Path(request.application.directory.storageDirectory + "Posts")
            do {
                try MarkdownFileManager.copyResources(from: path, toPublicOf: request.application)
            } catch {
                request.application.logger.error("\(error.localizedDescription)")
            }
        }
    }
    
    private func rebuildServerAndDepoly(from request: Request) throws {
        let scriptPath: String = request.application.directory.workingDirectory + "redepoly.sh"
        request.logger.warning("Running script: \(scriptPath)")
        try SimpleShell.run(cmd: "zsh \(scriptPath)")
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
