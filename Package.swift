// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "WWWebImage",
    platforms: [
        .iOS(.v16)
    ],
    products: [
        .library(name: "WWWebImage", targets: ["WWWebImage"]),
    ],
    dependencies: [
        .package(url: "https://github.com/William-Weng/WWCacheManager", .upToNextMinor(from: "1.1.0"))
    ],
    targets: [
        .target(name: "WWWebImage",
                dependencies: [
                    .product(name: "WWCacheManager", package: "WWCacheManager")
                ],
                resources: [.copy("Privacy")]),
    ],
    swiftLanguageVersions: [
        .v5
    ]
)
