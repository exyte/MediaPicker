// swift-tools-version: 5.6
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ExyteMediaPicker",
    platforms: [
        .iOS(.v15),
        .macOS(.v11)
    ],
    products: [
        .library(
            name: "ExyteMediaPicker",
            targets: ["ExyteMediaPicker"]),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "ExyteMediaPicker",
            path: "Sources/MediaPicker",
            dependencies: []
        ),
        .testTarget(
            name: "MediaPickerTests",
            dependencies: ["ExyteMediaPicker"]),
    ]
)
