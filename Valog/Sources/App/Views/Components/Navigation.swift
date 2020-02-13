//
//  Navigation.swift
//  App
//
//  Created by Harley-xk on 2020/2/12.
//

import Foundation
import Html

extension Node {
    
    static func navigation() -> Node {
        return .nav(
            attributes: [
                .class("navbar sticky-top navbar-expand-md navbar-dark bg-dark"),
            ],
            .button(
                attributes: [
                    .class("navbar-toggler"),
                    .type(.button),
                    .data("toggle", "collapse"),
                    .data("target", "#navbarSupportedContent"),
                    .ariaControls("navbarSupportedContent"),
                    .ariaExpanded(false),
                    .ariaLabel("Toggle navigation")
                ],
                .span(attributes: [.class("navbar-toggler-icon")])
            ),
            .a(attributes: [.class("navbar-brand"), .href("/")], "Harley's Studio"),
            .div(
                attributes: [.class("collapse navbar-collapse"), .id("navbarSupportedContent")],
                .ul(
                    attributes: [.class("navbar-nav mr-auto")],
                    makeNavitem(href: "/home", title: "首页"),
                    makeNavitem(href: "https://www.baidu.com/", title: "文章"),
                    makeNavitem(href: "/about", title: "关于")
                )
            ),
            .form(
                attributes: [.class("form-inline my-2 my-lg-0")],
                .input(attributes: [
                    .class("form-control mr-sm-2"),
                    .type(.search),
                    .placeholder("搜索文章"),
                    .ariaLabel("Search")
                ]),
                .button(attributes: [
                    .class("btn btn-outline-success my-2 my-sm-0"),
                    .type(.submit),
                ], "搜索")
            )
        )
    }
    
    static func makeNavitem(href: String, title: String) -> ChildOf<Tag.Ul> {
        return .li(
            attributes: [.class(title == "首页" ? "nav-item active" : "nav-item")],
            .a(
                attributes: [.class("nav-link"), .href(href)],
                .text(title), .span(attributes: [.class("sr-only")], "(current)")
            )
        )
    }
}
