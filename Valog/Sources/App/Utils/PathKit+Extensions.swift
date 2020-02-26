//
//  PathKit+Extensions.swift
//  App
//
//  Created by Harley-xk on 2020/2/26.
//

import Foundation

extension Path {
    
    init(_ url: URL) {
        self.init(url.relativePath)
    }
    
    /// refers to URL.appendingPathComponent(_:,isDirectory:)
    func appendingPathComponent(_ pathComponent: String, isDirectory: Bool) -> Path {
        return Path(url.appendingPathComponent(pathComponent, isDirectory: isDirectory))
    }
    
    func deletingLastPathComponent() -> Path {
        return Path(url.deletingLastPathComponent())
    }
    
    func appendingPathExtension(pathExtension: String) -> Path {
        return Path(url.appendingPathExtension(pathExtension))
    }
    
    func deletingPathExtension() -> Path {
        return Path(url.deletingPathExtension())
    }
    
}
