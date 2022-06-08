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
  dependencies: [
    .package(url: "https://github.com/Quick/Quick.git", .upToNextMajor(from: "5.0.0")),
    .package(url: "https://github.com/Quick/Nimble.git", .upToNextMajor(from: "10.0.0")),
  ],
  targets: [
    .target(name: "URLMatcher"),
    .target(name: "URLNavigator", dependencies: ["URLMatcher"]),
    .testTarget(name: "URLMatcherTests", dependencies: ["URLMatcher", "Quick", "Nimble"]),
    .testTarget(name: "URLNavigatorTests", dependencies: ["URLNavigator", "Quick", "Nimble"]),
  ]
)
