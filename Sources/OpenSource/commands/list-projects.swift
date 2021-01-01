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

    func run() throws {
        let lowerProductName = product.lowercased()
        let smooshedReleaseName = release.replacingOccurrences(of: ".", with: "")
        let moniker = "\(lowerProductName)-\(smooshedReleaseName)"
        let url = URL(string: "https://opensource.apple.com/plist/\(moniker).plist")!
        let data = try Data(contentsOf: url)
        var format = PropertyListSerialization.PropertyListFormat.xml
        let plist = try PropertyListSerialization.propertyList(from: data, options: .mutableContainersAndLeaves, format: &format) as! [String:AnyObject]
        
        print(plist.keys)
    }
}
