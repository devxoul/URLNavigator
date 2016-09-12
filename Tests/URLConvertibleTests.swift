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
import URLNavigator

class URLConvertibleTests: XCTestCase {

  func testParameters() {
    XCTAssertTrue("myapp://alert".queryParameters.isEmpty)
    XCTAssertTrue("myapp://alert?".queryParameters.isEmpty)
    XCTAssertTrue("myapp://alert?title".queryParameters.isEmpty)
    XCTAssertEqual("myapp://alert?title=".queryParameters, ["title": ""])
    XCTAssertEqual("myapp://alert?title=Hello+World!".queryParameters, ["title": "Hello World!"])
    XCTAssertEqual("myapp://alert?title=Hello%20World!".queryParameters, ["title": "Hello World!"])
    XCTAssertEqual("myapp://alert?title=Hello+World!&message=Nice+to+meet+you+:)".queryParameters,
                   ["title": "Hello World!", "message": "Nice to meet you :)"])
    XCTAssertEqual("myapp://alert?title=Hello%20World!&message=Nice%20to%20meet%20you%20:)".queryParameters,
                   ["title": "Hello World!", "message": "Nice to meet you :)"])
  }

}
