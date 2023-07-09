import XCTest

@testable import URLMatcher

final class URLMatcherInternalTests: XCTestCase {

  private var matcher: URLMatcher!

  override func setUp() {
    super.setUp()

    matcher = URLMatcher()
  }


  // MARK: normalizeURL

  func test_normalizeURL_does_not_change_anything_if_there_is_nothing_to_normalize() {
    XCTAssertEqual(matcher.normalizeURL("myapp://user/<id>/hello").urlStringValue, "myapp://user/<id>/hello")
    XCTAssertEqual(matcher.normalizeURL("https://<path:_>").urlStringValue, "https://<path:_>")
    XCTAssertEqual(matcher.normalizeURL("https://").urlStringValue, "https://")
  }

  func test_normalizeURL_removes_redundant_slashes_and_query_parameters_and_hashbangs() {
    // given
    let dirtyURL = "myapp:///////user///<id>//hello/??/#abc=/def"

    // then
    XCTAssertEqual(matcher.normalizeURL(dirtyURL).urlStringValue, "myapp://user/<id>/hello")
  }


  // MARK: pathComponents

  func test_pathComponents_returns_proper_path_components() {
    // given
    let components = matcher.pathComponents(from: "myapp://foo/bar/<name>/<int:id>")

    // then
    XCTAssertEqual(
      components,
      [
        .plain("foo"),
        .plain("bar"),
        .placeholder(type: nil, key: "name"),
        .placeholder(type: "int", key: "id"),
      ]
    )
  }


  // MARK: replaceRegex

  func test_replaceRegex_replaces_regular_expression() {
    XCTAssertEqual(matcher.replaceRegex("a", "0", "abc"), "0bc")
    XCTAssertEqual(matcher.replaceRegex("\\d", "A", "1234567abc098"), "AAAAAAAabcAAA")
  }
}
