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
        print("[ \(Date().string()) ] [ \(level.name) ] \(message)")
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
