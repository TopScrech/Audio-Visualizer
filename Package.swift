// swift-tools-version: 6.3.3

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
