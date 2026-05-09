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
        // Pre-release dependency for v0.2 patch proof. Final closeout updates
        // this to the proved MAI v0.2 remote tag.
        .package(
            url: "https://github.com/qdouble/Manim-Agentic-Interface.git",
            branch: "codex/tts-mai-v0.2-patch"
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
