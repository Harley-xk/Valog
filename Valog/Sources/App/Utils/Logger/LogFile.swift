//
//  LogFile.swift
//
//
//  Created by Harley-xk on 2020/5/5.
//

import Foundation

open class LogFile: TextOutputStream {
    
    /// 根据日期创建日志文件对象
    /// - Parameters:
    ///   - date: 日志时间
    ///   - directory: 日志文件所在的文件夹
    ///   - createIfNotExists: 如果日志文件不存在则自动创建
    /// - Throws: 略
    static func make(for date: Date = Date(), at directory: URL, createIfNotExists: Bool = true) throws -> LogFile {
        var isDirectory = ObjCBool(false)
        let folder = directory.appendingPathComponent("\(date.unit(.year))")
        let exists = FileManager.default.fileExists(atPath: folder.relativePath, isDirectory: &isDirectory)
        if !exists {
            if createIfNotExists {
                try FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true, attributes: nil)
            } else {
                throw URL.Error.fileDoesNotExist
            }
        } else if !isDirectory.boolValue {
            throw URL.Error.fileIsNotDirectory
        }

        let fileName = date.string(format: "MM-dd") + ".log"
        let path = folder.appendingPathComponent(fileName, isDirectory: false)
        return LogFile(path: path, createIfNotExists: createIfNotExists)
    }
    
    init(path: URL, createIfNotExists: Bool) {
        filePath = path
        autoCreate = createIfNotExists
    }
    
    private var filePath: URL
    
    private var autoCreate: Bool = true
    
    open var fileSize: Int64 {
        let size = try? FileManager.default.attributesOfItem(atPath: filePath.relativePath)[.size]
        return size as? Int64 ?? 0
    }
    
    open func write(_ string: String) {
        try? string.append(to: filePath, autoCreate: autoCreate)
    }
    
    open func read() throws -> String {
        return try String(contentsOf: filePath)
    }
}

public extension DailyLogger {
    
    class DailyFile {
        var file: LogFile
        var date: Date
        
        var isOutDated: Bool {
            return !date.isSameDay(as: Date())
        }
        
        init(file: LogFile, date: Date = Date()) {
            self.file = file
            self.date = date
        }
    }
}
