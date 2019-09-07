import Foundation

/// URLMatcher provides a way to match URLs against a list of specified patterns.
///
/// URLMatcher extracts the pattern and the values from the URL if possible.
open class URLMatcher {
  public typealias URLPattern = String
  public typealias URLValueConverter = (_ pathComponents: [String], _ index: Int) -> Any?

  static let defaultURLValueConverters: [String: URLValueConverter] = [
    "string": { pathComponents, index in
      return pathComponents[index]
    },
    "int": { pathComponents, index in
      return Int(pathComponents[index])
    },
    "float": { pathComponents, index in
      return Float(pathComponents[index])
    },
    "uuid": { pathComponents, index in
      return UUID(uuidString: pathComponents[index])
    },
    "path": { pathComponents, index in
      return pathComponents[index..<pathComponents.count].joined(separator: "/")
    }
  ]

  open var valueConverters: [String: URLValueConverter] = URLMatcher.defaultURLValueConverters

  public init() {
    // 🔄 I'm an URLMatcher!
  }

  /// Returns a matching URL pattern and placeholder values from the specified URL and patterns.
  /// It returns `nil` if the given URL is not contained in the URL patterns.
  ///
  /// For example:
  ///
  ///     let result = matcher.match("myapp://user/123", from: ["myapp://user/<int:id>"])
  ///
  /// The value of the `URLPattern` from an example above is `"myapp://user/<int:id>"` and the
  /// value of the `values` is `["id": 123]`.
  ///
  /// - parameter url: The placeholder-filled URL.
  /// - parameter from: The array of URL patterns.
  ///
  /// - returns: A `URLMatchComponents` struct that holds the URL pattern string, a dictionary of
  ///            the URL placeholder values.
  open func match(_ url: URLConvertible, from candidates: [URLPattern]) -> URLMatchResult? {
    let url = self.normalizeURL(url)
    let scheme = url.urlValue?.scheme
    let stringPathComponents = self.stringPathComponents(from :url)

    var results = [URLMatchResult]()
    
    for candidate in candidates {
      guard scheme == candidate.urlValue?.scheme else { continue }
      if let result = self.match(stringPathComponents, with: candidate) {
        results.append(result)
      }
    }

    return results.max {
       self.numberOfPlainPathComponent(in: $0.pattern) < self.numberOfPlainPathComponent(in: $1.pattern)
    }
  }

  func match(_ stringPathComponents: [String], with candidate: URLPattern) -> URLMatchResult? {
    let normalizedCandidate = self.normalizeURL(candidate).urlStringValue
    let candidatePathComponents = self.pathComponents(from: normalizedCandidate)
    guard self.ensurePathComponentsCount(stringPathComponents, candidatePathComponents) else {
      return nil
    }

    var urlValues: [String: Any] = [:]

    let pairCount = min(stringPathComponents.count, candidatePathComponents.count)
    for index in 0..<pairCount {
      let result = self.matchStringPathComponent(
        at: index,
        from: stringPathComponents,
        with: candidatePathComponents
      )

      switch result {
      case let .matches(placeholderValue):
        if let (key, value) = placeholderValue {
          urlValues[key] = value
        }

      case .notMatches:
        return nil
      }
    }

    return URLMatchResult(pattern: candidate, values: urlValues)
  }

  func normalizeURL(_ dirtyURL: URLConvertible) -> URLConvertible {
    guard dirtyURL.urlValue != nil else { return dirtyURL }
    var urlString = dirtyURL.urlStringValue
    urlString = urlString.components(separatedBy: "?")[0].components(separatedBy: "#")[0]
    urlString = self.replaceRegex(":/{3,}", "://", urlString)
    urlString = self.replaceRegex("(?<!:)/{2,}", "/", urlString)
    urlString = self.replaceRegex("(?<!:|:/)/+$", "", urlString)
    return urlString
  }

  func replaceRegex(_ pattern: String, _ repl: String, _ string: String) -> String {
    guard let regex = try? NSRegularExpression(pattern: pattern, options: []) else { return string }
    let range = NSMakeRange(0, string.count)
    return regex.stringByReplacingMatches(in: string, options: [], range: range, withTemplate: repl)
  }

  func ensurePathComponentsCount(
    _ stringPathComponents: [String],
    _ candidatePathComponents: [URLPathComponent]
  ) -> Bool {
    let hasSameNumberOfComponents = (stringPathComponents.count == candidatePathComponents.count)
    let containsPathPlaceholderComponent = candidatePathComponents.contains {
      if case let .placeholder(type, _) = $0, type == "path" {
        return true
      } else {
        return false
      }
    }
    return hasSameNumberOfComponents || (containsPathPlaceholderComponent && stringPathComponents.count > candidatePathComponents.count)
  }

  func stringPathComponents(from url: URLConvertible) -> [String] {
    return url.urlStringValue.components(separatedBy: "/").lazy.enumerated()
      .filter { index, component in !component.isEmpty }
      .filter { index, component in !self.isScheme(index, component) }
      .map { index, component in component }
  }

  private func isScheme(_ index: Int, _ component: String) -> Bool {
    return index == 0 && component.hasSuffix(":")
  }

  func pathComponents(from url: URLPattern) -> [URLPathComponent] {
    return self.stringPathComponents(from: url).map(URLPathComponent.init)
  }

  func matchStringPathComponent(
    at index: Int,
    from stringPathComponents: [String],
    with candidatePathComponents: [URLPathComponent]
  ) -> URLPathComponentMatchResult {
    let stringPathComponent = stringPathComponents[index]
    let urlPathComponent = candidatePathComponents[index]

    switch urlPathComponent {
    case let .plain(value):
      guard stringPathComponent == value else { return .notMatches }
      return .matches(nil)

    case let .placeholder(type, key):
      guard let type = type, let converter = self.valueConverters[type] else {
        return .matches((key, stringPathComponent))
      }
      if let value = converter(stringPathComponents, index) {
        return .matches((key, value))
      } else {
        return .notMatches
      }
    }
  }

  private func numberOfPlainPathComponent(in pattern: URLPattern) -> Int {
    return self.pathComponents(from: pattern).lazy.filter {
      guard case .plain = $0 else { return false }
      return true
    }.count
  }
}
