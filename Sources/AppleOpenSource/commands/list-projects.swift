//
//  list-projects.swift
//
//
//  Created by Kenneth Endfinger on 12/31/20.
//

import ArgumentParser
import Foundation

struct ListProjectsTool: ParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "list-projects",
        abstract: "List Projects Available in a Release"
    )

    @Option(name: .shortAndLong, help: "Product Name")
    var product: String

    @Option(name: .shortAndLong, help: "Release Name")
    var release: String

    @Option(name: .shortAndLong, help: "Output Format")
    var format: OutputFormat = .text

    func run() throws {
        let lowerProductName = product.lowercased()
        let smooshedReleaseName = release.replacingOccurrences(of: ".", with: "")
        let moniker = "\(lowerProductName)-\(smooshedReleaseName)"
        let release = try OpenSourceClient.fetchReleaseDetails(moniker: moniker)

        switch format {
        case .text:
            for project in release.projects.values {
                print("* \(project.name!)")
                print("  * version = \(project.version)")
                print("  * url = \(project.url!)")
            }
        case .json:
            print(try release.json())
        }
    }
}
