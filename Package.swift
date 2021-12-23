// swift-tools-version:5.4
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "TestCleaner",
    platforms: [.iOS(.v12), .tvOS(.v12), .watchOS(.v5), .macOS(.v10_14)],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "TestCleaner",
            targets: ["TestCleaner"]),
    ],
    dependencies: [
    ],
    targets: [
        .target(
            name: "TestCleaner",
            dependencies: []),
    ]
)
