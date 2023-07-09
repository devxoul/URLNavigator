import XCTest

@testable import URLMatcher

final class URLPathComponentTests: XCTestCase {

  func test_init_plain() {
    XCTAssertEqual(URLPathComponent("foo"), URLPathComponent.plain("foo"))
  }

  func test_init_placeholder_with_untyped_placeholder_string() {
    XCTAssertEqual(URLPathComponent("<name>"), URLPathComponent.placeholder(type: nil, key: "name"))
  }

  func test_init_placeholder_for_typed_placeholder_string() {
    XCTAssertEqual(URLPathComponent("<int:id>"), URLPathComponent.placeholder(type: "int", key: "id"))
  }

  func test_plain_equatable() {
    XCTAssertEqual(URLPathComponent.plain("foo"), URLPathComponent.plain("foo"))
    XCTAssertNotEqual(URLPathComponent.plain("foo"), URLPathComponent.plain("bar"))
  }

  func test_placeholder_equatable() {
    XCTAssertEqual(
      URLPathComponent.placeholder(type: "int", key: "id"),
      URLPathComponent.placeholder(type: "int", key: "id")
    )
    XCTAssertNotEqual(
      URLPathComponent.placeholder(type: "int", key: "id"),
      URLPathComponent.placeholder(type: "string", key: "id")
    )
    XCTAssertNotEqual(
      URLPathComponent.placeholder(type: "int", key: "id"),
      URLPathComponent.placeholder(type: "int", key: "name")
    )
    XCTAssertNotEqual(
      URLPathComponent.placeholder(type: "int", key: "id"),
      URLPathComponent.placeholder(type: "string", key: "name")
    )

    XCTAssertNotEqual(URLPathComponent.plain("id"), URLPathComponent.placeholder(type: "int", key: "id"))
  }
}
