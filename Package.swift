// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "AudioVisualizer",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "Audio Visualizer",
            targets: ["Audio Visualizer"]),
    ],
    targets: [
        .target(
            name: "Audio Visualizer"),
    ]
)
