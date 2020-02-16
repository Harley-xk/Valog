//
//  PostController.swift
//  App
//
//  Created by Harley-xk on 2020/2/13.
//

import Foundation
import Fluent
import Vapor
import CryptoSwift

final class PostController: RouteCollection {
    
    func boot(routes: RoutesBuilder) throws {
        routes.get("posts", use: allPosts)
    }
    
    func allPosts(_ request: Request) throws -> EventLoopFuture<[Post]> {
        return request.redis.get(Post.Keys.list, asJSON: [Post].self).flatMapThrows { (posts) -> EventLoopFuture<[Post]> in
            guard let list = posts else {
                let path = Path(request.application.directory.storageDirectory)
                let results = try self.findPosts(in: path)
                return request.redis.set(Post.Keys.list, toJSON: results).transform(to: results)
            }
            return request.application.eventLoopGroup.future(list)
        }
    }
    
    func findPosts(in directory: Path) throws -> [Post] {
        var posts: [Post] = []
        for path in try directory.children() {
            guard path.isDirectory else {
                continue
            }
            if path.extension == "post" {
                try posts.append(decodePost(from: path))
            } else {
                try posts.append(contentsOf: findPosts(in: path))
            }
        }
        return posts
    }
    
    func decodePost(from path: Path) throws -> Post {
        let dataFile = path + Path("content.json")
        let data = try Data(contentsOf: dataFile.url)
        return try Post.decode(from: data)
    }
    
}

final class Post: Content {
    
    static func decode(from data: Data) throws -> Post {
        let post = try JSONDecoder().decode(Post.self, from: data)
        post.id = post.date.md5()
        post.views = Int.random(in: 1 ... 20)
        post.comments = Int.random(in: 1 ... 20)
        return post
    }
    
    var id: String!
    
    var title: String
    
    var date: String
    
    var intro: String?
    
    var tags: [String]?
    
    var categories: [String]?
    
    var views: Int!
    
    var comments: Int!
}
