//
//  extract.swift
//
//
//  Created by Kenneth Endfinger on 1/2/21.
//

import Foundation

func extractProjectArchive(tar: URL, into: URL) throws {
    let process = Process()
    process.executableURL = URL(fileURLWithPath: "/usr/bin/tar")
    process.currentDirectoryPath = into.absoluteURL.path
    process.arguments = [
        "zxf",
        tar.absoluteURL.path,
        "--strip-components",
        "1"
    ]
    try process.run()
    process.waitUntilExit()
    let exitStatus = process.terminationStatus
    if exitStatus != 0 {
        print("WARN: Failed to extract file \(tar.path) (status = \(exitStatus)")
    }
}
