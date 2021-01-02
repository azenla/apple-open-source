//
//  extract.swift
//
//
//  Created by Kenneth Endfinger on 1/2/21.
//

import Foundation

func extractArchive(tar: URL, into: URL) throws {
    let process = Process()
    process.executableURL = URL(fileURLWithPath: "/usr/bin/tar")
    process.currentDirectoryPath = into.path
    process.arguments = [
        "xf",
        tar.path
    ]
    try process.run()
    process.waitUntilExit()
    let exitStatus = process.terminationStatus
    if exitStatus != 0 {
        exit(1)
    }
}
