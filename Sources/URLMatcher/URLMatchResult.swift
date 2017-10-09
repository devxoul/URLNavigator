/// Represents an URL match result.
public struct URLMatchResult {
  /// The url pattern that was matched.
  public let pattern: String

  /// The values extracted from the URL placeholder.
  public let values: [String: Any]
}
