//
//  PostCommentsController.swift
//  App
//
//  Created by Harley-xk on 2020/3/17.
//

import Foundation
import Vapor
import Fluent
import SwiftSMTP

struct PostCommentCreatingBody: Content {
    
    var content: String
    var replyTo: Int?
    
    /// 如果是游客评论，该字段必填
    var sender: String?
}

final class PostCommentsController: RouteCollection {
    
    func boot(routes: RoutesBuilder) throws {
        routes.get("posts", ":id", "comments", use: index)
        
        routes.grouped(Token.authenticator())
            .post("posts", ":id", "comments", use: create)
    }
    
    func index(_ request: Request) throws -> EventLoopFuture<Page<PostComment.Public>> {
        guard let postId = request.parameters.get("id") else {
            throw Abort(.badRequest)
        }
        return PostComment.query(on: request.db)
            .with(\.$post)
            .with(\.$sender)
            .with(\.$taregtUser)
            .filter(\.$post.$id == postId)
            .sort(\.$createdAt, .descending)
            .paginate(for: request).map { (page) -> (Page<PostComment.Public>) in
                return page.map { $0.makePublic() }
        }
    }
    
    func create(_ request: Request) throws -> EventLoopFuture<PostComment.Public> {
        guard let postId = request.parameters.get("id") else {
            throw Abort(.badRequest, reason: "没有指定文章")
        }
        // 确保文章存在
        return Post.find(postId, on: request.db)
            .unwrap(or: Abort(.notFound, reason: "文章不存在"))
            .flatMapThrows { post in
                let body = try request.content.decode(PostCommentCreatingBody.self)
                if let user = request.auth.get(User.self) {
                    // 已登录用户，直接创建评论
                    return try self.createComment(on: request, for: post, with: body, sender: user)
                } else if let sender = body.sender {
                    return try User.fetchTourist(on: request, for: sender)
                        .flatMapThrows { user in
                            return try self.createComment(on: request, for: post, with: body, sender: user)
                    }
                } else {
                    throw Abort(.badRequest)
                }
        }
    }
    
    private func createComment(
        on request: Request,
        for post: Post,
        with body: PostCommentCreatingBody,
        sender: User
    ) throws -> EventLoopFuture<PostComment.Public> {
        // 文章评论数 + 1
        post.comments += 1
        if let replyTo = body.replyTo {
            return PostComment.query(on: request.db)
                .with(\.$sender)
                .filter(\.$id == replyTo)
                .first()
                .unwrap(or: Abort(.notFound))
                .flatMapThrows { (replied) -> EventLoopFuture<PostComment> in
                    if replied.sessionId == nil {
                        replied.sessionId = replyTo
                        return replied.update(on: request.db).transform(to: replied)
                    }
                    return request.eventLoop.future(replied)
            }.flatMap { (replied) -> EventLoopFuture<PostComment.Public> in
                let comment = PostComment(postId: post.id!, content: body.content, sender: sender, replyTo: replied)
                self.sendNotificationMail(for: comment, from: sender, on: post, replyTo: replied)
                return comment.create(on: request.db).flatMapThrows {
                    post.update(on: request.db)
                }.transform(to: comment.loadEagerAndMakePublic(on: request))
            }
        } else {
            let comment = PostComment(postId: post.id!, content: body.content, sender: sender, replyTo: nil)
            sendNotificationMail(for: comment, from: sender, on: post, replyTo: nil)
            return comment.create(on: request.db).flatMapThrows {
                post.update(on: request.db)
            }.transform(to: comment.loadEagerAndMakePublic(on: request))
        }
    }
    
    private func sendNotificationMail(for comment: PostComment, from sender: User, on post: Post, replyTo: PostComment?) {
        // 给我发通知
        let config = Application.shared.config.smtp
        let owner = Mail.User(name: config.senderName, email: config.senderAccount)
        var mail = Mail(from: owner, to: [owner])
        var content = ""
        if let replyTo = replyTo {
            mail.subject = "[Harley-xk.studio] \(sender.nickname) 回复了评论"
            content = "<p>\(sender.nickname)在文章<a href=\"https://me.harley-xk.studio/posts/\(post.id!)\">《\(post.title)》</a>回复了 \(replyTo.sender.nickname)：\(comment.content)</p>"
            if let email = replyTo.sender.contact?.email {
                let replyToUser = Mail.User(name: replyTo.sender.nickname, email: email)
                mail.to = [replyToUser]
                mail.cc = [owner]
            }
        } else {
            mail.subject = "[Harley-xk.studio] \(sender.nickname) 发表了评论"
            content = "<p>\(sender.nickname)在文章<a href=\"https://me.harley-xk.studio/posts/\(post.id!)\">《\(post.title)》</a>发表了评论：\(comment.content)</p>"
        }
        mail.alternative = Attachment(htmlContent: content)
        sendMail(mail)
    }
    
    private func sendMail(_ mail: Mail) {
        let config = Application.shared.config.smtp
        let service = SMTP(
            hostname: config.host,
            email: config.senderAccount,
            password: config.password
        )
        Application.shared.logger.info(
            """
            [发送邮件 \(mail.uuid)][from: \(mail.from.email)][to: \(mail.to.first?.name ?? "<null>")][cc: \(mail.cc.first?.name ?? "无")] \(mail.text)
            """
        )
        service.send(mail) { (error) in
            if let error = error {
                Application.shared.logger.error("[发送邮件 \(mail.uuid)] 失败：\(error.localizedDescription)")
            } else {
                Application.shared.logger.info("[发送邮件 \(mail.uuid)] 成功！")
            }
        }
    }
}
