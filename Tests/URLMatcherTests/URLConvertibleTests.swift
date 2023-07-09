import Foundation
import XCTest

import URLMatcher

final class URLConvertibleTests: XCTestCase {

  // MARK: URL

  func test_urlValue_returns_an_URL_instance() {
    // given
    let url = URL(string: "https://xoul.kr")!

    // then
    XCTAssertEqual(url.urlValue, url)
    XCTAssertEqual(url.absoluteString.urlValue, url)
  }

  func test_urlValue_returns_an_URL_instance_from_unicode_string() {
    // given
    let urlString = "https://xoul.kr/한글"

    // then
    XCTAssertEqual(urlString.urlValue, URL(string: "https://xoul.kr/%ED%95%9C%EA%B8%80")!)
  }

  func test_urlStringValue_returns_a_URL_string_value() {
    // given
    let url = URL(string: "https://xoul.kr")!

    // then
    XCTAssertEqual(url.urlStringValue, url.absoluteString)
    XCTAssertEqual(url.absoluteString.urlStringValue, url.absoluteString)
  }


  // MARK: Query Parameters

  func test_queryParameters_when_there_is_no_query_string_return_empty_dict() {
    // given
    let url = "https://xoul.kr"

    // then
    XCTAssertEqual(url.urlValue?.queryParameters, [:])
    XCTAssertEqual(url.urlStringValue.queryParameters, [:])
  }

  func test_queryParameters_when_there_is_an_empty_query_string_returns_empty_dict() {
    // given
    let url = "https://xoul.kr?"

    // then
    XCTAssertEqual(url.urlValue?.queryParameters, [:])
    XCTAssertEqual(url.urlStringValue.queryParameters, [:])
  }

  func test_queryParameters_when_there_is_a_query_string() {
    // given
    let url = "https://xoul.kr?key=this%20is%20a%20value&greeting=hello+world!&int=12&int=34&url=https://foo/bar?hello=world"

    // then
    /// has proper keys
    XCTAssertEqual(Set(url.urlValue!.queryParameters.keys), ["key", "greeting", "int", "url"])
    XCTAssertEqual(Set(url.urlStringValue.queryParameters.keys), ["key", "greeting", "int", "url"])

    /// decodes a percent encoding
    XCTAssertEqual(url.urlValue?.queryParameters["key"], "this is a value")
    XCTAssertEqual(url.urlStringValue.queryParameters["key"], "this is a value")

    /// doesn't convert + to whitespace
    XCTAssertEqual(url.urlValue?.queryParameters["greeting"], "hello+world!")
    XCTAssertEqual(url.urlStringValue.queryParameters["greeting"], "hello+world!")

    /// takes last value from duplicated keys
    XCTAssertEqual(url.urlValue?.queryParameters["int"], "34")
    XCTAssertEqual(url.urlStringValue.queryParameters["int"], "34")

    /// has an url
    XCTAssertEqual(url.urlValue?.queryParameters["url"], "https://foo/bar?hello=world")
  }

  // MARK: Query Items

  func test_queryItems_when_there_is_no_query_string_returns_nil() {
    // given
    let url = "https://xoul.kr"

    // then
    XCTAssertNil(url.urlValue?.queryItems)
    XCTAssertNil(url.urlStringValue.queryItems)
  }

  func test_queryItems_when_there_is_an_empty_query_string_returns_an_empty_array() {
    // given
    let url = "https://xoul.kr?"

    // then
    XCTAssertEqual(url.urlValue?.queryItems, [])
    XCTAssertEqual(url.urlStringValue.queryItems, [])
  }

  func test_queryItems_when_there_is_a_query_string() {
    // given
    let url = "https://xoul.kr?key=this%20is%20a%20value&greeting=hello+world!&int=12&int=34"

    // then
    /// has exact number of items
    XCTAssertEqual(url.urlValue?.queryItems?.count, 4)
    XCTAssertEqual(url.urlStringValue.queryItems?.count, 4)

    /// decodes a percent encoding
    XCTAssertEqual(url.urlValue?.queryItems?[0], URLQueryItem(name: "key", value: "this is a value"))
    XCTAssertEqual(url.urlStringValue.queryItems?[0], URLQueryItem(name: "key", value: "this is a value"))

    /// doesn't convert + to whitespace
    XCTAssertEqual(url.urlValue?.queryItems?[1], URLQueryItem(name: "greeting", value: "hello+world!"))
    XCTAssertEqual(url.urlStringValue.queryItems?[1], URLQueryItem(name: "greeting", value: "hello+world!"))

    /// takes all duplicated keys
    XCTAssertEqual(url.urlValue?.queryItems?[2], URLQueryItem(name: "int", value: "12"))
    XCTAssertEqual(url.urlValue?.queryItems?[3], URLQueryItem(name: "int", value: "34"))
    XCTAssertEqual(url.urlStringValue.queryItems?[2], URLQueryItem(name: "int", value: "12"))
    XCTAssertEqual(url.urlStringValue.queryItems?[3], URLQueryItem(name: "int", value: "34"))
  }
}
