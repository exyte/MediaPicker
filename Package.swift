// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ExyteMediaPicker",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "ExyteMediaPicker",
            targets: ["ExyteMediaPicker"]),
    ],
    dependencies: [
        .package(
            url: "https://github.com/exyte/AnchoredPopup.git",
            from: "1.0.0"
        )
    ],
    targets: [
        .target(
            name: "ExyteMediaPicker",
            dependencies: [
                .product(name: "AnchoredPopup", package: "AnchoredPopup")
            ]
        ),
        .testTarget(
            name: "MediaPickerTests",
            dependencies: ["ExyteMediaPicker"]),
    ]
)
