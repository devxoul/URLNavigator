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

import Foundation

/// A type which can be converted to URL string.
public protocol URLConvertible {
    var URLValue: NSURL? { get }
    var URLStringValue: String { get }
}

extension String: URLConvertible {
    public var URLValue: NSURL? {
        if let URL = NSURL(string: self) {
            return URL
        }
        let set = NSMutableCharacterSet()
        set.formUnionWithCharacterSet(.URLHostAllowedCharacterSet())
        set.formUnionWithCharacterSet(.URLPathAllowedCharacterSet())
        set.formUnionWithCharacterSet(.URLQueryAllowedCharacterSet())
        set.formUnionWithCharacterSet(.URLFragmentAllowedCharacterSet())
        return self.stringByAddingPercentEncodingWithAllowedCharacters(set).flatMap { NSURL(string: $0) }
    }

    public var URLStringValue: String {
        return self
    }
}

extension NSURL: URLConvertible {
    public var URLValue: NSURL? {
        return self
    }

    public var URLStringValue: String {
        return self.absoluteString
    }
}
