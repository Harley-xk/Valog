//
//  File.swift
//  
//
//  Created by Harley-xk on 2020/7/7.
//

import Foundation
import Vapor
import AsyncHTTPClient

class GithubController {
    
    func checkCode(_ request: Request) throws -> EventLoopFuture<GithubUser.Response> {
        return try getAccessToken(by: request).flatMapThrows { (resp) -> EventLoopFuture<GithubUser.Response> in
            return try self.getGithubUser(request, with: resp)
        }
    }
    
    private func getAccessToken(by codeRequest: Request) throws -> EventLoopFuture<AccessTokenResponse> {
        let content = try codeRequest.content.decode(CheckCodeRequest.self)
        let reqContent = AccessTokenRequest(
            client_id: codeRequest.application.config.github?.client_id ?? "",
            client_secret: codeRequest.application.config.github?.client_secret ?? "",
            code: content.code,
            state: content.state
        )
        return codeRequest.client.post(
            "https://github.com/login/oauth/access_token",
            headers: [
                "Accept":"application/json",
                "User-Agent": "Valog HttpClient, powered by Vapor"
            ]
        ) { (request) in
            try request.content.encode(reqContent, as: .json)
        }.mapThrows { (resp) -> (AccessTokenResponse) in
            return try self.decodeResponse(resp, errorType: OAuthErrorResponse.self)
        }
    }
    
    private func getGithubUser(_ request: Request, with token: AccessTokenResponse) throws -> EventLoopFuture<GithubUser.Response> {
        
        return request.client.get(
            "https://api.github.com/user",
            headers: [
                    "Accept": "application/json",
                    "Authorization": "token \(token.access_token)",
                    "User-Agent": "Valog HttpClient, powered by Vapor"
            ]).mapThrows { (resp) -> GithubUser.Response in
                return try self.decodeApiResponse(resp)
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
    
    struct OAuthErrorResponse: Content, Error {
        var error: String
        var error_description: String
        var error_uri: String?
    }
    
    struct ApiErrorResponse: Content, Error {
        var message: String
        var documentation_url: String?
    }
    
    private func decodeApiResponse<T: Content>(_ response: ClientResponse) throws -> T {
        return try decodeResponse(response, errorType: ApiErrorResponse.self)
    }
    
    private func decodeResponse<T: Content, E: Content & Error>(
        _ response: ClientResponse, errorType: E.Type
    ) throws -> T {
        
        Application.shared.logger.info("[Github Response] \(response.description)")
        
        if let error = try? response.content.decode(E.self) {
            throw Abort(.badRequest, reason: error.localizedDescription)
        }
        do {
            let model = try response.content.decode(T.self)
            return model
        } catch {
            throw Abort(.badRequest, reason: error.localizedDescription)
        }
    }
}

extension GithubController.OAuthErrorResponse: LocalizedError {
    var errorDescription: String? {
        return error_description
    }
}

extension GithubController.ApiErrorResponse: LocalizedError {
    var errorDescription: String? {
        return message
    }
}
