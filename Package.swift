// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "MapleBacon",
  platforms: [
    .iOS(.v12)
  ],
  products: [
    .library(name: "MapleBacon", targets: ["MapleBacon"]),
  ],
  targets: [
    .target(name: "MapleBacon", path: "MapleBacon"),
  ]
)
