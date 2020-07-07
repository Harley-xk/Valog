//
//  File.swift
//  
//
//  Created by Harley-xk on 2020/7/7.
//

import Foundation
import Vapor
import AsyncHTTPClient

class GithubController: RouteCollection {
    
    func boot(routes: RoutesBuilder) throws {
        let group = routes.grouped("github")
        group.post("check-code", use: checkCode)
    }
    
    private func checkCode(_ request: Request) throws -> EventLoopFuture<AccessTokenResponse> {
        let content = try request.content.decode(CheckCodeRequest.self)
        let reqContent = AccessTokenRequest(
            client_id: request.application.config.github?.client_id ?? "",
            client_secret: request.application.config.github?.client_secret ?? "",
            code: content.code,
            state: content.state
        )
        return request.client.post(
            "https://github.com/login/oauth/access_token",
            headers: ["Accept":"application/json"]
        ) { (request) in
            try request.content.encode(reqContent, as: .json)
        }.mapThrows { (resp) -> (AccessTokenResponse) in
            return try resp.content.decode(AccessTokenResponse.self)
        }
    }

}

extension GithubController {
    
    struct CheckCodeRequest: Content {
        var code: String
        var state: String
    }
    
    struct AccessTokenRequest: Content {
        /// Required. The client ID you received from GitHub for your GitHub App.
        var client_id: String
        
        /// Required. The client secret you received from GitHub for your GitHub App.
        var client_secret: String
        
        /// Required. The code you received as a response to Step 1.
        var code: String
                
        /// The unguessable random string you provided in Step 1.
        var state: String
    }
    
    struct AccessTokenResponse: Content {
        var access_token: String
        var token_type: String
    }
}
