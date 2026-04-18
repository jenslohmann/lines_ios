// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "Lines",
    platforms: [
        .iOS(.v17),
        .macOS(.v14)
    ],
    targets: [
        .executableTarget(
            name: "Lines",
            path: "Lines"
        ),
        .testTarget(
            name: "LinesTests",
            dependencies: ["Lines"],
            path: "LinesTests"
        )
    ]
)

