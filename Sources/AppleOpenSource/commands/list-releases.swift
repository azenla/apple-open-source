//
//  list-releases.swift
//
//
//  Created by Kenneth Endfinger on 12/31/20.
//

import ArgumentParser
import Foundation
import SwiftSoup

struct ListReleasesTool: ParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "list-releases",
        abstract: "List Available Product Releases"
    )

    @Option(name: .shortAndLong, help: "Filter by Product")
    var product: String?

    @Option(name: .shortAndLong, help: "Limit Releases for each Product")
    var limit: Int = 10

    func run() throws {
        let homeSourceData = try Data(contentsOf: openSourceHomeUrl)
        let homeSourceString = String(data: homeSourceData, encoding: .utf8)!
        let document = try SwiftSoup.parse(homeSourceString)
        let releaseListElements = try document.select(".release-list")

        for releaseListElement in releaseListElements {
            let productName = try releaseListElement.select(".product-name").first()!.text()

            if product != nil,
               productName.lowercased() != product!.lowercased() {
                continue
            }

            print("* \(productName)")
            let releaseListButtons = try releaseListElement.select(".release-list-button")

            var index = 0
            for releaseListButton in releaseListButtons {
                let releaseListButtonSpan = try releaseListButton.select("span").first()!
                let superReleaseName = try releaseListButtonSpan.text()
                let actualSuperReleaseName = String(superReleaseName.split(separator: "/")[0])
                guard let actualListElement = try releaseListElement.getElementById("release-list-\(productName)-\(actualSuperReleaseName)") else {
                    continue
                }
                for actualReleaseElement in try actualListElement.select("a") {
                    let actualReleaseName = try actualReleaseElement.text()
                    print("  * \(actualReleaseName)")
                    index += 1

                    if index == limit {
                        break
                    }
                }
            }
        }
    }
}
