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
            atPath: directory.dataDirectory,
            withIntermediateDirectories: true,
            attributes: nil
        )
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
