// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "NVCuriositiesSignalKit",
    platforms: [
        .iOS(.v16),
        .macOS(.v10_15)
    ],
    products: [
        .library(
            name: "NVCuriositiesSignalKit",
            targets: ["NVCuriositiesSignalKit"]
        )
    ],
    targets: [
        .target(name: "NVCuriositiesSignalKit")
    ]
)
