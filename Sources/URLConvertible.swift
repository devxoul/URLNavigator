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
    var URLValue: URL? { get }
    var URLStringValue: String { get }

    /// Returns URL query parameters. For convenience, this property will never return `nil` even if there's no query
    /// string in URL. This property doesn't take care of duplicated keys. Use `queryItems` for strictness.
    ///
    /// - SeeAlso: `queryItems`
    var queryParameters: [String: String] { get }

    /// Returns `queryItems` property of `URLComponents` instance.
    ///
    /// - SeeAlso: `queryParameters`
    @available(iOS 8, *)
    var queryItems: [URLQueryItem]? { get }
}

extension URLConvertible {
    public var queryParameters: [String: String] {
        var parameters = [String: String]()
        self.URLValue?.query?.components(separatedBy: "&").forEach {
            let keyAndValue = $0.components(separatedBy: "=")
            if keyAndValue.count == 2 {
                let key = keyAndValue[0]
                let value = keyAndValue[1].replacingOccurrences(of: "+", with: " ").removingPercentEncoding
                    ?? keyAndValue[1]
                parameters[key] = value
            }
        }
        return parameters
    }

    @available(iOS 8, *)
    public var queryItems: [URLQueryItem]? {
        return URLComponents(string: self.URLStringValue)?.queryItems
    }
}

extension String: URLConvertible {
    public var URLValue: URL? {
        if let URL = URL(string: self) {
            return URL
        }
        var set = CharacterSet()
        set.formUnion(.urlHostAllowed)
        set.formUnion(.urlPathAllowed)
        set.formUnion(.urlQueryAllowed)
        set.formUnion(.urlFragmentAllowed)
        return self.addingPercentEncoding(withAllowedCharacters: set).flatMap { URL(string: $0) }
    }

    public var URLStringValue: String {
        return self
    }
}

extension URL: URLConvertible {
    public var URLValue: URL? {
        return self
    }

    public var URLStringValue: String {
        return self.absoluteString
    }
}
