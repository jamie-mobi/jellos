// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "JellyKit",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v26),
        .macOS(.v26),
        .tvOS(.v26)
    ],
    products: [
        .library(name: "JellyAccessibility", targets: ["JellyAccessibility"]),
        .library(name: "JellyComposition", targets: ["JellyComposition"]),
        .library(name: "JellyPresentation", targets: ["JellyPresentation"]),
        .library(name: "JellyPresentationTV", targets: ["JellyPresentationTV"])
    ],
    targets: [
        .target(name: "JellyDomain"),
        .target(name: "JellyAccessibility"),
        .target(name: "JellyData", dependencies: ["JellyDomain"]),
        .target(name: "JellyServices", dependencies: ["JellyDomain", "JellyData"]),
        .target(name: "JellyPlayback", dependencies: ["JellyDomain", "JellyData"]),
        .target(name: "JellyMocks", dependencies: ["JellyDomain", "JellyData", "JellyServices"]),
        .target(
            name: "JellyComposition",
            dependencies: ["JellyDomain", "JellyData", "JellyServices", "JellyPlayback", "JellyMocks"]
        ),
        .target(
            name: "JellyPresentationCore",
            dependencies: ["JellyDomain", "JellyServices", "JellyAccessibility", "JellyComposition", "JellyMocks"]
        ),
        .target(
            name: "JellyPresentation",
            dependencies: ["JellyDomain", "JellyServices", "JellyAccessibility", "JellyPresentationCore", "JellyMocks"],
            resources: [.process("Resources")]
        ),
        .target(
            name: "JellyPresentationTV",
            dependencies: ["JellyDomain", "JellyServices", "JellyAccessibility", "JellyPresentationCore", "JellyMocks"]
        ),
        .testTarget(name: "JellyDomainTests", dependencies: ["JellyDomain"]),
        .testTarget(name: "JellyDataTests", dependencies: ["JellyDomain", "JellyData"]),
        .testTarget(name: "JellyServicesTests", dependencies: ["JellyDomain", "JellyData", "JellyServices"]),
        .testTarget(name: "JellyIntegrationTests", dependencies: ["JellyDomain", "JellyData"])
    ]
)
