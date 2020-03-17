//
//  PostComment.swift
//  App
//
//  Created by Harley-xk on 2020/3/17.
//

import Foundation
import Vapor
import Fluent

/**
 文章评论
 */

final class PostComment: Model {
    
    static var schema = "PostComments"
    
    /// id，自动生成
    @ID(key: "id")
    var id: Int?
    
    /// 评论所属文章
    @Parent(key: "post_id")
    var post: Post
    
    /// 评论内容，支持 markdwon 标签
    @Field(key: "content")
    var content: String
    
    /// 评论发送人
    @Parent(key: "sender_id")
    var sender: User
    
    /// 评论时间
    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?
    
    /// 评论目标，如果是回复别的评论，该字段有值
    @OptionalParent(key: "reply_to")
    var replyTo: PostComment?
    
    /// 目标用户，目标评论的发布者
    @OptionalParent(key: "target_user_id")
    var taregtUser: User?
    
    /// 会话 id，用来查询同一个链条上的评论
    /// 当第一个回复创建时，会将他和 Target 的 SessionId 都设置成 target 的 id
    /// 后续所有回复到同一个 SessionId 的评论都共享该 SessionId
    @Field(key: "session_id")
    var sessionId: Int?

    /// 所有回复这条评论的评论
    @Children(for: \.$replyTo)
    var replies: [PostComment]
    
    required init() {}
    
    init(postId: String,
         content: String,
         sender: User,
         replyTo: PostComment?
    ) {
        self.$post.id = postId
        self.content = content
        self.$sender.id = sender.id!
        if let replyTo = replyTo {
            self.$replyTo.id = replyTo.id
            self.$taregtUser.id = replyTo.$sender.id
            self.sessionId = replyTo.sessionId
        } else {
            self.$replyTo.id = nil
            self.$taregtUser.id = nil
            self.sessionId = nil
        }
    }
}

extension PostComment: Content {}

extension PostComment {
    
    struct Public: Content {
        var id: Int?
        var postId: String?
        var content: String
        var sender: User.Public
        var createdAt: Date?
        var replyTo: Int?
        var targetUser: User.Public?
        var sessionId: Int?
    }
    
    func makePublic() -> Public {
        Public(
            id: self.id,
            postId: self.$post.id,
            content: self.content,
            sender: self.sender.makePublic(),
            createdAt: self.createdAt,
            replyTo: self.$replyTo.id,
            targetUser: self.taregtUser?.makePublic(),
            sessionId: self.sessionId
        )
    }
    
    func loadEagerAndMakePublic(on request: Request) -> EventLoopFuture<Public> {
        return [
            $sender.load(on: request.db),
            $taregtUser.load(on: request.db),
            ]
            .flatten(on: request.eventLoop)
            .map { self.makePublic() }
    }
}
