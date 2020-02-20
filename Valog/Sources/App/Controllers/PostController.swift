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
    
    func allPosts(_ request: Request) throws -> EventLoopFuture<Page<Post.Public>> {
        return Post.query(on: request.db).sort(\.$date, .descending).paginate(for: request).map { (page) -> (Page<Post.Public>) in
            page.map { $0.makePublic() }
        }
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
            if let info = try decodePost(from: path) {
                posts.append(info)
            }
            try posts.append(contentsOf: findPosts(in: path))
        }
        return posts
    }
    
    func decodePost(from directory: Path) throws -> PostInfo? {
        
        var postInfo: PostInfo?
        var markdownPath: Path?
        
        for path in try directory.children() {
            if path.extension == "json", postInfo == nil {
                postInfo = try PostInfo.decode(from: path)
            }
            if path.extension == "md", markdownPath == nil {
                markdownPath = path
            }
        }
        if var info = postInfo, let md = markdownPath {
            info.filePath = md.string
            return info
        } else {
            return nil
        }
    }
}
