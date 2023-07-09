// swift-tools-version: 5.7.1

import PackageDescription

let package = Package(
  name: "URLNavigator",
  platforms: [
    .iOS(.v11), .tvOS(.v11),
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
