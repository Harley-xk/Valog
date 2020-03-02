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
        routes.get("posts", use: getPosts)
        routes.get("posts", ":id", use: postDetail)
    }
    
    func getPosts(_ request: Request) throws -> EventLoopFuture<Page<Post.Public>> {
        return Post.query(on: request.db).sort(\.$date, .descending).paginate(for: request).map { (page) -> (Page<Post.Public>) in
            page.map { $0.makePublic() }
        }
    }
    
    func postDetail(_ request: Request) throws -> EventLoopFuture<Post.Details> {
        guard let id = request.parameters.get("id") else {
            throw Abort(.badRequest)
        }
        
        return Post.query(on: request.db).filter(\.$id == id).first().flatMapThrows { (post) -> EventLoopFuture<Post.Details> in
            guard let meta = post else {
                throw Abort(.notFound)
            }
            
            let path = Path(request.application.directory.publicDirectory + "_posts/" + meta.filePath)
            guard path.exists else {
                return request.eventLoop.future(
                    Post.Details(meta: meta.makePublic(), content: "*文章不存在或已删除*")
                )
            }
            
            let content = try String(contentsOf: path.url)
            meta.views += 1
            return meta.update(on: request.db).transform(
                    to: Post.Details(meta: meta.makePublic(), content: content)
            )
        }
    }
    
    func reloadPosts(_ request: Request) throws -> EventLoopFuture<[Post.Public]> {
        let path = Path(request.application.directory.storageDirectory + "Posts")
        let results = try self.findPosts(in: path)
        try MarkdownFileManager.copyResources(from: path, toPublicOf: request.application)
        
        return Post.query(on: request.db).all().flatMapThrows { (posts) -> EventLoopFuture<[Post]> in
            var exists: [Post] = []
            /// 删除已经移除的文章
            return posts.compactMap { post -> EventLoopFuture<Void>? in
                if results.contains(where: { $0.date == post.date }) {
                    exists.append(post)
                    return nil
                }
                return post.delete(on: request.db)
            }.flatten(on: request.eventLoop).transform(to: exists)
        }.flatMapThrows { (posts) -> EventLoopFuture<[Post.Public]> in
            return results.compactMap { (info) -> EventLoopFuture<Post.Public> in
                if let post = posts.first(where: { (p) -> Bool in
                    return p.date == info.date
                }) {
                    post.update(from: info)
                    return post.update(on: request.db).transform(to: post.makePublic())
                } else {
                    let model = info.makeModel()
                    return model.create(on: request.db).transform(to: model.makePublic())
                }
            }.flatten(on: request.eventLoop)
        }
    }
    
    func findPosts(in directory: Path) throws -> [PostInfo] {        
        let list = MarkdownFileManager.findFiles(from: directory)
        return try list.compactMap {
            try MarkdownFileManager.save(file: $0, toPublicOf: Application.shared)
            return PostInfo(title: $0.frontMatter.title,
                            date: $0.frontMatter.date,
                            intro: $0.frontMatter.abstract,
                            tags: $0.frontMatter.tags,
                            categories: $0.frontMatter.categories,
                            filePath: $0.relativePath)
        }
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
