//
//  application.swift
//  App
//
//  Created by Harley-xk on 2020/1/29.
//

import Vapor

fileprivate var runningApplication: Application!

extension Application {
    
    static var running: Application {
        return runningApplication
    }
    
    func beforeConfigure() throws {
        runningApplication = self

        // create storage directory
        try FileManager.default.createDirectory(
            atPath: directory.storageDirectory,
            withIntermediateDirectories: true,
            attributes: nil
        )
        
        // clone posts
        if !Path(directory.storageDirectory + "Posts").exists {
            try SimpleShell.runSynchronously(
                cmd: "git clone https://github.com/Harley-xk/Posts.git",
                on: directory.storageDirectory
            )
        }        
    }
}

extension DirectoryConfiguration {
    
    public var storageDirectory: String {
        return workingDirectory + "Storage/"
    }
    
    public var dataDirectory: String {
        return storageDirectory + "Data/"
    }
}

extension EventLoopFuture {
    public func flatMapThrows<NewValue>(file: StaticString = #file, line: UInt = #line, _ callback: @escaping (Value) throws -> EventLoopFuture<NewValue>) -> EventLoopFuture<NewValue> {
        return flatMap { (value) -> EventLoopFuture<NewValue> in
            do {
                return try callback(value)
            } catch {
                return self.eventLoop.future(error: error)
            }
        }
    }
}
