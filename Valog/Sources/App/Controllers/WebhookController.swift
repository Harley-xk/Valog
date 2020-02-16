//
//  WebhookController.swift
//  App
//
//  Created by Harley-xk on 2020/2/16.
//

import Foundation
import Vapor

class WebhooksController: RouteCollection {
    
    func boot(routes: RoutesBuilder) throws {
        routes.post("webhook", use: pushAction)
    }
    
    func pushAction(_ request: Request) throws -> HTTPStatus {
        
        print("== Headers ==")
        request.headers.forEach { (name, value) in
            print("\(name) : \(value)")
        }
        print("== Body ==")
        print(request.body.string ?? "<empty body>")
        
        return .ok
    }
    
}
