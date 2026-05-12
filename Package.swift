// swift-tools-version: 6.3

import PackageDescription

let package = Package(
    name: "ManimAgenticInterfacePlayground",
    platforms: [
        .macOS(.v14),
    ],
    products: [
        .executable(
            name: "minimal-scene",
            targets: ["MinimalScene"]
        ),
    ],
    dependencies: [
        // Wave 8 pre-merge MAI dependency proof branch. Return to main or a
        // tagged release after spatial-storyboard-layout merges.
        .package(
            url: "https://github.com/qdouble/Manim-Agentic-Interface.git",
            branch: "codex/spatial-storyboard-layout"
        ),
    ],
    targets: [
        .executableTarget(
            name: "MinimalScene",
            dependencies: [
                .product(name: "ManimAgenticInterface", package: "manim-agentic-interface"),
                .product(name: "ManimAgenticInterfaceTTS", package: "manim-agentic-interface"),
            ]
        ),
        .testTarget(
            name: "SetupShellTests",
            dependencies: []
        ),
    ],
    swiftLanguageModes: [.v6]
)
