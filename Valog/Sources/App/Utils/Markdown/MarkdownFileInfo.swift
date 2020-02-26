//
//  MarkdownFileInfo.swift
//  App
//
//  Created by Harley-xk on 2020/2/25.
//

import Foundation
import Yams

struct MarkdownFile {
    
    struct FrontMatter: Codable {
        var title: String
        var date: String

        var abstract: String?
        var tags: [String]?
        var categories: [String]?
    }
    
    var frontMatter: FrontMatter
    var contents: String
    
    var relativePath: String {
        guard let date = Date(string: frontMatter.date, format: "yyyy-MM-dd HH:mm") else {
            return frontMatter.date + ".md"
        }
        return "\(date.unit(.year))" + "/"
            + "\(date.unit(.month))" + "/"
            + "\(date.unit(.day))" + "/"
            + "\(date.unit(.hour))\(date.unit(.minute))"
            + ".md"
    }
    
    init(path: URL) throws {
        let string = try String(contentsOf: path).trimmingCharacters(in: .whitespacesAndNewlines)
        var lines = string.components(separatedBy: .newlines)
        guard lines.count > 0 else {
            throw MarkdownParseError.noContents
        }
        guard lines.first!.hasPrefix("---") else {
            throw MarkdownParseError.noFrontMatter
        }

        var yamlContent = ""
        var endTagFound = false

        lines.removeFirst()
        while !endTagFound {
            let line = lines.removeFirst()
            if line.hasPrefix("---") {
                endTagFound = true
                break
            }
            yamlContent.append(line)
            yamlContent.append("\n")
        }

        guard endTagFound else {
            throw MarkdownParseError.noFrontMatter
        }

        frontMatter = try YAMLDecoder().decode(from: yamlContent)
        contents = lines.joined(separator: "\n").trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
