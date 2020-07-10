//
//  File.swift
//  
//
//  Created by Harley-xk on 2020/7/9.
//

import Foundation
import Vapor
import Fluent

/// Github 用户信息
final class GithubUser: Model {
    
    static let schema = "GithubUser"
    
    @ID(custom: "id")
    var id: Int?
    
    @Parent(key: "user_id")
    var user: User
    
    @Field(key: "login")
    var login: String

    @Field(key: "name")
    var name: String

    @Field(key: "email")
    var email: String

    @Field(key: "avatar_url")
    var avatar_url: String?

    @Field(key: "url")
    var url: String?

    // 暂时只需要以下字段
    struct Response: Content {
        var login: String
        var name: String
        var email: String
        var avatar_url: String
        var url: String
    }
    
    required init() {}
    
    init(from response: Response, user_id: Int) {
        $user.id = user_id
        login = response.login
        name = response.name
        email = response.email
        avatar_url = response.avatar_url
        url = response.url
    }
}
