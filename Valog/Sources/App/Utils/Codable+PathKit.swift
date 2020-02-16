//
//  Codable+PathKit.swift
//  App
//
//  Created by Harley-xk on 2020/2/16.
//

import Foundation

extension Decodable {

    // 从 json 文件中读取对象
    static func decode(from file: Path, decoder: JSONDecoder = JSONDecoder()) throws -> Self {
        let data = try Data(contentsOf: file.url)
        return try decoder.decode(Self.self, from: data)
    }
}

extension Encodable {
    
    // 将对象写入 json 文件
    func encode(to file: Path, encoder: JSONEncoder = JSONEncoder()) throws {
        let data = try encoder.encode(self)
        try data.write(to: file.url)
    }
    
}
