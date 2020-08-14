//
//  File.swift
//  
//
//  Created by Harley-xk on 2020/8/14.
//

import Foundation
import Vapor
import Fluent

/// 文章浏览记录
final class PostReadRecord: Model {

    static let schema = "PostReadRecord"
    
    @ID(custom: "id")
    var id: Int?
    
    /// 记录对应的文章
    @Parent(key: "post_id")
    var post: Post
    
    /// 阅读文章的用户
    @OptionalParent(key: "sender_id")
    var reader: User?
    
    /// 对应的访问日志
    @Parent(key: "access_log_id")
    var accessLog: AccessLog
    
    /// 阅读时间
    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?
    
    static func make(postId: String, logId: AccessLog.IDValue, userId: User.IDValue?) -> PostReadRecord {
        let record = PostReadRecord()
        record.$post.id = postId
        record.$accessLog.id = logId
        record.$reader.id = userId
        record.createdAt = Date()
        return record
    }
    
}
