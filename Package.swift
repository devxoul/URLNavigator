// swift-tools-version:5.4

import PackageDescription

let package = Package(
  name: "URLNavigator",
  platforms: [
    .iOS(.v9), .tvOS(.v9),
  ],
  products: [
    .library(name: "URLMatcher", targets: ["URLMatcher"]),
    .library(name: "URLNavigator", targets: ["URLNavigator"]),
  ],
  targets: [
    .target(name: "URLMatcher"),
    .target(name: "URLNavigator", dependencies: ["URLMatcher"]),
    .testTarget(name: "URLMatcherTests", dependencies: ["URLMatcher"]),
    .testTarget(name: "URLNavigatorTests", dependencies: ["URLNavigator"]),
  ]
)
