//
//  client.swift
//  
//
//  Created by Kenneth Endfinger on 12/31/20.
//

import Foundation

struct OpenSourceClient {
    static func fetchReleaseDetails(moniker: String) throws -> OpenSourceRelease {
        let url = URL(string: "https://opensource.apple.com/plist/\(moniker).plist")!
        let data = try Data(contentsOf: url)
        var release = try PropertyListDecoder().decode(OpenSourceRelease.self, from: data)
        for projectName in release.projects.keys {
            var project = release.projects[projectName]!
            project.name = projectName
            release.projects[projectName] = project
        }
        return release
    }
}

struct OpenSourceRelease: Codable {
    var build: String
    var inherits: String
    var projects: [String:OpenSourceProject]
}

struct OpenSourceProject: Codable {
    var version: String
    
    var name: String? = "unknown"
    
    func createDownloadURL() -> URL {
        URL(string: "https://opensource.apple.com/tarballs/\(name!)/\(name!)-\(version).tar.gz")!
    }
}
