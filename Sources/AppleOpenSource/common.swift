//
//  constants.swift
//
//
//  Created by Kenneth Endfinger on 12/31/20.
//

import ArgumentParser
import Foundation

let openSourceHomeUrl = URL(string: "https://opensource.apple.com")!

enum OutputFormat: String, ExpressibleByArgument, CaseIterable {
    case text
    case json
}

extension Data {
    func string() -> String {
        String(data: self, encoding: .utf8)!
    }
}

extension Encodable {
    func json() throws -> String {
        let encoder = JSONEncoder()
        encoder.dataEncodingStrategy = .base64
        encoder.outputFormatting = [
            .prettyPrinted,
            .sortedKeys,
            .withoutEscapingSlashes
        ]
        return try encoder.encode(self).string()
    }
}

extension FileManager {
    func createDirectoriesIfNotExists(_ url: URL) throws {
        if FileManager.default.fileExists(atPath: url.path) {
            return
        }

        try FileManager.default.createDirectory(
            atPath: url.path,
            withIntermediateDirectories: true,
            attributes: nil
        )
    }
}
