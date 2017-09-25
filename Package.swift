// swift-tools-version:4.0

import PackageDescription

let package = Package(
  name: "URLNavigator",
  products: [
    .library(name: "URLNavigator", targets: ["URLNavigator"]),
  ],
  targets: [
    .target(name: "URLNavigator"),
    .testTarget(name: "URLNavigatorTests", dependencies: ["URLNavigator"]),
  ]
)
