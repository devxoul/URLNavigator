import XCTest

import URLMatcher

final class URLMatcherTests: XCTestCase {
  var matcher: URLMatcher!

  override func setUp() {
    super.setUp()
    matcher = URLMatcher()
  }

  func test_returns_nil_when_there_is_no_candidates() {
    // when
    let result = matcher.match("myapp://user/1", from: [])

    // then
    XCTAssertNil(result)
  }

  func test_returns_nil_for_unmatched_scheme() {
    // when
    let result = matcher.match("myapp://user/1", from: ["yourapp://user/<id>"])

    // then
    XCTAssertNil(result)
  }

  func test_returns_nil_for_totally_unmatched_url() {
    // when
    let result = matcher.match("myapp://user/1", from: ["myapp://comment/<id>"])

    // then
    XCTAssertNil(result)
  }

  func test_returns_nil_for_partially_unmatched_url() {
    // when
    let result = matcher.match("myapp://user/1", from: ["myapp://user/<id>/hello"])

    // then
    XCTAssertNil(result)
  }

  func test_returns_nil_for_an_unmatched_value_type() {
    // when
    let result = matcher.match("myapp://user/devxoul", from: ["myapp://user/<int:id>"])

    // then
    XCTAssertNil(result)
  }

  func test_returns_a_result_for_totally_matching_url() {
    // given
    let candidates = ["myapp://hello/<name>", "myapp://hello/world"]

    // when
    let result = matcher.match("myapp://hello/world", from: candidates)

    // then
    XCTAssertNotNil(result)
    XCTAssertEqual(result?.pattern, "myapp://hello/world")
    XCTAssertEqual(result?.values.count, 0)
  }

  func test_returns_a_result_for_the_longest_matching_url() {
    // given
    let candidates = ["myapp://<path:path>", "myapp://hello/<name>"]

    // when
    let result = matcher.match("myapp://hello/world", from: candidates)

    // then
    XCTAssertNotNil(result)
    XCTAssertEqual(result?.pattern, "myapp://hello/<name>")
    XCTAssertEqual(result?.values.count, 1)
  }

  func test_returns_a_result_with_an_url_value_for_matching_url() {
    // given
    let candidates = ["myapp://user/<id>/hello", "myapp://user/<id>"]

    // when
    let result = matcher.match("myapp://user/1", from: candidates)

    // then
    XCTAssertNotNil(result)
    XCTAssertEqual(result?.pattern, "myapp://user/<id>")
    XCTAssertEqual(result?.values.count, 1)
    XCTAssertEqual(result?.values["id"] as? String, "1")
  }

  func test_returns_a_result_with_an_string_type_url_value_for_matching_url() {
    // given
    let candidates = ["myapp://user/<string:id>"]

    // when
    let result = matcher.match("myapp://user/123", from: candidates)

    // then
    XCTAssertNotNil(result)
    XCTAssertEqual(result?.pattern, "myapp://user/<string:id>")
    XCTAssertEqual(result?.values.count, 1)
    XCTAssertEqual(result?.values["id"] as? String, "123")
  }

  func test_returns_a_result_with_an_int_type_url_value_for_matching_url() {
    // given
    let candidates = ["myapp://user/<int:id>"]

    // when
    let result = matcher.match("myapp://user/123", from: candidates)

    // then
    XCTAssertNotNil(result)
    XCTAssertEqual(result?.pattern, "myapp://user/<int:id>")
    XCTAssertEqual(result?.values.count, 1)
    XCTAssertEqual(result?.values["id"] as? Int, 123)
  }

  func test_returns_a_result_with_a_float_type_url_value_for_matching_url() {
    // given
    let candidates = ["myapp://user/<float:id>"]

    // when
    let result = matcher.match("myapp://user/123.456", from: candidates)

    // then
    XCTAssertNotNil(result)
    XCTAssertEqual(result?.pattern, "myapp://user/<float:id>")
    XCTAssertEqual(result?.values.count, 1)
    XCTAssertEqual(result?.values["id"] as? Float, 123.456)
  }

  func test_returns_a_result_with_a_uuid_type_url_value_for_matching_url() {
    // given
    let candidates = ["myapp://user/<uuid:id>"]
    let uuidString = "621425B8-42D1-4AB4-9A58-1E69D708A84B"

    // when
    let result = matcher.match("myapp://user/\(uuidString)", from: candidates)

    // then
    XCTAssertNotNil(result)
    XCTAssertEqual(result?.pattern, "myapp://user/<uuid:id>")
    XCTAssertEqual(result?.values.count, 1)
    XCTAssertEqual(result?.values["id"] as? UUID, UUID(uuidString: uuidString))
  }

  func test_returns_a_result_with_a_custom_type_url_value_for_matching_url() {
    // given
    matcher.valueConverters["greeting"] = { pathComponents, index in
      return "Hello, \(pathComponents[index])!"
    }
    let candidates = ["myapp://hello/<greeting:name>"]

    // when
    let result = matcher.match("myapp://hello/devxoul" ,from: candidates)

    // then
    XCTAssertNotNil(result)
    XCTAssertEqual(result?.pattern, "myapp://hello/<greeting:name>")
    XCTAssertEqual(result?.values.count, 1)
    XCTAssertEqual(result?.values["name"] as? String, "Hello, devxoul!")
  }

  func test_returns_a_result_with_multiple_url_values_for_matching_url() {
    // given
    let candidates = ["myapp://user/<id>", "myapp://user/<id>/<object>"]

    // when
    let result = matcher.match("myapp://user/1/posts", from: candidates)

    // then
    XCTAssertNotNil(result)
    XCTAssertEqual(result?.pattern, "myapp://user/<id>/<object>")
    XCTAssertEqual(result?.values.count, 2)
    XCTAssertEqual(result?.values["id"] as? String, "1")
    XCTAssertEqual(result?.values["object"] as? String, "posts")
  }

  func test_returns_a_result_with_ignoring_a_query_string() {
    // given
    let candidates = ["myapp://alert"]

    // when
    let result = matcher.match("myapp://alert?title=hello&message=world", from: candidates)

    // then
    XCTAssertNotNil(result)
    XCTAssertEqual(result?.pattern, "myapp://alert")
    XCTAssertEqual(result?.values.count, 0)
  }

  func test_returns_a_result_with_a_path_type_url_value() {
    // given
    let candidates = ["https://<path:url>"]

    // when
    let result = matcher.match("https://google.com/search?q=URLNavigator", from: candidates)

    // then
    XCTAssertNotNil(result)
    XCTAssertEqual(result?.pattern, "https://<path:url>")
    XCTAssertEqual(result?.values["url"] as? String, "google.com/search")
  }

  func test_returns_a_result_with_a_path_url_value_ending_with_trailing_slash() {
    // given
    let candidates = ["https://<path:url>"]

    // when
    let result = matcher.match("https://google.com/search/?q=URLNavigator", from: candidates)

    // then
    XCTAssertNotNil(result)
    XCTAssertEqual(result?.pattern, "https://<path:url>")
    XCTAssertEqual(result?.values["url"] as? String, "google.com/search")
  }

  // (issues-109)
  func test_returns_nil_when_there_is_no_candidates_using_path() {
    // given
    let candidates = ["/anything/<path:url>"]
    let candidates2 = ["http://host/anything/<path:url>"]

    // when
    let result = matcher.match("", from: candidates)
    let result2 = matcher.match("http://host/anything", from: candidates2)

    // then
    XCTAssertNil(result)
    XCTAssertNil(result2)
  }

  // (issues-109)
  func test_returns_same_candidate() {
    // given
    let candidates1 = ["http://host/anything/<path:url>", "http://host/anything"]
    let candidates2 = ["http://host/anything", "http://host/anything/<path:url>"]

    // when
    let result1 = matcher.match("http://host/anything", from: candidates1)
    let result2 = matcher.match("http://host/anything", from: candidates2)

    // then
    XCTAssertEqual(result1?.pattern, result2?.pattern)
  }

  // #123
  func test_returns_nil_when_there_is_another_url_in_the_path() {
    // given
    let candidates = ["myapp://browser/<url>"]

    // when
    let result = matcher.match("myapp://browser/http://google.fr", from: candidates)

    // then
    XCTAssertNil(result)
  }
}
