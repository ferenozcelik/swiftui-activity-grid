// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "SwiftUIActivityGrid",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v16),
        .macOS(.v13),
        .visionOS(.v1),
        .watchOS(.v9),
    ],
    products: [
        .library(
            name: "SwiftUIActivityGrid",
            targets: ["SwiftUIActivityGrid"]
        ),
    ],
    targets: [
        .target(
            name: "SwiftUIActivityGrid",
            resources: [
                .process("Resources/Localizable.xcstrings"),
                .copy("Resources/PrivacyInfo.xcprivacy"),
            ]
        ),
        .testTarget(
            name: "SwiftUIActivityGridTests",
            dependencies: ["SwiftUIActivityGrid"]
        ),
    ],
    swiftLanguageModes: [.v6]
)
