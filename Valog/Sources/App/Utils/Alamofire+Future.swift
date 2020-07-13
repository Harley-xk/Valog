//
//  File.swift
//  
//
//  Created by Harley on 2020/7/12.
//

import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif
import Alamofire
import NIO

extension DataRequest {
    
    private var responseQueue: DispatchQueue {
        return .init(label: "com.harley.valog.alamofire.queue.response")
    }
    
    func futureDataResponse(on eventLoop: EventLoop) -> EventLoopFuture<Data> {
        let promise = eventLoop.makePromise(of: Data.self)
        responseData(queue: responseQueue) { (resp) in
            promise.completeWith(af_result: resp.result)
        }
        return promise.futureResult
    }
    
    func futureModelResponse<Model: Codable>(model: Model.Type, on eventLoop: EventLoop) -> EventLoopFuture<Model> {
        let promise = eventLoop.makePromise(of: Model.self)
        responseDecodable(of: Model.self, queue: responseQueue) { (resp) in
            promise.completeWith(af_result: resp.result)
        }
        return promise.futureResult
    }
}

extension EventLoopPromise {
    func completeWith(af_result result: Result<Value, AFError>) {
        do {
            try succeed(result.get())
        } catch {
            fail(error)
        }
    }
}
