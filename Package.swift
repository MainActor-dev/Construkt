// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "Construkt",
    platforms: [.iOS(.v14)],
    products: [
        .library(name: "ConstruktKit", targets: ["ConstruktKit"]),
    ],
    targets: [
        .target(name: "ConstruktKit", path: "Sources/Construkt"),
        .testTarget(
            name: "ConstruktTests",
            dependencies: ["ConstruktKit"]
        ),
    ],
    swiftLanguageVersions: [.v5]
)
