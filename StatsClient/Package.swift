// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "StatsClient",
    platforms: [.macOS(.v14)],
    products: [
        .library(
              name: "StatsClient",
              targets: ["StatsClient"]),
            .library(
              name: "StatsClientLive",
              targets: ["StatsClientLive"]),
    ],
    targets: [
        .target(name: "StatsClient"),
        .target(name: "StatsClientLive", dependencies: ["StatsClient"]),
        .testTarget(name: "StatsClientTests", dependencies: ["StatsClient", "StatsClientLive"]),
    ]
)
