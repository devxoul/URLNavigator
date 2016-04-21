// The MIT License (MIT)
//
// Copyright (c) 2016 Suyeol Jeon (xoul.kr)
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
// SOFTWARE.

import XCTest
@testable import URLNavigator

class URLNavigatorInternalTests: XCTestCase {

    func testMatchURL() {
        {
            XCTAssertNil(URLNavigator.matchURL("myapp://user/1", from: []))
        }();
        {
            XCTAssertNil(URLNavigator.matchURL("myapp://user/1", from: ["myapp://comment/<id>"]))
        }();
        {
            XCTAssertNil(URLNavigator.matchURL("myapp://user/1", from: ["myapp://user/<id>/hello"]))
        }();
        {
            let from = ["myapp://hello"]
            let (URLPattern, values) = URLNavigator.matchURL("myapp://hello", from: from)!
            XCTAssertEqual(URLPattern, "myapp://hello")
            XCTAssertEqual(values.count, 0)
        }();
        {
            let from = ["myapp://user/<id>"]
            let (URLPattern, values) = URLNavigator.matchURL("myapp://user/1", from: from)!
            XCTAssertEqual(URLPattern, "myapp://user/<id>")
            XCTAssertEqual(values as! [String: String], ["id": "1"])
        }();
        {
            let from = ["myapp://user/<id>", "myapp://user/<id>/hello"]
            let (URLPattern, values) = URLNavigator.matchURL("myapp://user/1", from: from)!
            XCTAssertEqual(URLPattern, "myapp://user/<id>")
            XCTAssertEqual(values as! [String: String], ["id": "1"])
        }();
        {
            let from = ["myapp://user/<id>", "myapp://user/<id>/<object>"]
            let (URLPattern, values) = URLNavigator.matchURL("myapp://user/1/posts", from: from)!
            XCTAssertEqual(URLPattern, "myapp://user/<id>/<object>")
            XCTAssertEqual(values as! [String: String], ["id": "1", "object": "posts"])
        }();
        {
            let from = ["myapp://alert"]
            let (URLPattern, values) = URLNavigator.matchURL("myapp://alert?title=hello&message=world", from: from)!
            XCTAssertEqual(URLPattern, "myapp://alert")
            XCTAssertEqual(values.count, 2)
        }();
        {
            let from = ["http://<path:url>"]
            let (URLPattern, values) = URLNavigator.matchURL("http://xoul.kr", from: from)!
            XCTAssertEqual(URLPattern, "http://<path:url>")
            XCTAssertEqual(values as! [String: String], ["url": "xoul.kr"])
        }();
        {
            let from = ["http://<path:url>"]
            let (URLPattern, values) = URLNavigator.matchURL("http://xoul.kr/resume", from: from)!
            XCTAssertEqual(URLPattern, "http://<path:url>")
            XCTAssertEqual(values as! [String: String], ["url": "xoul.kr/resume"])
        }();
        {
            let from = ["http://<path:url>"]
            let (URLPattern, values) = URLNavigator.matchURL("http://google.com/search?q=URLNavigator", from: from)!
            XCTAssertEqual(URLPattern, "http://<path:url>")
            XCTAssertEqual(values as! [String: String], ["url": "google.com/search", "q":"URLNavigator"])
        }();
        {
            let from = ["http://<path:url>"]
            let (URLPattern, values) = URLNavigator.matchURL("http://google.com/search/?q=URLNavigator", from: from)!
            XCTAssertEqual(URLPattern, "http://<path:url>")
            XCTAssertEqual(values as! [String: String], ["url": "google.com/search", "q":"URLNavigator"])
        }();
    }

    func testNormalizedURL() {
        XCTAssertEqual(URLNavigator.normalizedURL("myapp://user/<id>/hello").URLStringValue, "myapp://user/<id>/hello")
        XCTAssertEqual(URLNavigator.normalizedURL("myapp:///////user///<id>//hello/??/#abc=/def").URLStringValue,
            "myapp://user/<id>/hello")
        XCTAssertEqual(URLNavigator.normalizedURL("https://<path:_>").URLStringValue, "https://<path:_>")
    }

    func testPlaceholderValueFromURLPathComponents() {
        {
            let placeholder = URLNavigator.placeholderKeyValueFromURLPatternPathComponent(
                "<id>",
                URLPathComponents: ["123", "456"],
                atIndex: 0
            )
            XCTAssertEqual(placeholder?.0, "id")
            XCTAssertEqual(placeholder?.1 as? String, "123")
        }();
        {
            let placeholder = URLNavigator.placeholderKeyValueFromURLPatternPathComponent(
                "<int:id>",
                URLPathComponents: ["123", "456"],
                atIndex: 0
            )
            XCTAssertEqual(placeholder?.0, "id")
            XCTAssertEqual(placeholder?.1 as? Int, 123)
        }();
        {
            let placeholder = URLNavigator.placeholderKeyValueFromURLPatternPathComponent(
                "<int:id>",
                URLPathComponents: ["abc", "456"],
                atIndex: 0
            )
            XCTAssertNil(placeholder)
        }();
        {
            let placeholder = URLNavigator.placeholderKeyValueFromURLPatternPathComponent(
                "<float:height>",
                URLPathComponents: ["180", "456"],
                atIndex: 0
            )
            XCTAssertEqual(placeholder?.0, "height")
            XCTAssertEqual(placeholder?.1 as? Float, 180)
        }();
        {
            let placeholder = URLNavigator.placeholderKeyValueFromURLPatternPathComponent(
                "<float:height>",
                URLPathComponents: ["abc", "456"],
                atIndex: 0
            )
            XCTAssertNil(placeholder)
        }();
        {
            let placeholder = URLNavigator.placeholderKeyValueFromURLPatternPathComponent(
                "<url>",
                URLPathComponents: ["xoul.kr"],
                atIndex: 0
            )
            XCTAssertEqual(placeholder?.0, "url")
            XCTAssertEqual(placeholder?.1 as? String, "xoul.kr")
        }();
        {
            let placeholder = URLNavigator.placeholderKeyValueFromURLPatternPathComponent(
                "<url>",
                URLPathComponents: ["xoul.kr", "resume"],
                atIndex: 0
            )
            XCTAssertEqual(placeholder?.0, "url")
            XCTAssertEqual(placeholder?.1 as? String, "xoul.kr")
        }();
        {
            let placeholder = URLNavigator.placeholderKeyValueFromURLPatternPathComponent(
                "<path:url>",
                URLPathComponents: ["xoul.kr"],
                atIndex: 0
            )
            XCTAssertEqual(placeholder?.0, "url")
            XCTAssertEqual(placeholder?.1 as? String, "xoul.kr")
        }();
        {
            let placeholder = URLNavigator.placeholderKeyValueFromURLPatternPathComponent(
                "<path:url>",
                URLPathComponents: ["xoul.kr", "resume"],
                atIndex: 0
            )
            XCTAssertEqual(placeholder?.0, "url")
            XCTAssertEqual(placeholder?.1 as? String, "xoul.kr/resume")
        }();
        {
            let placeholder = URLNavigator.placeholderKeyValueFromURLPatternPathComponent(
                "<path:url>",
                URLPathComponents: ["google.com", "search?q=test"],
                atIndex: 0
            )
            XCTAssertEqual(placeholder?.0, "url")
            XCTAssertEqual(placeholder?.1 as? String, "google.com/search?q=test")
        }();
        {
            let placeholder = URLNavigator.placeholderKeyValueFromURLPatternPathComponent(
                "<path:url>",
                URLPathComponents: ["google.com", "search", "?q=test"],
                atIndex: 0
            )
            XCTAssertEqual(placeholder?.0, "url")
            XCTAssertEqual(placeholder?.1 as? String, "google.com/search/?q=test")
        }();
    }

    func testReplaceRegex() {
        XCTAssertEqual(URLNavigator.replaceRegex("a", "0", "abc"), "0bc")
        XCTAssertEqual(URLNavigator.replaceRegex("\\d", "A", "1234567abc098"), "AAAAAAAabcAAA")
    }

}
