// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "EasyNav",
    platforms: [
        .iOS(.v16)
    ],
    products: [
        .library(
            name: "EasyNav",
            targets: ["EasyNav"]
        )
    ],
    dependencies: [
        .package(
            url: "https://github.com/realm/SwiftLint.git",
            from: "0.62.0"
        )
    ],
    targets: [
        .target(
            name: "EasyNav",
            dependencies: [],
            path: "Sources/EasyNav",
            plugins: [
                .plugin(name: "SwiftLintBuildToolPlugin", package: "SwiftLint")
            ]
        ),
        .testTarget(
            name: "EasyNavTests",
            dependencies: ["EasyNav"],
            path: "Tests/EasyNavTests",
            plugins: [
                .plugin(name: "SwiftLintBuildToolPlugin", package: "SwiftLint")
            ]
        ),

    ],
    swiftLanguageVersions: [.v5]
)
