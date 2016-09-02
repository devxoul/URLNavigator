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

class URLMatcherInternalTests: XCTestCase {
    
    var matcher: URLMatcher!
    
    override func setUp() {
        super.setUp()
        self.matcher = URLMatcher()
    }
    
    func testURLWithScheme() {
        XCTAssertEqual(matcher.URLWithScheme(nil, "myapp://user/1").URLStringValue, "myapp://user/1")
        XCTAssertEqual(matcher.URLWithScheme("myapp", "/user/1").URLStringValue, "myapp://user/1")
        XCTAssertEqual(matcher.URLWithScheme("", "/user/1").URLStringValue, "://user/1") // idiot
    }

    func testNormalizedURL() {
        XCTAssertEqual(matcher.normalizedURL("myapp://user/<id>/hello").URLStringValue, "myapp://user/<id>/hello")
        XCTAssertEqual(matcher.normalizedURL("myapp:///////user///<id>//hello/??/#abc=/def").URLStringValue,
                       "myapp://user/<id>/hello")
        XCTAssertEqual(matcher.normalizedURL("https://<path:_>").URLStringValue, "https://<path:_>")
    }
    
    func testPlaceholderValueFromURLPathComponents() {
        {
            let placeholder = matcher.placeholderKeyValueFromURLPatternPathComponent(
                "<id>",
                URLPathComponents: ["123", "456"],
                atIndex: 0
            )
            XCTAssertEqual(placeholder?.0, "id")
            XCTAssertEqual(placeholder?.1 as? String, "123")
        }();
        {
            let placeholder = matcher.placeholderKeyValueFromURLPatternPathComponent(
                "<int:id>",
                URLPathComponents: ["123", "456"],
                atIndex: 0
            )
            XCTAssertEqual(placeholder?.0, "id")
            XCTAssertEqual(placeholder?.1 as? Int, 123)
        }();
        {
            let placeholder = matcher.placeholderKeyValueFromURLPatternPathComponent(
                "<int:id>",
                URLPathComponents: ["abc", "456"],
                atIndex: 0
            )
            XCTAssertNil(placeholder)
        }();
        {
            let placeholder = matcher.placeholderKeyValueFromURLPatternPathComponent(
                "<float:height>",
                URLPathComponents: ["180", "456"],
                atIndex: 0
            )
            XCTAssertEqual(placeholder?.0, "height")
            XCTAssertEqual(placeholder?.1 as? Float, 180)
        }();
        {
            let placeholder = matcher.placeholderKeyValueFromURLPatternPathComponent(
                "<float:height>",
                URLPathComponents: ["abc", "456"],
                atIndex: 0
            )
            XCTAssertNil(placeholder)
        }();
        {
            let placeholder = matcher.placeholderKeyValueFromURLPatternPathComponent(
                "<url>",
                URLPathComponents: ["xoul.kr"],
                atIndex: 0
            )
            XCTAssertEqual(placeholder?.0, "url")
            XCTAssertEqual(placeholder?.1 as? String, "xoul.kr")
        }();
        {
            let placeholder = matcher.placeholderKeyValueFromURLPatternPathComponent(
                "<url>",
                URLPathComponents: ["xoul.kr", "resume"],
                atIndex: 0
            )
            XCTAssertEqual(placeholder?.0, "url")
            XCTAssertEqual(placeholder?.1 as? String, "xoul.kr")
        }();
        {
            let placeholder = matcher.placeholderKeyValueFromURLPatternPathComponent(
                "<path:url>",
                URLPathComponents: ["xoul.kr"],
                atIndex: 0
            )
            XCTAssertEqual(placeholder?.0, "url")
            XCTAssertEqual(placeholder?.1 as? String, "xoul.kr")
        }();
        {
            let placeholder = matcher.placeholderKeyValueFromURLPatternPathComponent(
                "<path:url>",
                URLPathComponents: ["xoul.kr", "resume"],
                atIndex: 0
            )
            XCTAssertEqual(placeholder?.0, "url")
            XCTAssertEqual(placeholder?.1 as? String, "xoul.kr/resume")
        }();
        {
            let placeholder = matcher.placeholderKeyValueFromURLPatternPathComponent(
                "<path:url>",
                URLPathComponents: ["google.com", "search?q=test"],
                atIndex: 0
            )
            XCTAssertEqual(placeholder?.0, "url")
            XCTAssertEqual(placeholder?.1 as? String, "google.com/search?q=test")
        }();
        {
            let placeholder = matcher.placeholderKeyValueFromURLPatternPathComponent(
                "<path:url>",
                URLPathComponents: ["google.com", "search", "?q=test"],
                atIndex: 0
            )
            XCTAssertEqual(placeholder?.0, "url")
            XCTAssertEqual(placeholder?.1 as? String, "google.com/search/?q=test")
        }();
    }
    
    func testReplaceRegex() {
        XCTAssertEqual(matcher.replaceRegex("a", "0", "abc"), "0bc")
        XCTAssertEqual(matcher.replaceRegex("\\d", "A", "1234567abc098"), "AAAAAAAabcAAA")
    }
}
