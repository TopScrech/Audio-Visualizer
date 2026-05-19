// swift-tools-version: 6.3.2

import PackageDescription

let package = Package(
    name: "AudioVisualizer",
    products: [
        .library(name: "AudioVisualizer", targets: ["AudioVisualizer"])
    ],
    targets: [
        .target(name: "AudioVisualizer")
    ]
)
