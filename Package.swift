// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "AppleOpenSource",
    platforms: [
        .macOS("10.15.4")
    ],
    products: [
        .executable(
            name: "apple-open-source",
            targets: ["AppleOpenSource"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser.git", .upToNextMinor(from: "1.0.1")),
        .package(url: "https://github.com/scinfu/SwiftSoup.git", from: "2.3.3"),
        .package(url: "https://github.com/Flight-School/AnyCodable.git", from: "0.6.2")
    ],
    targets: [
        .target(
            name: "AppleOpenSource",
            dependencies: [
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
                .product(name: "SwiftSoup", package: "SwiftSoup"),
                .product(name: "AnyCodable", package: "AnyCodable")
            ]
        )
    ]
)
