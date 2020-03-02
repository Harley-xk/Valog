//
//  ConsoleStyleExtension.swift
//  App
//
//  Created by Harley-xk on 2020/3/2.
//

import Foundation
import Vapor

extension ConsoleColor {
    
    static func hex(_ string: String) -> ConsoleColor {
        var int = UInt64()
        var hex = string
        if hex.hasPrefix("#") { hex = hex.replacingOccurrences(of: "#", with: "") }
        Scanner(string: hex).scanHexInt64(&int)
        let r, g, b: UInt64
        (r, g, b) = (int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        return .custom(r: UInt8(r), g: UInt8(g), b: UInt8(b))
    }
    
}
