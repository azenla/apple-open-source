//
//  xcode-projects.swift
//
//
//  Created by Kenneth Endfinger on 1/2/21.
//

import AnyCodable
import ArgumentParser
import Foundation

struct XcodeProjectsTool: ParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "xcode-projects",
        abstract: "Scan Apple Sources for Xcode Projects"
    )

    @Flag(name: .long, help: "Print Xcode Project Paths")
    var printProjectPaths: Bool = false

    @Flag(name: .long, help: "Find Installed Artifacts")
    var findInstalledArtifacts: Bool = false

    func run() throws {
        let result = try ProcessRunner.run("/usr/bin/find", [
            ".",
            "-type",
            "d",
            "-name",
            "*.xcodeproj"
        ])

        var xcodeProjectPaths: [String] = []

        let output = result.standardOutput
        for line in output.components(separatedBy: "\n") {
            if line.isEmpty {
                continue
            }
            let relativeFilePath = line[line.index(line.startIndex, offsetBy: 2)...]
            xcodeProjectPaths.append(String(relativeFilePath))
        }

        if printProjectPaths {
            for xcodeProjectPath in xcodeProjectPaths {
                print(xcodeProjectPath)
            }
            XcodeProjectsTool.exit()
        }

        if findInstalledArtifacts {
            for xcodeProjectPath in xcodeProjectPaths {
                let model = try loadXcodeProject(xcodeProjectPath)
                if model != nil {
                    try analyzeXcodeModel(xcodeProjectPath, model!)
                }
            }
        }
    }

    func loadXcodeProject(_ path: String) throws -> XcodeProjectModel? {
        let projectFileURL = URL(fileURLWithPath: path).appendingPathComponent("project.pbxproj")
        if !FileManager.default.fileExists(atPath: projectFileURL.path) {
            return nil
        }
        let data = try Data(contentsOf: projectFileURL)
        let decoder = PropertyListDecoder()
        return try decoder.decode(XcodeProjectModel.self, from: data)
    }

    func analyzeXcodeModel(_ path: String, _ model: XcodeProjectModel) throws {
        let targets = model.findObjectWithType("PBXNativeTarget")

        for entry in targets {
            let object = entry.value
            let productName = object.productName!
            let productReference = model.objects[object.productReference ?? "__NONE__"]
            let productReferencePath = productReference?.path
            let installPath = object.productInstallPath

            print("\(path) \(productName) \(String(describing: productReferencePath)) \(String(describing: installPath))")
        }
    }
}

typealias XcodeProjectModelObject = [String: AnyCodable]
struct XcodeProjectModel: Codable {
    let archiveVersion: String
    let classes: AnyCodable
    let objectVersion: String
    let objects: [String: XcodeProjectModelObject]

    func findObjectWithType(_ type: String) -> [String: XcodeProjectModelObject] {
        var matchingObjects: [String: XcodeProjectModelObject] = [:]
        for entry in objects {
            if entry.value.isa == type {
                matchingObjects[entry.key] = entry.value
            }
        }
        return matchingObjects
    }
}

extension XcodeProjectModelObject {
    var isa: String {
        self["isa"]?.value as! String
    }

    var name: String? {
        self["name"]?.value as? String
    }

    var productName: String? {
        self["productName"]?.value as? String
    }

    var productReference: String? {
        self["productReference"]?.value as? String
    }

    var path: String? {
        self["path"]?.value as? String
    }

    var productInstallPath: String? {
        self["productInstallPath"]?.value as? String
    }

    var buildSettings: [String: AnyCodable]? {
        self["buildSettings"]?.value as? [String: AnyCodable]
    }

    var defaultConfigurationName: String? {
        self["defaultConfigurationName"]?.value as? String
    }

    var buildConfigurations: [String]? {
        self["buildConfigurations"]?.value as? [String]
    }
}
