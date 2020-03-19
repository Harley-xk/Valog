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
    var sections: [Post.Section]
    
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
        let lines = string.components(separatedBy: .newlines)
        guard lines.count > 0 else {
            throw MarkdownParseError(.noContents, in: path)
        }
        guard lines.first!.isYamlTag() else {
            throw MarkdownParseError(.noFrontMatter, in: path)
        }

        var yamlContent = ""
        var postContent = ""
        let rootSection = MarkdownSection(title: "", level: 0)
        
        var lastNode = rootSection
        
        var inYamlContent = false
        var inCodeblock = false
        
        for line in lines {
            if line.isYamlTag(), !inYamlContent, yamlContent.count <= 0 {
                inYamlContent = true
                continue
            }
            if line.isYamlTag(), inYamlContent {
                inYamlContent = false
                continue
            }
            if inYamlContent {
                yamlContent.append(line)
                yamlContent.append("\n")
            } else {
                postContent.append(line)
                postContent.append("\n")
                
                // 判断是否在代码区，这些区域忽略查找章节标题
                if line.hasPrefix("```") {
                    inCodeblock.toggle()
                }
                
                if !inCodeblock, let section = MarkdownFileManager.parseSection(from: line) {
                    lastNode.addChild(section)
                    lastNode = section
                }
            }
        }
        
        guard yamlContent.count > 0 else {
            throw MarkdownParseError(.noFrontMatter, in: path)
        }
        
        sections = rootSection.children?.compactMap { $0.toPostSection() } ?? []

        frontMatter = try YAMLDecoder().decode(from: yamlContent)
        contents = postContent.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    func makeModel() -> Post {
        let p = Post()
        p.id = frontMatter.date.removingOccurrences(["-", ":", " "])
        p.title = frontMatter.title
        p.date = frontMatter.date
        p.intro = frontMatter.abstract
        p.tags = frontMatter.tags
        p.categories = frontMatter.categories
        p.sections = sections
        p.filePath = relativePath
        p.views = 0
        p.comments = 0
        p.likes = 0
        return p
    }
}

class MarkdownSection: CustomStringConvertible {
    
    var title: String
    var level: Int
    var children: [MarkdownSection]?
    weak var parent: MarkdownSection?
    
    init(title: String, level: Int) {
        self.title = title
        self.level = level
    }
    
    func addChild(_ node: MarkdownSection) {
        if node.level <= level {
            parent?.addChild(node)
        } else {
            children = children ?? []
            children?.append(node)
            node.parent = self
        }
    }
    
    var description: String {
        let gap = " ".repeating(times: level)
        var string: String = gap + title
        for child in children ?? [] {
            string += "\n"
            string += child.description
        }
        return string
    }
    
    func toPostSection() -> Post.Section {
        return Post.Section(title: title,
                            level: level,
                            children: children?.compactMap { $0.toPostSection() })
    }
}

extension String {
    
    /// 一个字符串，把自身重复 n 遍
    func repeating(times: Int) -> String {
        if times <= 0 {
            return ""
        } else if times == 1 {
            return self
        } else {
            var result = ""
            for _ in 0 ..< times {
                result += self
            }
            return result
        }
    }
    
    func removingOccurrences(_ list: [String]) -> String {
        return list.reduce(self) { (result, s) -> String in
            return result.replacingOccurrences(of: s, with: "")
        }
    }
    
    func isYamlTag() -> Bool {
        return trimmingCharacters(in: .whitespaces) == "---"
    }
}
