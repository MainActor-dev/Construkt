// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "Construkt",
    platforms: [.iOS(.v16)],
    products: [
        .library(name: "Construkt", targets: ["Construkt"]),
    ],
    targets: [
        .target(name: "Construkt"),
        .testTarget(
            name: "ConstruktTests",
            dependencies: ["Construkt"]
        ),
    ]
)
