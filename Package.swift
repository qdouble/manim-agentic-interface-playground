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
        // MAI dependency on main branch. Update to a tagged release
        // (e.g., from: "0.3.0") once the next stable release is cut.
        .package(
            url: "https://github.com/qdouble/Manim-Agentic-Interface.git",
            branch: "main"
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
