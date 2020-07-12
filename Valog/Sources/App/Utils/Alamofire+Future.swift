//
//  File.swift
//  
//
//  Created by Harley on 2020/7/12.
//

import Foundation
import Alamofire
import NIO

extension DataRequest {
    
    func futureDataResponse(on eventLoop: EventLoop) -> EventLoopFuture<Data> {
        let promise = eventLoop.makePromise(of: Data.self)
        responseData(queue: .init(label: "Alamofire Task Queue")) { (resp) in
            do {
                try promise.succeed(resp.result.get())
            } catch {
                promise.fail(error)
            }
        }
        return promise.futureResult
    }
    
//    func futureModelResponse()
    
}
