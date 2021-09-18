// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Symbolicator",
    platforms: [
        .iOS(.v14),
        .macOS(.v11)
    ],
    products: [
        .library(
            name: "Symbolicator",
            targets: ["Symbolicator"]),
    ],
    dependencies: [
        .package(url: "https://github.com/naru-jpn/CallStackSymbols", from: "1.0.2"),
    ],
    targets: [
        .target(
            name: "Symbolicator",
            dependencies: ["CallStackSymbols"]),
        .testTarget(
            name: "SymbolicatorTests",
            dependencies: ["Symbolicator"]),
    ]
)
