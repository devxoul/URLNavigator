//
//  URLMatcher.swift
//  URLNavigator
//
//  Created by Sklar, Josh on 9/2/16.
//  Copyright © 2016 Suyeol Jeon. All rights reserved.
//
// The MIT License (MIT)
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

/// URLMatchComponents encapsulates data about a URL match.
/// It contains the following attributes:
///
/// - pattern: The url pattern that was matched.
/// - values: The values extracted from the URL.
public struct URLMatchComponents {
  public let pattern: String
  public let values: [String: Any]
}

/// URLMatcher provides a way to match URLs against a list of specified patterns.
///
/// URLMatcher extracts the pattern and the values from the URL if possible.
open class URLMatcher {

  /// A closure type which matches a URL value string to a typed value.
  public typealias URLValueMatcherHandler = (String) -> Any?

  /// A dictionary to store URL value matchers by value type.
  private var customURLValueMatcherHandlers = [String: URLValueMatcherHandler]()


  // MARK: Singleton

  open static let `default` = URLMatcher()


  // MARK: Initialization

  public init() {
    // 🔄 I'm a URLMatcher!
  }


  // MARK: Matching

  /// Returns a matching URL pattern and placeholder values from specified URL and URL patterns. Returns `nil` if the
  /// URL is not contained in URL patterns.
  ///
  /// For example:
  ///
  ///     let urlMatchComponents = matcher.match("myapp://user/123", from: ["myapp://user/<int:id>"])
  ///
  /// The value of the `URLPattern` from an example above is `"myapp://user/<int:id>"` and the value of the `values`
  /// is `["id": 123]`.
  ///
  /// - parameter url: The placeholder-filled URL.
  /// - parameter from: The array of URL patterns.
  ///
  /// - returns: A `URLMatchComponents` struct that holds the URL pattern string, a dictionary of URL placeholder
  ///            values, and any query items.
  open func match(_ url: URLConvertible, scheme: String? = nil, from urlPatterns: [String]) -> URLMatchComponents? {
    let normalizedURLString = self.normalized(url, scheme: scheme).urlStringValue
    let urlPathComponents = normalizedURLString.components(separatedBy: "/") // e.g. ["myapp:", "user", "123"]

    outer: for urlPattern in urlPatterns {
      // e.g. ["myapp:", "user", "<int:id>"]
      let urlPatternPathComponents = urlPattern.components(separatedBy: "/")
      let containsPathPlaceholder = urlPatternPathComponents.contains { $0.hasPrefix("<path:") }
      guard containsPathPlaceholder || urlPatternPathComponents.count == urlPathComponents.count else {
        continue
      }

      var values = [String: Any]()

      // e.g. ["user", "<int:id>"]
      for (i, component) in urlPatternPathComponents.enumerated() {
        guard i < urlPathComponents.count else {
          continue outer
        }
        let info = self.placeholderKeyValueFrom(urlPatternPathComponent: component,
                                                urlPathComponents: urlPathComponents,
                                                atIndex: i)
        if let (key, value) = info {
          values[key] = value // e.g. ["id": 123]
          if component.hasPrefix("<path:") {
            break // there's no more placeholder after <path:>
          }
        } else if component != urlPathComponents[i] {
          continue outer
        }
      }

      return URLMatchComponents(pattern: urlPattern, values: values)
    }
    return nil
  }

  // MARK: Utils

  /// Adds a new handler for matching any custom URL value type.
  /// If the custom URL type already has a custom handler, this overwrites its handler.
  ///
  /// For example:
  ///
  ///     matcher.addURLValueMatcherHandler(for: "SSN") { (ssnString) -> AnyObject? in
  ///       return SSN(string: ssnString)
  ///     }
  ///
  /// The value type that this would match against is "ssn" (i.e. Social Security Number), and the
  /// handler to be used for that type returns a newly created `SSN` object from the ssn string.
  ///
  /// - parameter valueType: The value type (string) to match against.
  /// - parameter handler: The handler to use when matching against that value type.
  open func addURLValueMatcherHandler(for valueType: String, handler: @escaping URLValueMatcherHandler) {
    self.customURLValueMatcherHandlers[valueType] = handler
  }

  /// Returns an scheme-appended `URLConvertible` if given `url` doesn't have its scheme.
  func url(withScheme scheme: String?, _ url: URLConvertible) -> URLConvertible {
    let urlString = url.urlStringValue
    if let scheme = scheme, !urlString.contains("://") {
      #if DEBUG
        if !urlString.hasPrefix("/") {
          NSLog("[Warning] URL pattern doesn't have leading slash(/): '\(url)'")
        }
      #endif
      return scheme + ":/" + urlString
    } else if scheme == nil && !urlString.contains("://") {
      assertionFailure("Either matcher or URL should have scheme: '\(url)'") // assert only in debug build
    }
    return urlString
  }

  /// Returns the URL by
  ///
  /// - Removing redundant trailing slash(/) on scheme
  /// - Removing redundant double-slashes(//)
  /// - Removing trailing slash(/) aside from slashes directly following the scheme
  ///
  /// - parameter dirtyURL: The dirty URL to be normalized.
  ///
  /// - returns: The normalized URL. Returns `nil` if the pecified URL is invalid.
  func normalized(_ dirtyURL: URLConvertible, scheme: String? = nil) -> URLConvertible {
    guard dirtyURL.urlValue != nil else {
      return dirtyURL
    }
    var urlString = self.url(withScheme: scheme, dirtyURL).urlStringValue
    urlString = urlString.components(separatedBy: "?")[0].components(separatedBy: "#")[0]
    urlString = self.replaceRegex(":/{3,}", "://", urlString)
    urlString = self.replaceRegex("(?<!:)/{2,}", "/", urlString)
    urlString = self.replaceRegex("(?<!:|:/)/+$", "", urlString)
    return urlString
  }

  func placeholderKeyValueFrom(
    urlPatternPathComponent component: String,
    urlPathComponents: [String],
    atIndex index: Int
  ) -> (String, Any)? {
    guard component.hasPrefix("<") && component.hasSuffix(">") else { return nil }

    let start = component.index(after: component.startIndex)
    let end = component.index(before: component.endIndex)
    let placeholder = component[start..<end] // e.g. "<int:id>" -> "int:id"

    let typeAndKey = placeholder.components(separatedBy: ":") // e.g. ["int", "id"]
    if typeAndKey.count == 0 { // e.g. component is "<>"
      return nil
    }
    if typeAndKey.count == 1 { // untyped placeholder
      return (placeholder, urlPathComponents[index])
    }

    let (type, key) = (typeAndKey[0], typeAndKey[1]) // e.g. ("int", "id")
    let value: Any?
    switch type {
    case "UUID": value = UUID(uuidString: urlPathComponents[index]) // e.g. 123e4567-e89b-12d3-a456-426655440000
    case "string": value = String(urlPathComponents[index]) // e.g. "123"
    case "int": value = Int(urlPathComponents[index]) // e.g. 123
    case "float": value = Float(urlPathComponents[index]) // e.g. 123.0
    case "path": value = urlPathComponents[index..<urlPathComponents.count].joined(separator: "/")
    default:
      if let customURLValueTypeHandler = customURLValueMatcherHandlers[type] {
        value = customURLValueTypeHandler(urlPathComponents[index])
      }
      else {
        value = urlPathComponents[index]
      }
    }

    if let value = value {
      return (key, value)
    }
    return nil
  }

  func replaceRegex(_ pattern: String, _ repl: String, _ string: String) -> String {
    guard let regex = try? NSRegularExpression(pattern: pattern, options: []) else { return string }
    let range = NSMakeRange(0, string.characters.count)
    return regex.stringByReplacingMatches(in: string, options: [], range: range, withTemplate: repl)
  }
}
