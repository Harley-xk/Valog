//
//  Shell.swift
//  App
//
//  Created by Harley-xk on 2020/2/3.
//

import Foundation

final class SimpleShell {
    
    typealias TerminationHandler = (Process) -> ()
    
    static func run(cmd: String, on directory: String? = nil, handler: TerminationHandler? = nil) throws {
        let ls = Process()
        ls.executableURL = URL(fileURLWithPath: "/usr/bin/env")
        if let path = directory {
            ls.currentDirectoryURL = URL(fileURLWithPath: path)
        }
        ls.arguments = cmd.components(separatedBy: " ")
        ls.terminationHandler = handler
        try ls.run()
    }
    
    @discardableResult
    static func runSynchronously(cmd: String, on directory: String? = nil, executableURL: URL? = nil) throws -> Process {
        let ls = Process()
        ls.executableURL = executableURL ?? URL(fileURLWithPath: "/usr/bin/env")
        if let path = directory {
            ls.currentDirectoryURL = URL(fileURLWithPath: path)
        }
        ls.arguments = cmd.components(separatedBy: " ")
        try ls.run()
        ls.waitUntilExit()
        return ls
    }
}

extension Process {
    var readableReason: String {
        switch terminationReason {
        case .exit: return "exit with code: \(terminationStatus)"
        case .uncaughtSignal: return "exit with uncaughtSignal: \(terminationStatus)"
        default: return "exit with unknown status: \(terminationStatus)"
        }
    }
}
