//
//  RequestLog.swift
//  App
//
//  Created by Harley-xk on 2020/3/20.
//

import Foundation
import Vapor

struct RequestLog: Codable {
    var method: String
    var url: String
    var query: String?
    var headers: String
    var body: String
    
    init(_ request: Request) {
        method = request.method.string
        url = request.url.path
        query = request.url.query
        headers = request.headers.debugDescription
        body = request.body.string ?? ""
    }
}

struct ResponseLog: Codable {
    
    var status: Int
    var headers: String
    var body: String?
    
    init(_ response: Response, hidesBody: Bool = false) {
        status = Int(response.status.code)
        headers = response.headers.debugDescription
        body = hidesBody ? "<Object>" : response.body.description
    }
    
    init(error: Error) {
        status = -1
        headers = ""
        body = error.localizedDescription
    }
}
