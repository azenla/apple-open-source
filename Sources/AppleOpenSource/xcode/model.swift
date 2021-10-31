//
//  model.swift
//
//
//  Created by Kenneth Endfinger on 1/2/21.
//

import AnyCodable
import Foundation

typealias XcodeProjectModelObject = [String: AnyCodable]

struct XcodeProjectModel: Codable {
    let archiveVersion: String
    let classes: AnyCodable
    let objectVersion: String
    let objects: [String: XcodeProjectModelObject]

    func findObjectWithType(_ type: String) -> [String: XcodeProjectModelObject] {
        var matchingObjects: [String: XcodeProjectModelObject] = [:]
        for entry in objects where entry.value.isa == type {
            matchingObjects[entry.key] = entry.value
        }
        return matchingObjects
    }

    func mapReferenceArray(_ array: [String]?) -> [String: XcodeProjectModelObject] {
        var references: [String: XcodeProjectModelObject] = [:]
        if array != nil {
            for item in array! {
                references[item] = objects[item]
            }
        }
        return references
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

    var buildSettings: [String: Any]? {
        self["buildSettings"]?.value as? [String: Any]
    }

    var defaultConfigurationName: String? {
        self["defaultConfigurationName"]?.value as? String
    }

    var buildConfigurations: [String]? {
        self["buildConfigurations"]?.value as? [String]
    }

    var buildConfigurationList: String? {
        self["buildConfigurationList"]?.value as? String
    }
}
