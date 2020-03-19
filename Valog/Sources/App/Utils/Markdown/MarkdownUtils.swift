//
//  MarkdownUtils.swift
//  App
//
//  Created by Harley-xk on 2020/2/25.
//

import Foundation
import Vapor

struct MarkdownParseError: Error, CustomStringConvertible {
    
    enum Error: String {
        case noContents
        case noFrontMatter
    }

    var filename: String
    var error: Error
    
    init(_ error: Error, in file: String) {
        self.error = error
        self.filename = file
    }
    
    init(_ error: Error, in file: URL) {
        self.error = error
        self.filename = file.relativePath
    }
    
    var description: String {
        return "解析 Markdown 出错，文件：\(filename)，错误：\(error.rawValue)"
    }
}

class MarkdownFileManager {
    
    static func findFiles(from directory: Path) -> [MarkdownFile] {
        
        var children: [Path] = []
        
        do {
            children = try directory.children()
        } catch {
            Application.shared.logger.error("No contents find: \(error)")
            return []
        }
        
        var files: [MarkdownFile] = []
        for path in children {
            if path.isDirectory {
                files.append(contentsOf: findFiles(from: path))
            } else if path.extension == "md" {
                do {
                    let file = try MarkdownFile(path: path.url)
                    files.append(file)
                } catch {
                    Application.shared.logger.error("Parse markdown failed: \(error), file: \(path.string)")
                }
            }
        }
        return files
    }
    
    static func save(file: MarkdownFile, toPublicOf app: Application) throws {
        let fullPath = Path(app.directory.publicDirectory + "_posts/" + file.relativePath)
        let directory = fullPath.parent()
        if !directory.exists {
            try FileManager.default.createDirectory(at: directory.url, withIntermediateDirectories: true, attributes: nil)
        }
        try file.contents.write(to: fullPath.url, atomically: true, encoding: .utf8)
    }
    
    static func copyResources(from directory: Path, toPublicOf app: Application) throws {
        
        for path in try directory.children() {
            guard path.isDirectory, path.lastComponent != "_posts" else {
                continue
            }
            let dest = Path(app.config.webSite.root + path.lastComponent)
            if dest.exists {
                try FileManager.default.removeItem(at: dest.url)
            }
            try FileManager.default.copyItem(at: path.url, to: dest.url)
        }
    }
    
    
    static func parseSection(from line: String) -> MarkdownSection? {
        guard let prefix = line.components(separatedBy: " ").first else {
            return nil
        }
        var level = 0
        switch prefix {
        case "#": level = 1
        case "##": level = 2
        case "###": level = 3
        case "####": level = 4
        case "#####": level = 5
        case "######": level = 6
        default: return nil
        }
        let title = line.replacingOccurrences(of: prefix + " ", with: "")
        return MarkdownSection(title: title, level: level)
    }
}
