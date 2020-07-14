//
//  ColoredLogger.swift
//  App
//
//  Created by Harley-xk on 2020/3/2.
//

import Foundation
import Vapor

/// Outputs logs to `LogFile`s.
/// Logs by every day will be placed in a logfile named by the date
public class DailyLogger: LogHandler {
    /// See `LogHandler.metadata`.
    public var metadata: Logger.Metadata
    
    /// See `LogHandler.logLevel`.
    public var logLevel: Logger.Level
    
    /// Creates a new `ColoredLogger` instance.
    ///
    /// - Parameters:
    ///   - label: Unique identifier for this logger.
    ///   - console: The console to log the messages to.
    ///   - level: The minimum level of message that the logger will output. This defaults to `.debug`, the lowest level.
    ///   - metadata: Extra metadata to log with the message. This defaults to an empty dictionary.
    public init(level: Logger.Level = .debug, metadata: Logger.Metadata = [:]) {
        self.metadata = metadata
        self.logLevel = level
    }
    
    /// See `LogHandler[metadataKey:]`.
    ///
    /// This just acts as a getter/setter for the `.metadata` property.
    public subscript(metadataKey key: String) -> Logger.Metadata.Value? {
        get { return self.metadata[key] }
        set { self.metadata[key] = newValue }
    }
    
    private var __file: DailyFile?
    private var __logDirectory: URL?
    
    private var logDirectory: URL? {
        if __logDirectory == nil, Application.isRunning {
            let path = Application.shared.directory.logsDirectory + "Standard/"
            __logDirectory = URL(fileURLWithPath: path)
        }
        return __logDirectory
    }
    
    private func reuseDailyFile() throws -> DailyFile? {
        guard let directory = logDirectory else {
            return nil
        }
        guard let file = __file, !file.isOutDated else {
            let date = Date()
            let f = try DailyFile(file: .make(for: date, at: directory, createIfNotExists: true), date: date)
            __file = f
            return f
        }
        return file
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
        
        text += " ".consoleText() + message.description.consoleText(color: .hex("#444444"))
        // only log metadata + file info if we are debug or trace
        if self.logLevel <= .debug,!self.metadata.isEmpty {
            // only log metadata if not empty
            text += " " + self.metadata.description.consoleText()
        }
        do {
            if let dailyFile = try reuseDailyFile() {
                print(text.terminalStylize(), to: &dailyFile.file)
            }
            if self.logLevel == .debug || self.logLevel == .trace {
                print(text.description)
            }
        } catch {
            print("Write Daily Logs Failed: \(error.localizedDescription)")
        }
        fflush(stdout)
    }
}
