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
    
    func allPosts(_ request: Request) throws -> EventLoopFuture<[Post.Public]> {
        return Post.query(on: request.db).all().mapEachCompact { $0.makePublic() }
    }
    
    func reloadPosts(_ request: Request) throws -> EventLoopFuture<[Post.Public]> {
        let path = Path(request.application.directory.storageDirectory)
        let results = try self.findPosts(in: path)
        return results.compactMap { info in
            return Post.query(on: request.db).filter(\.$date == info.date).first().flatMapThrows { (post) -> EventLoopFuture<Post.Public> in
                guard let post = post else {
                    let model = info.makeModel()
                    return model.create(on: request.db).transform(to: model.makePublic())
                }
                post.update(from: info)
                return post.update(on: request.db).transform(to: post.makePublic())
            }
        }.flatten(on: request.eventLoop)
    }
    
    func findPosts(in directory: Path) throws -> [PostInfo] {
        var posts: [PostInfo] = []
        for path in try directory.children() {
            guard path.isDirectory else {
                continue
            }
            if path.extension == "post" {
                let dataFile = path + Path("content.json")
                var info = try PostInfo.decode(from: dataFile)
                info.filePath = path.string
                posts.append(info)
            } else {
                try posts.append(contentsOf: findPosts(in: path))
            }
        }
        return posts
    }
}
