#if os(iOS) || os(tvOS)
import UIKit

#if !COCOAPODS
import URLMatcher
#endif

open class Navigator: NavigatorType {
  open let matcher = URLMatcher()

  private var factories = [URLPattern: ViewControllerFactory]()
  private var handlers = [URLPattern: URLOpenHandlerFactory]()

  public init() {
    // ⛵ I'm a Navigator!
  }

  open func register(_ pattern: URLPattern, _ factory: @escaping ViewControllerFactory) {
    self.factories[pattern] = factory
  }

  open func handle(_ pattern: URLPattern, _ handler: @escaping URLOpenHandlerFactory) {
    self.handlers[pattern] = handler
  }

  open func viewController(for url: URLConvertible, context: Any? = nil) -> UIViewController? {
    let urlPatterns = Array(self.factories.keys)
    guard let match = self.matcher.match(url, from: urlPatterns) else { return nil }
    guard let factory = self.factories[match.pattern] else { return nil }
    return factory(url, match.values, context)
  }

  open func handler(for url: URLConvertible, context: Any?) -> URLOpenHandler? {
    let urlPatterns = Array(self.handlers.keys)
    guard let match = self.matcher.match(url, from: urlPatterns) else { return nil }
    guard let handler = self.handlers[match.pattern] else { return nil }
    return { handler(url, match.values, context) }
  }
}
#endif
