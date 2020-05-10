//
//  ExtraDirectory.swift
//  
//
//  Created by Harley-xk on 2020/5/6.
//

import Foundation
import Vapor

extension DirectoryConfiguration {
    public var storageDirectory: String {
        return workingDirectory + "Storage/"
    }
    
    public var dataDirectory: String {
        return storageDirectory + "Data/"
    }
    
    public var logsDirectory: String {
        return storageDirectory + "Logs/"
    }
}
