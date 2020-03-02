//
//  TimingLogger.swift
//  App
//
//  Created by Harley-xk on 2020/2/28.
//

import Foundation
import Vapor

extension Logger {
    static func timed(label: String) -> Logger {
        return Logger(label: label) { (_) -> LogHandler in
            return PritingTimingLogger()
        }
    }
}

final class PritingTimingLogger: LogHandler {
    func log(level: Logger.Level, message: Logger.Message, metadata: Logger.Metadata?, file: String, function: String, line: UInt) {
        let sep_l: String = "[".colored(hex: "CECECE")
        let sep_r: String = "]".colored(hex: "CECECE")
        let date = Date().string().colored(hex: "3AC0B1")
        var content = "\(sep_l)\(date)\(sep_r)"
        content += "\(sep_l)\(level.coloredName)\(sep_r)"
        content += " \(message.description.colored(hex: "444444"))"
        print(content)        
    }
    
    subscript(metadataKey key: String) -> Logger.Metadata.Value? {
        get {
            return metadata[key]
        }
        set(newValue) {
            metadata[key] = newValue
        }
    }
    
    var metadata: Logger.Metadata = [:]
    
    var logLevel: Logger.Level = .info
}

extension Logger.Level {
    
    var coloredName: String {
        switch self {
        /// Appropriate for messages that contain information only when debugging a program.
        case .trace: return "追踪".colored(hex: "947839")
            
        /// Appropriate for messages that contain information normally of use only when
        /// debugging a program.
        case .debug: return "调试".colored(hex: "947839")
            
        /// Appropriate for informational messages.
        case .info: return "日志".colored(hex: "1C941E")
            
        /// Appropriate for conditions that are not error conditions, but that may require
        /// special handling.
        case .notice: return "注意".colored(hex: "8D9439")
            
        /// Appropriate for messages that are not error conditions, but more severe than
        /// `.notice`.
        case .warning: return "警告".colored(hex: "C66600")
            
        /// Appropriate for error conditions.
        case .error: return "错误".colored(hex: "C62100")
            
        /// Appropriate for critical error conditions that usually require immediate
        /// attention.
        ///
        /// When a `critical` message is logged, the logging backend (`LogHandler`) is free to perform
        /// more heavy-weight operations to capture system state (such as capturing stack traces) to facilitate
        /// debugging.
        case .critical: return "CRITICAL".colored(hex: "EB0000")
        }
    }
}

extension String {
    func colored(hex: String) -> String {
        return Color(hex: hex).toANSI() + self
    }
    
    func colored(_ color: Color) -> String {
        return color.toANSI() + self
    }
}

public struct Color: Codable {
        
    public internal(set) var red: Int
    public internal(set) var green: Int
    public internal(set) var blue: Int

    public init(_ red: Int, _ green: Int, _ blue: Int) {
        self.red = red
        self.green = green
        self.blue = blue
    }
    
    public init(hex: String) {
        var int = UInt64()
        Scanner(string: hex).scanHexInt64(&int)
        let r, g, b: UInt64
        (r, g, b) = (int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        (red, green, blue) = (Int(r), Int(g), Int(b))
    }
    
    func toANSI() -> String {
        return "\u{001B}[38;2;\(red);\(green);\(blue)m"
    }
}
