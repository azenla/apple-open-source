// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "AppleOpenSource",
    products: [
        .executable(
            name: "apple-open-source",
            targets: ["AppleOpenSource"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser.git", .upToNextMinor(from: "0.3.1")),
        .package(url: "https://github.com/scinfu/SwiftSoup.git", from: "1.7.4")
    ],
    targets: [
        .target(
            name: "AppleOpenSource",
            dependencies: [
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
                .product(name: "SwiftSoup", package: "SwiftSoup")
            ]
        )
    ]
)
