//
//  RedisKeys.swift
//  App
//
//  Created by Harley-xk on 2020/2/16.
//

import Foundation
import Vapor
import Redis

public protocol RedisKey {
    var rawValue: String { get }
}

extension RedisClient {
    
    public func get<D>(_ key: RedisKey, asJSON type: D.Type) -> EventLoopFuture<D?> where D : Decodable {
        return get(key.rawValue, asJSON: type)
    }
    
    /// Sets key to an encodable item.
    public func set<E>(_ key: RedisKey, toJSON entity: E) -> EventLoopFuture<Void> where E: Encodable {
        return set(key.rawValue, toJSON: entity)
    }
}

extension Request.Redis {
    
}

extension Post {
    
    enum Keys: String, RedisKey {
        case list = "post-list"
    }
    
    
}
