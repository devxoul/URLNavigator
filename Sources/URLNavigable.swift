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

/// A type that can be initialized with URLs and values.
///
/// - seealso: `URLNavigator`
public protocol URLNavigable {

  /// Creates an instance with specified URL and returns it. Returns `nil` if the URL and the values are not met the
  /// condition to create an instance.
  ///
  /// For example, to validate whether a value of `id` is an `Int`:
  ///
  ///     convenience init?(url: URLConvertible, values: [String: Any]) {
  ///       guard let id = values["id"] as? Int else {
  ///         return nil
  ///       }
  ///       self.init(id: id)
  ///     }
  ///
  /// Do not call this initializer directly. It is recommended to use with `URLNavigator`.
  ///
  /// - parameter url: The URL which is used to create an instance.
  /// - parameter values: The URL pattern placeholder values by placeholder names. For example, if the URL pattern is
  ///     `myapp://user/<int:id>` and the given URL is `myapp://user/123`, values will be `["id": 123]`.
  init?(url: URLConvertible, values: [String: Any])

}
