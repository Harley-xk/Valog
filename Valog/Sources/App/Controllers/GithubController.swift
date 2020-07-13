//
//  File.swift
//  
//
//  Created by Harley-xk on 2020/7/7.
//

import Foundation
import Vapor
import Alamofire

class GithubController {
    
    func checkCode(_ request: Vapor.Request) throws -> EventLoopFuture<GithubUser.Response> {
        return try getAccessToken(by: request).flatMapThrows { (resp) -> EventLoopFuture<GithubUser.Response> in
            return try self.getGithubUser(request, with: resp)
        }
    }
    
    private func getAccessToken(by codeRequest: Vapor.Request) throws -> EventLoopFuture<AccessTokenResponse> {
        let content = try codeRequest.content.decode(CheckCodeRequest.self)
        let reqContent = AccessTokenRequest(
            client_id: codeRequest.application.config.github?.client_id ?? "",
            client_secret: codeRequest.application.config.github?.client_secret ?? "",
            code: content.code,
            state: content.state
        )
        
        return Alamofire.Session.default.request(
            "https://github.com/login/oauth/access_token",
            method: .post,
            parameters: reqContent,
            encoder: JSONParameterEncoder(),
            headers: [
                "Accept":"application/json",
            ]
        ).futureDataResponse(on: codeRequest.eventLoop).mapThrows { (data) -> AccessTokenResponse in
            return try self.decodeResponse(from: data, errorType: OAuthErrorResponse.self)
        }
    }
    
    private func getGithubUser(_ request: Vapor.Request, with token: AccessTokenResponse) throws -> EventLoopFuture<GithubUser.Response> {
        return Alamofire.Session.default.request(
            "https://api.github.com/user",
            method: .get,
            headers: [
                "Accept": "application/vnd.github.v3+json",
                "Authorization": "token \(token.access_token)",
            ]
        ).futureDataResponse(on: request.eventLoop).mapThrows { (data) -> GithubUser.Response in
            return try self.decodeApiResponse(from: data)
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
    
    private func decodeApiResponse<T: Content>(from data: Data) throws -> T {
        return try decodeResponse(from: data, errorType: ApiErrorResponse.self)
    }
    
    private func decodeResponse<T: Content, E: Content & Error>(
        from data: Data, errorType: E.Type
    ) throws -> T {
        var logContent = "[Github Response] "
        defer {
            Application.shared.logger.info("\(logContent)")
            #if DEBUG
            let dict = try! JSONSerialization.jsonObject(with: data)
            let formatted = try! JSONSerialization.data(withJSONObject: dict, options: .prettyPrinted)
            let content = String(data: formatted, encoding: .utf8)
            logContent += "\n\(content ?? "<null>")"
            print(logContent)
            #endif
        }
        if let model = try? JSONDecoder().decode(T.self, from: data) {
            logContent += String(describing: model)
            return model
        } else if let error = try? JSONDecoder().decode(E.self, from: data) {
            throw Abort(.badRequest, reason: error.localizedDescription)
        } else {
            throw Abort(.badRequest, reason: "未知错误")
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
