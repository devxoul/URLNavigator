// swift-tools-version:5.0

import PackageDescription

let package = Package(
  name: "URLNavigator",
  platforms: [
    .iOS(.v8), .tvOS(.v9),
  ],
  products: [
    .library(name: "URLMatcher", targets: ["URLMatcher"]),
    .library(name: "URLNavigator", targets: ["URLNavigator"]),
  ],
  dependencies: [
    .package(url: "https://github.com/devxoul/Quick.git", .branch("swift-5")),
    .package(url: "https://github.com/devxoul/Nimble.git", .branch("swift-5")),
    .package(url: "https://github.com/devxoul/Stubber.git", .upToNextMajor(from: "1.4.0")),
  ],
  targets: [
    .target(name: "URLMatcher"),
    .target(name: "URLNavigator", dependencies: ["URLMatcher"]),
    .testTarget(name: "URLMatcherTests", dependencies: ["URLMatcher", "Quick", "Nimble"]),
    .testTarget(name: "URLNavigatorTests", dependencies: ["URLNavigator", "Quick", "Nimble", "Stubber"]),
  ]
)
