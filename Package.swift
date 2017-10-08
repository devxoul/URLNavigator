// swift-tools-version:4.0

import PackageDescription

let package = Package(
  name: "URLNavigator",
  products: [
    .library(name: "URLMatcher", targets: ["URLMatcher"]),
  ],
  dependencies: [
    .package(url: "https://github.com/Quick/Quick.git", .upToNextMajor(from: "1.2.0")),
    .package(url: "https://github.com/Quick/Nimble.git", .upToNextMajor(from: "7.0.2")),
  ],
  targets: [
    .target(name: "URLMatcher"),
    .testTarget(name: "URLMatcherTests", dependencies: ["URLMatcher", "Quick", "Nimble"]),
  ]
)
