//
//  URLMatcherPublicTests.swift
//  URLNavigator
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
// SOFTWARE.

import XCTest
@testable import URLNavigator

class URLMatcherPublicTests: XCTestCase {
    
    var matcher: URLMatcher!
    
    override func setUp() {
        super.setUp()
        self.matcher = URLMatcher()
    }
    
    func testMatchURL() {
        {
            XCTAssertNil(matcher.matchURL("myapp://user/1", from: []))
        }();
        {
            XCTAssertNil(matcher.matchURL("myapp://user/1", from: ["myapp://comment/<id>"]))
        }();
        {
            XCTAssertNil(matcher.matchURL("myapp://user/1", from: ["myapp://user/<id>/hello"]))
        }();
        {
            XCTAssertNil(matcher.matchURL("/user/1", scheme: "myapp", from: []))
        }();
        {
            XCTAssertNil(matcher.matchURL("/user/1", scheme: "myapp", from: ["myapp://comment/<id>"]))
        }();
        {
            XCTAssertNil(matcher.matchURL("/user/1", scheme: "myapp", from: ["myapp://user/<id>/hello"]))
        }();
        {
            XCTAssertNil(matcher.matchURL("myapp://user/1", scheme: "myapp", from: []))
        }();
        {
            XCTAssertNil(matcher.matchURL("myapp://user/1", scheme: "myapp", from: ["myapp://comment/<id>"]))
        }();
        {
            XCTAssertNil(matcher.matchURL("myapp://user/1", scheme: "myapp", from: ["myapp://user/<id>/hello"]))
        }();
        {
            let from = ["myapp://hello"]
            let (URLPattern, values) = matcher.matchURL("myapp://hello", from: from)!
            XCTAssertEqual(URLPattern, "myapp://hello")
            XCTAssertEqual(values.count, 0)
            
            let scheme = matcher.matchURL("/hello", scheme: "myapp", from: from)!
            XCTAssertEqual(URLPattern, scheme.0)
            XCTAssertEqual(values as! [String: String], scheme.1 as! [String: String])
        }();
        {
            let from = ["myapp://user/<id>"]
            let (URLPattern, values) = matcher.matchURL("myapp://user/1", from: from)!
            XCTAssertEqual(URLPattern, "myapp://user/<id>")
            XCTAssertEqual(values as! [String: String], ["id": "1"])
            
            let scheme = matcher.matchURL("/user/1", scheme: "myapp", from: from)!
            XCTAssertEqual(URLPattern, scheme.0)
            XCTAssertEqual(values as! [String: String], scheme.1 as! [String: String])
        }();
        {
            let from = ["myapp://user/<id>", "myapp://user/<id>/hello"]
            let (URLPattern, values) = matcher.matchURL("myapp://user/1", from: from)!
            XCTAssertEqual(URLPattern, "myapp://user/<id>")
            XCTAssertEqual(values as! [String: String], ["id": "1"])
            
            let scheme = matcher.matchURL("/user/1", scheme: "myapp", from: from)!
            XCTAssertEqual(URLPattern, scheme.0)
            XCTAssertEqual(values as! [String: String], scheme.1 as! [String: String])
        }();
        {
            let from = ["myapp://user/<id>", "myapp://user/<id>/<object>"]
            let (URLPattern, values) = matcher.matchURL("myapp://user/1/posts", from: from)!
            XCTAssertEqual(URLPattern, "myapp://user/<id>/<object>")
            XCTAssertEqual(values as! [String: String], ["id": "1", "object": "posts"])
            
            let scheme = matcher.matchURL("/user/1/posts", scheme: "myapp", from: from)!
            XCTAssertEqual(URLPattern, scheme.0)
            XCTAssertEqual(values as! [String: String], scheme.1 as! [String: String])
        }();
        {
            let from = ["myapp://alert"]
            let (URLPattern, values) = matcher.matchURL("myapp://alert?title=hello&message=world", from: from)!
            XCTAssertEqual(URLPattern, "myapp://alert")
            XCTAssertEqual(values.count, 0)
            
            let scheme = matcher.matchURL("/alert?title=hello&message=world", scheme: "myapp", from: from)!
            XCTAssertEqual(URLPattern, scheme.0)
            XCTAssertEqual(values as! [String: String], scheme.1 as! [String: String])
        }();
        {
            let from = ["http://<path:url>"]
            let (URLPattern, values) = matcher.matchURL("http://xoul.kr", from: from)!
            XCTAssertEqual(URLPattern, "http://<path:url>")
            XCTAssertEqual(values as! [String: String], ["url": "xoul.kr"])
            
            let scheme = matcher.matchURL("http://xoul.kr", scheme: "myapp", from: from)!
            XCTAssertEqual(URLPattern, scheme.0)
            XCTAssertEqual(values as! [String: String], scheme.1 as! [String: String])
        }();
        {
            let from = ["http://<path:url>"]
            let (URLPattern, values) = matcher.matchURL("http://xoul.kr/resume", from: from)!
            XCTAssertEqual(URLPattern, "http://<path:url>")
            XCTAssertEqual(values as! [String: String], ["url": "xoul.kr/resume"])
            
            let scheme = matcher.matchURL("http://xoul.kr/resume", scheme: "myapp", from: from)!
            XCTAssertEqual(URLPattern, scheme.0)
            XCTAssertEqual(values as! [String: String], scheme.1 as! [String: String])
        }();
        {
            let from = ["http://<path:url>"]
            let (URLPattern, values) = matcher.matchURL("http://google.com/search?q=URLNavigator", from: from)!
            XCTAssertEqual(URLPattern, "http://<path:url>")
            XCTAssertEqual(values as! [String: String], ["url": "google.com/search"])
            
            let scheme = matcher.matchURL("http://google.com/search?q=URLNavigator", scheme: "myapp", from: from)!
            XCTAssertEqual(URLPattern, scheme.0)
            XCTAssertEqual(values as! [String: String], scheme.1 as! [String: String])
        }();
        {
            let from = ["http://<path:url>"]
            let (URLPattern, values) = matcher.matchURL("http://google.com/search/?q=URLNavigator", from: from)!
            XCTAssertEqual(URLPattern, "http://<path:url>")
            XCTAssertEqual(values as! [String: String], ["url": "google.com/search"])
            
            let scheme = matcher.matchURL("http://google.com/search/?q=URLNavigator",
                                          scheme: "myapp", from: from)!
            XCTAssertEqual(URLPattern, scheme.0)
            XCTAssertEqual(values as! [String: String], scheme.1 as! [String: String])
        }();
    }
}
