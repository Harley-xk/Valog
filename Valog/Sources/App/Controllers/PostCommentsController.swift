//
//  PostCommentsController.swift
//  App
//
//  Created by Harley-xk on 2020/3/17.
//

import Foundation
import Vapor
import Fluent

struct PostCommentCreatingBody: Content {
    
    var content: String
    var replyTo: Int?
    
    /// 如果是游客评论，该字段必填
    var sender: String?
}

final class PostCommentsController: RouteCollection {
    
    func boot(routes: RoutesBuilder) throws {
        routes.get("posts", ":id", "comments", use: index)
        routes.post("posts", ":id", "comments", use: create)
    }
    
    func index(_ request: Request) throws -> EventLoopFuture<Page<PostComment.Public>> {
        guard let postId = request.parameters.get("id") else {
            throw Abort(.badRequest)
        }
        return PostComment.query(on: request.db)
            .with(\.$post)
            .with(\.$sender)
            .with(\.$replyTo)
            .filter(\.$post.$id == postId)
            .sort(\.$createdAt, .ascending)
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
                    return try self.createComment(on: request, for: postId, with: body, sender: user)
                } else if let sender = body.sender {
                    return try User.fetchTourist(on: request, for: sender)
                        .flatMapThrows { user in
                            return try self.createComment(on: request, for: postId, with: body, sender: user)
                    }
                } else {
                    throw Abort(.badRequest)
                }
        }
    }
    
    private func createComment(
        on request: Request,
        for postId: String,
        with body: PostCommentCreatingBody,
        sender: User
    ) throws -> EventLoopFuture<PostComment.Public> {
        if let replyTo = body.replyTo {
            return PostComment.find(replyTo, on: request.db).unwrap(or: Abort(.notFound))
                .flatMapThrows { (replied) -> EventLoopFuture<PostComment> in
                    if replied.sessionId == nil {
                        replied.sessionId = replyTo
                        return replied.update(on: request.db).transform(to: replied)
                    }
                    return request.eventLoop.future(replied)
            }.flatMap { (replied) -> EventLoopFuture<PostComment.Public> in
                let comment = PostComment(postId: postId, content: body.content, sender: sender, replyTo: replied)
                return comment.create(on: request.db)
                    .transform(to: comment.loadEagerAndMakePublic(on: request))
            }
        } else {
            let comment = PostComment(postId: postId, content: body.content, sender: sender, replyTo: nil)
            return comment.create(on: request.db)
                .transform(to: comment.loadEagerAndMakePublic(on: request))
        }
    }
    
}
