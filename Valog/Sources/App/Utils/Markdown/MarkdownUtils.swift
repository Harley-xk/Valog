//
//  MarkdownUtils.swift
//  App
//
//  Created by Harley-xk on 2020/2/25.
//

import Foundation
import Vapor

enum MarkdownParseError: Error {
    case noContents
    case noFrontMatter
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
                    Application.shared.logger.error("Parse markdown failed: \(error)")
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
    
}
