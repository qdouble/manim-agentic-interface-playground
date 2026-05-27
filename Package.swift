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
        // Active MAI development branch. Carries the storyboard
        // visual-quality work (HTML/SVG -> render-storyboard -> Scene
        // Editor chain). Retarget to a tagged release once the branch
        // ships per README "Package dependency".
        .package(
            url: "https://github.com/qdouble/Manim-Agentic-Interface.git",
            branch: "codex/storyboard-visual-quality"
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
