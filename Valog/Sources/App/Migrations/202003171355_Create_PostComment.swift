//
//  202003171355_Create_PostComment.swift
//  App
//
//  Created by Harley-xk on 2020/3/17.
//

import Foundation
import Vapor
import Fluent

final class CreatePostComment: Migration {
    
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        database.schema(PostComment.schema)
            .field("id", .int, .identifier(auto: true))
            .field("post_id", .string, .required)
            .field("content", .string, .required)
            .field("sender_id", .int, .required)
            .field("created_at", .datetime)
            .field("reply_to", .int)
            .field("target_user_id", .int)
            .field("session_id", .int)
            .create()
    }
    
    func revert(on database: Database) -> EventLoopFuture<Void> {
        database.schema(PostComment.schema).delete()
    }
}

/*

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
 
 /// 会话 id，用来查询同一个链条上的评论
 /// 当第一个回复创建时，会将他和 Target 的 SessionId 都设置成 target 的 id
 /// 后续所有回复到同一个 SessionId 的评论都共享该 SessionId
 @Field(key: "session_id")
 var sessionId: Int
*/
