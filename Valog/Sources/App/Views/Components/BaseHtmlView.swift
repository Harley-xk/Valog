//
//  BaseHtmlView.swift
//  App
//
//  Created by Harley-xk on 2020/2/12.
//

import Foundation
import Html
import Vapor

extension Node: ResponseEncodable {
    public func encodeResponse(for request: Request) -> EventLoopFuture<Response> {
        let body = Response.Body(string: Html.render(self))
        let response = Response(headers: ["content-type": "text/html; charset=utf-8"], body: body)
        return request.eventLoop.submit { response }
    }
}


func makeHTMLPage(body: Node ...) -> Node {
    
    return .html(
        attributes: [
            
        ],
        .head(
            .meta(attributes: [.charset(.utf8)]),
            .meta(viewport: .width(.deviceWidth), .initialScale(1)),
            .link(attributes: [.href("/styles/bootstrap.min.css"), .rel(.stylesheet)]),
            .link(attributes: [.href("/styles/app.css"), .rel(.stylesheet)])
        ),
        .body(
            .div(attributes: [.class("container-md")],
                 .navigation(),
                 .fragment(body)
            ),
            .script(attributes: [.src("/scripts/jquery.min.js"), .crossorigin(.anonymous)]),
            .script(attributes: [.src("/scripts/popper.min.js"), .crossorigin(.anonymous)]),
            .script(attributes: [.src("/scripts/bootstrap.min.js"), .crossorigin(.anonymous)])
        )
    )
}

