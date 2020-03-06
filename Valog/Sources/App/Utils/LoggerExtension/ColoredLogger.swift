//
//  ColoredLogger.swift
//  App
//
//  Created by Harley-xk on 2020/3/2.
//

import Foundation
import Vapor

/// Outputs logs to a `Console`.
/// Copied from ConsoleLogger and modified the output format
public struct ColoredLogger: LogHandler {
    
    public let label: String
    
    /// See `LogHandler.metadata`.
    public var metadata: Logger.Metadata
    
    /// See `LogHandler.logLevel`.
    public var logLevel: Logger.Level
    
    /// The conosle that the messages will get logged to.
    public let console: Console
    
    /// Creates a new `ColoredLogger` instance.
    ///
    /// - Parameters:
    ///   - label: Unique identifier for this logger.
    ///   - console: The console to log the messages to.
    ///   - level: The minimum level of message that the logger will output. This defaults to `.debug`, the lowest level.
    ///   - metadata: Extra metadata to log with the message. This defaults to an empty dictionary.
    public init(label: String, console: Console, level: Logger.Level = .debug, metadata: Logger.Metadata = [:]) {
        self.label = label
        self.metadata = metadata
        self.logLevel = level
        self.console = console
    }
    
    /// See `LogHandler[metadataKey:]`.
    ///
    /// This just acts as a getter/setter for the `.metadata` property.
    public subscript(metadataKey key: String) -> Logger.Metadata.Value? {
        get { return self.metadata[key] }
        set { self.metadata[key] = newValue }
    }
    
    /// See `LogHandler.log(level:message:metadata:file:function:line:)`.
    public func log(
        level: Logger.Level,
        message: Logger.Message,
        metadata: Logger.Metadata?,
        file: String,
        function: String,
        line: UInt
    ) {
        var text: ConsoleText = ""
        
        let sep_l = "[".consoleText(color: .hex("#CECECE"))
        let sep_r = "]".consoleText(color: .hex("#CECECE"))
        let date = Date().string().consoleText(color: .hex("#3AC0B1"))
        text += sep_l + date + sep_r
        text += sep_l + level.consoleName + sep_r
        if self.logLevel <= .trace {
            text += sep_l + self.label.consoleText() + sep_r
        }
        
        text += " ".consoleText() + message.description.consoleText(color: .hex("#444444"))
        // only log metadata + file info if we are debug or trace
        if self.logLevel <= .debug {
            if !self.metadata.isEmpty {
                // only log metadata if not empty
                text += " " + self.metadata.description.consoleText()
            }
            // log the concise path + line
            let fileInfo = "(\(self.conciseSourcePath(file)) : \(line.description))"
                .consoleText(color: .hex("#8c8c8c"))
            text += fileInfo
        }
        self.console.output(text)
    }
    
    /// splits a path on the /Sources/ folder, returning everything after
    ///
    ///     "/Users/developer/dev/MyApp/Sources/Run/main.swift"
    ///     // becomes
    ///     "Run/main.swift"
    ///
    private func conciseSourcePath(_ path: String) -> String {
        return path.split(separator: "/")
            .split(separator: "Sources")
            .last?
            .joined(separator: "/") ?? path
    }
}

extension LoggingSystem {
   
    public static func bootstrapColoredLogger(from environment: inout Environment) throws {
        let level: Logger.Level = environment == .production ? .info : .debug
        self.bootstrap { label in
            return ColoredLogger(label: label, console: Terminal(), level: level, metadata: [:])
        }
    }
}

extension Logger.Level {
    /// Converts log level to console style
    public var coloredStyle: ConsoleStyle {
        switch self {
        case .trace, .debug: return ConsoleStyle(color: .hex("#947839"))
        case .info, .notice: return ConsoleStyle(color: .hex("#1C941E"))
        case .warning: return ConsoleStyle(color: .hex("#C66600"))
        case .error: return ConsoleStyle(color: .hex("#C62100"))
        case .critical: return ConsoleStyle(color: .brightRed)
        }
    }
    
    public var localizedName: String {
        switch self {
        case .trace: return "跟踪"
        case .debug: return "调试"
        case .info: return "信息"
        case .notice: return "注意"
        case .warning: return "警告"
        case .error: return "错误"
        case .critical: return "崩溃"
        }
    }
    
    var consoleName: ConsoleText {
        return localizedName.consoleText(coloredStyle)
    }
}
