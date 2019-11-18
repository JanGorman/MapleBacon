// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "MapleBacon",
  platforms: [
    .iOS(.v10)
  ],
  products: [
    .library(name: "MapleBacon",
             targets: ["MapleBacon"])
  ],
  dependencies: [
    .package(url: "https://github.com/Quick/Nimble.git", .upToNextMajor(from: "8.0.1")),
  ],
  targets: [
    .target(name: "MapleBacon",
            path: "MapleBacon"),
    .testTarget(name: "MapleBaconTests",
                dependencies: ["MapleBacon", "Nimble"],
                path: "MapleBaconTests")
  ]
)
