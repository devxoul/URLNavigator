//
//  URLMatcherInternalTests.swift
//  URLNavigator
//
//
//  Created by Sklar, Josh on 9/2/16.
//  Copyright (c) 2016 Suyeol Jeon (xoul.kr)
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE

import XCTest
@testable import URLNavigator

class SSN {
  let ssnString: String

  init(ssnString: String) {
    self.ssnString = ssnString
  }
}

class URLMatcherInternalTests: XCTestCase {

  var matcher: URLMatcher!

  override func setUp() {
    super.setUp()
    self.matcher = URLMatcher()
  }

  func testURLWithScheme() {
    XCTAssertEqual(matcher.url(withScheme: nil, "myapp://user/1").urlStringValue, "myapp://user/1")
    XCTAssertEqual(matcher.url(withScheme: "myapp", "/user/1").urlStringValue, "myapp://user/1")
    XCTAssertEqual(matcher.url(withScheme: "", "/user/1").urlStringValue, "://user/1") // idiot
  }

  func testNormalizedURL() {
    XCTAssertEqual(matcher.normalized("myapp://user/<id>/hello").urlStringValue, "myapp://user/<id>/hello")
    XCTAssertEqual(matcher.normalized("myapp:///////user///<id>//hello/??/#abc=/def").urlStringValue,
                   "myapp://user/<id>/hello")
    XCTAssertEqual(matcher.normalized("https://<path:_>").urlStringValue, "https://<path:_>")
    XCTAssertEqual(matcher.normalized("https://").urlStringValue, "https://")
  }

  func testPlaceholderValueFromURLPathComponents() {
    {
      let placeholder = matcher.placeholderKeyValueFrom(
        urlPatternPathComponent: "<id>",
        urlPathComponents: ["123", "456"],
        atIndex: 0
      )
      XCTAssertEqual(placeholder?.0, "id")
      XCTAssertEqual(placeholder?.1 as? String, "123")
    }();
    {
      let placeholder = matcher.placeholderKeyValueFrom(
        urlPatternPathComponent: "<string:id>",
        urlPathComponents: ["123", "456"],
        atIndex: 0
      )
      XCTAssertEqual(placeholder?.0, "id")
      XCTAssertEqual(placeholder?.1 as? String, "123")
    }();
    {
      let placeholder = matcher.placeholderKeyValueFrom(
        urlPatternPathComponent: "<UUID:uuid>",
        urlPathComponents: ["123e4567-e89b-12d3-a456-426655440000"],
        atIndex: 0
      )
      XCTAssertEqual(placeholder?.0, "uuid")
      XCTAssertEqual(placeholder?.1 as? UUID, UUID(uuidString: "123e4567-e89b-12d3-a456-426655440000"))
    }();
    {
      let placeholder = matcher.placeholderKeyValueFrom(
        urlPatternPathComponent: "<int:id>",
        urlPathComponents: ["123", "456"],
        atIndex: 0
      )
      XCTAssertEqual(placeholder?.0, "id")
      XCTAssertEqual(placeholder?.1 as? Int, 123)
    }();
    {
      let placeholder = matcher.placeholderKeyValueFrom(
        urlPatternPathComponent: "<int:id>",
        urlPathComponents: ["abc", "456"],
        atIndex: 0
      )
      XCTAssertNil(placeholder)
    }();
    {
      let placeholder = matcher.placeholderKeyValueFrom(
        urlPatternPathComponent: "<float:height>",
        urlPathComponents: ["180", "456"],
        atIndex: 0
      )
      XCTAssertEqual(placeholder?.0, "height")
      XCTAssertEqual(placeholder?.1 as? Float, 180)
    }();
    {
      let placeholder = matcher.placeholderKeyValueFrom(
        urlPatternPathComponent: "<float:height>",
        urlPathComponents: ["abc", "456"],
        atIndex: 0
      )
      XCTAssertNil(placeholder)
    }();
    {
      let placeholder = matcher.placeholderKeyValueFrom(
        urlPatternPathComponent: "<url>",
        urlPathComponents: ["xoul.kr"],
        atIndex: 0
      )
      XCTAssertEqual(placeholder?.0, "url")
      XCTAssertEqual(placeholder?.1 as? String, "xoul.kr")
    }();
    {
      let placeholder = matcher.placeholderKeyValueFrom(
        urlPatternPathComponent: "<url>",
        urlPathComponents: ["xoul.kr", "resume"],
        atIndex: 0
      )
      XCTAssertEqual(placeholder?.0, "url")
      XCTAssertEqual(placeholder?.1 as? String, "xoul.kr")
    }();
    {
      let placeholder = matcher.placeholderKeyValueFrom(
        urlPatternPathComponent: "<path:url>",
        urlPathComponents: ["xoul.kr"],
        atIndex: 0
      )
      XCTAssertEqual(placeholder?.0, "url")
      XCTAssertEqual(placeholder?.1 as? String, "xoul.kr")
    }();
    {
      let placeholder = matcher.placeholderKeyValueFrom(
        urlPatternPathComponent: "<path:url>",
        urlPathComponents: ["xoul.kr", "resume"],
        atIndex: 0
      )
      XCTAssertEqual(placeholder?.0, "url")
      XCTAssertEqual(placeholder?.1 as? String, "xoul.kr/resume")
    }();
    {
      let placeholder = matcher.placeholderKeyValueFrom(
        urlPatternPathComponent: "<path:url>",
        urlPathComponents: ["google.com", "search?q=test"],
        atIndex: 0
      )
      XCTAssertEqual(placeholder?.0, "url")
      XCTAssertEqual(placeholder?.1 as? String, "google.com/search?q=test")
    }();
    {
      let placeholder = matcher.placeholderKeyValueFrom(
        urlPatternPathComponent: "<path:url>",
        urlPathComponents: ["google.com", "search", "?q=test"],
        atIndex: 0
      )
      XCTAssertEqual(placeholder?.0, "url")
      XCTAssertEqual(placeholder?.1 as? String, "google.com/search/?q=test")
    }();
    {
      matcher.addURLValueMatcherHandler(for: "SSN") { ssnString in
        return SSN(ssnString: ssnString)
      }

      let placeholder = matcher.placeholderKeyValueFrom(
        urlPatternPathComponent: "<SSN:ssn>",
        urlPathComponents: ["123-45-6789"],
        atIndex: 0
      )
      XCTAssertEqual(placeholder?.0, "ssn")
      XCTAssertEqual((placeholder?.1 as? SSN)?.ssnString, "123-45-6789")
    }();
  }

  func testReplaceRegex() {
    XCTAssertEqual(matcher.replaceRegex("a", "0", "abc"), "0bc")
    XCTAssertEqual(matcher.replaceRegex("\\d", "A", "1234567abc098"), "AAAAAAAabcAAA")
  }
}
