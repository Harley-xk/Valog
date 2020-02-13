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
        
        server.configuration.hostname = "0.0.0.0"
        
        // create storage directory
        try FileManager.default.createDirectory(
            atPath: directory.dataDirectory,
            withIntermediateDirectories: true,
            attributes: nil
        )
//
//        try SimpleShell.runSynchronously(cmd: "mkdir GitTest")
//        try SimpleShell.runSynchronously(
//            //            cmd: "git clone https://github.com/Harley-xk/MySite.git --branch=gh-pages",
//            cmd: "git clone https://github.com/Harley-xk/LiteStory-iOS.git",
//            on: self.directory.workingDirectory + "GitTest/"
//        )
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
