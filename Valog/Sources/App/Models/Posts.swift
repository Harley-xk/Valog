//
//  Posts.swift
//  App
//
//  Created by Harley-xk on 2020/2/17.
//

import Foundation
import Vapor
import Fluent

/// 文章信息表
final class Post: Model {
    
    static var schema = "Posts"
    
    @ID(key: "id")
    var id: String?
    
    @Field(key: "title")
    var title: String
    
    @Field(key: "date")
    var date: String
    
    @Field(key: "intro")
    var intro: String?
    
    @Field(key: "tags")
    var tags: [String]?

    @Field(key: "categories")
    var categories: [String]?
    
    /// 阅读量
    @Field(key: "views")
    var views: Int
    
    /// 评论数
    @Field(key: "comments")
    var comments: Int
    
    /// 点赞数
    @Field(key: "likes")
    var likes: Int
    
    /// 文件路径
    @Field(key: "file-path")
    var filePath: String
    
    required init() {}
    
    struct Public: Content {
        var id: String?
        var title: String
        var date: String
        var intro: String?
        var tags: [String]?
        var categories: [String]?
        var views: Int
        var comments: Int
        var likes: Int
    }
    
    struct Details: Content {
        var meta: Post.Public
        var content: String
    }
    
    func makePublic() -> Public {
        Public(
            id: id,
            title: title,
            date: date,
            intro: intro,
            tags: tags,
            categories: categories,
            views: views,
            comments: comments,
            likes: likes
        )
    }
    
    func update(from info: PostInfo) {
        title = info.title
        date = info.date
        intro = info.intro
        tags = info.tags
        categories = info.categories
    }
}
 
struct PostInfo: Codable {

    var title: String
    
    var date: String
    
    var intro: String?
    
    var tags: [String]?
    
    var categories: [String]?
    
    var filePath: String!
    
    func makeModel() -> Post {
        let p = Post()
        p.id = date.removingOccurrences(["-", ":", " "])
        p.title = title
        p.date = date
        p.intro = intro
        p.tags = tags
        p.categories = categories
        p.filePath = filePath
        p.views = 0
        p.comments = 0
        p.likes = 0
        return p
    }
}

fileprivate extension String {
    func removingOccurrences(_ list: [String]) -> String {
        return list.reduce(self) { (result, s) -> String in
            return result.replacingOccurrences(of: s, with: "")
        }
    }
}
