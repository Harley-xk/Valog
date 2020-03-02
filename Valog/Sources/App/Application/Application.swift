//
//  application.swift
//  App
//
//  Created by Harley-xk on 2020/1/29.
//

import Vapor

fileprivate var runningApplication: Application!

fileprivate var _config: Config!

extension Application {
    
    static var shared: Application {
        return runningApplication
    }
    
    func prepareConfigure() throws -> Config {
        
        #if Xcode
        directory = DirectoryConfiguration(
            workingDirectory: #file.components(separatedBy: "/Sources").first!
        )
        #endif
        
        let path = Path(directory.workingDirectory + "config-" + environment.name + ".json")
        _config = try Config.decode(from: path)

        #if Xcode
        _config.webSite.root = directory.publicDirectory
        #endif
        
        runningApplication = self

        // create storage directory
        try FileManager.default.createDirectory(
            atPath: directory.storageDirectory,
            withIntermediateDirectories: true,
            attributes: nil
        )
        
        return _config
    }
    
    var config: Config {
        return _config
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
    public func flatMapThrows<NewValue>(
        file: StaticString = #file,
        line: UInt = #line,
        _ callback: @escaping (Value) throws -> EventLoopFuture<NewValue>
    ) -> EventLoopFuture<NewValue> {
        return flatMap { (value) -> EventLoopFuture<NewValue> in
            do {
                return try callback(value)
            } catch {
                return self.eventLoop.future(error: error)
            }
        }
    }
    
    public func mapThrows<NewValue>(
        file: StaticString = #file,
        line: UInt = #line,
        _ callback: @escaping (Value) throws -> NewValue
    ) -> EventLoopFuture<NewValue> {
        return flatMapResult { (value) -> Result<NewValue, Error> in
            do {
                let newValue = try callback(value)
                return .success(newValue)
            } catch {
                return .failure(error)
            }
        }
    }
}
