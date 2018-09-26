// swift-tools-version:4.2

import PackageDescription

let package = Package(
  name: "URLNavigator",
  products: [
    .library(name: "URLMatcher", targets: ["URLMatcher"]),
    .library(name: "URLNavigator", targets: ["URLNavigator"]),
  ],
  dependencies: [
    .package(url: "https://github.com/Quick/Quick.git", .upToNextMajor(from: "1.2.0")),
    .package(url: "https://github.com/Quick/Nimble.git", .upToNextMajor(from: "7.0.2")),
    .package(url: "https://github.com/devxoul/Stubber.git", .upToNextMajor(from: "1.0.0")),
  ],
  targets: [
    .target(name: "URLMatcher"),
    .target(name: "URLNavigator", dependencies: ["URLMatcher"]),
    .testTarget(name: "URLMatcherTests", dependencies: ["URLMatcher", "Quick", "Nimble"]),
    .testTarget(name: "URLNavigatorTests", dependencies: ["URLNavigator", "Quick", "Nimble", "Stubber"]),
  ]
)
