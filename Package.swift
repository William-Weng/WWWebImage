// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "WWWebImage",
    platforms: [
        .iOS(.v12)
    ],
    products: [
        .library(name: "WWWebImage", targets: ["WWWebImage"]),
    ],
    dependencies: [
        .package(name: "WWNetworking", url: "https://github.com/William-Weng/WWNetworking.git", from: "1.1.0"),
    ],
    targets: [
        .target(name: "WWWebImage", dependencies: ["WWNetworking"]),
        .testTarget(name: "WWWebImageTests", dependencies: ["WWWebImage"]),
    ],
    swiftLanguageVersions: [
        .v5
    ]
)
