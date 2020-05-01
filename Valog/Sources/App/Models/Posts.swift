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
    
    @ID(custom: "id")
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
    
    @Field(key: "sections")
    var sections: [Section]
    
    required init() {}
    
    struct Public: Content {
        var id: String?
        var title: String
        var date: String
        var intro: String?
        var tags: [String]?
        var categories: [String]?
        var sections: [Section]
        var views: Int
        var comments: Int
        var likes: Int
    }
    
    struct Details: Content {
        var meta: Post.Public
        var content: String
    }
    
    struct Section: Content {
        var title: String
        var level: Int
        var children: [Section]?
    }
    
    func makePublic() -> Public {
        Public(
            id: id,
            title: title,
            date: date,
            intro: intro,
            tags: tags,
            categories: categories,
            sections: sections,
            views: views,
            comments: comments,
            likes: likes
        )
    }
    
    func update(from info: MarkdownFile) {
        title = info.frontMatter.title
        date = info.frontMatter.date
        intro = info.frontMatter.abstract
        tags = info.frontMatter.tags
        categories = info.frontMatter.categories
        sections = info.sections
        filePath = info.relativePath
    }
}
