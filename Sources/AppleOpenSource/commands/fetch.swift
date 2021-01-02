//
//  fetch.swift
//
//
//  Created by Kenneth Endfinger on 12/31/20.
//

import ArgumentParser
import Foundation

struct FetchTool: ParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "fetch",
        abstract: "Fetch Project Sources"
    )

    @Option(name: .shortAndLong, help: "Product Name")
    var product: String

    @Option(name: .shortAndLong, help: "Release Name")
    var release: String

    @Option(name: .shortAndLong, help: "Project Selections")
    var selection: [String] = []

    @Option(name: .shortAndLong, help: "Output Directory")
    var output: String = Process().currentDirectoryPath

    @Flag(name: .shortAndLong, help: "Extract Tarballs")
    var extract: Bool = false

    @Flag(name: .long, help: "Keep Tarballs Post-Extraction")
    var keepTar: Bool = false

    func run() throws {
        let lowerProductName = product.lowercased()
        let smooshedReleaseName = release.replacingOccurrences(of: ".", with: "")
        let moniker = "\(lowerProductName)-\(smooshedReleaseName)"
        let release = try OpenSourceClient.fetchReleaseDetails(moniker: moniker)

        let selectionInLower = selection.map {
            $0.lowercased()
        }

        let outputDirectoryURL = URL(fileURLWithPath: output)
        try FileManager.default.createDirectoriesIfNotExists(outputDirectoryURL)

        for project in release.projects.values {
            if !selection.isEmpty,
               !selectionInLower.contains(project.name!.lowercased()) {
                continue
            }
            let remoteTarballURL = URL(string: project.url!)!

            print("* \(remoteTarballURL.lastPathComponent)")

            let localTarURL = outputDirectoryURL.appendingPathComponent(remoteTarballURL.lastPathComponent)

            let semaphore = DispatchSemaphore(value: 0)
            let task = URLSession.shared.downloadTask(with: remoteTarballURL) { tmpTarURL, _, error in
                if error != nil {
                    FetchTool.exit(withError: error)
                }

                do {
                    try FileManager.default.moveItem(at: tmpTarURL!, to: localTarURL)
                } catch {
                    FetchTool.exit(withError: error)
                }
                semaphore.signal()
            }

            task.resume()
            semaphore.wait()
            if extract {
                let projectSourceURL = outputDirectoryURL.appendingPathComponent(project.name!)
                try FileManager.default.createDirectoriesIfNotExists(projectSourceURL)
                try extractProjectArchive(tar: localTarURL, into: projectSourceURL)

                if !keepTar {
                    try FileManager.default.removeItem(at: localTarURL)
                }
            }
        }

        FetchTool.exit()
    }
}
