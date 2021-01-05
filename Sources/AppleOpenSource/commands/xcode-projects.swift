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
                    try analyzeXcodeModelForInstallableArtifacts(xcodeProjectPath, model!)
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

    func analyzeXcodeModelForInstallableArtifacts(_ path: String, _ model: XcodeProjectModel) throws {
        let targets = model.findObjectWithType("PBXNativeTarget")

        for entry in targets {
            let nativeTarget = entry.value
            let productReference = model.objects[nativeTarget.productReference ?? "__NONE__"]
            let productReferencePath = productReference?.path
            var installPath = nativeTarget.productInstallPath

            var buildConfigurationSet: [String]?

            if nativeTarget.buildConfigurations != nil {
                buildConfigurationSet = nativeTarget.buildConfigurations
            }

            if buildConfigurationSet == nil {
                if let buildConfigurationListRef = nativeTarget.buildConfigurationList {
                    buildConfigurationSet = model.objects[buildConfigurationListRef]?.buildConfigurations
                }
            }

            let buildConfigurations = model.mapReferenceArray(buildConfigurationSet)

            let buildConfiguration: XcodeProjectModelObject? = buildConfigurations.values.first {
                if let n = $0.name {
                    return n == "Release"
                } else {
                    return false
                }
            }

            if buildConfiguration != nil {
                let buildSettings = buildConfiguration?.buildSettings
                if let buildSettings = buildSettings {
                    installPath = buildSettings["INSTALL_PATH"] as? String
                }
            }

            if installPath == nil {
                continue
            }

            let jsonInfo: [String: String?] = [
                "project": path,
                "targetName": nativeTarget.name,
                "productName": nativeTarget.productName,
                "installDirectoryPath": installPath,
                "installFileName": productReferencePath
            ]

            let jsonEncoder = JSONEncoder()
            jsonEncoder.outputFormatting = [
                .sortedKeys,
                .withoutEscapingSlashes
            ]

            print(try jsonEncoder.encode(jsonInfo).string())
        }
    }
}
