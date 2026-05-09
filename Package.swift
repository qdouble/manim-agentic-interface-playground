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
        // W1 scaffold dependency. W3/final closeout updates this to the proved
        // MAI v0.2 remote tag after setup/render proof exists.
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
            ]
        ),
        .testTarget(
            name: "SetupShellLockTests",
            dependencies: []
        ),
    ],
    swiftLanguageModes: [.v6]
)
