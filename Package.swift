// swift-tools-version: 5.6
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "MediaPicker",
    platforms: [
        .iOS(.v15),
        .macOS(.v11)
    ],
    products: [
        .library(
            name: "MediaPicker",
            targets: ["MediaPicker"]),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "MediaPicker",
            dependencies: []
        ),
        .testTarget(
            name: "MediaPickerTests",
            dependencies: ["MediaPicker"]),
    ]
)
