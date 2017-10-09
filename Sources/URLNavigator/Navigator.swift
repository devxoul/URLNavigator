#if os(iOS) || os(tvOS)
import UIKit

#if !COCOAPODS
import URLMatcher
#endif

public typealias URLPattern = String
public typealias ViewControllerFactory = (_ url: URLConvertible, _ values: [String: Any], _ context: Any?) -> UIViewController?
public typealias URLOpenHandler = (_ url: URLConvertible, _ values: [String: Any], _ context: Any?) -> Bool

public protocol NavigatorType {
  func register(_ pattern: URLPattern, _ factory: @escaping ViewControllerFactory)
  func handle(_ pattern: URLPattern, _ handler: @escaping URLOpenHandler)

  func push(_ url: URLConvertible, context: Any?, from: UINavigationControllerType?, animated: Bool) -> UIViewController?
  func push(_ viewController: UIViewController, from: UINavigationControllerType?, animated: Bool) -> UIViewController?

  func present(_ url: URLConvertible, context: Any?, wrap: UINavigationController.Type?, from: UIViewControllerType?, animated: Bool, completion: (() -> Void)?) -> UIViewController?
  func present(_ viewController: UIViewController, wrap: UINavigationController.Type?, from: UIViewControllerType?, animated: Bool, completion: (() -> Void)?) -> UIViewController?

  func open(_ url: URLConvertible, context: Any?) -> Bool
}

open class Navigator: NavigatorType {
  private let matcher = URLMatcher()
  private var factories = [URLPattern: ViewControllerFactory]()
  private var handlers = [URLPattern: URLOpenHandler]()

  public init() {
    // ⛵ I'm a Navigator!
  }


  // MARK: Registering

  /// Registers a view controller factory to the URL pattern.
  open func register(_ pattern: URLPattern, _ factory: @escaping ViewControllerFactory) {
    self.factories[pattern] = factory
  }

  /// Registers an URL open handler to the URL pattern.
  open func handle(_ pattern: URLPattern, _ handler: @escaping URLOpenHandler) {
    self.handlers[pattern] = handler
  }


  // MARK: View Controller

  /// Returns a matching view controller from the specified URL.
  ///
  /// - parameter url: An URL to find view controllers.
  ///
  /// - returns: A match view controller or `nil` if not matched.
  open func viewController(for url: URLConvertible, context: Any? = nil) -> UIViewController? {
    let urlPatterns = Array(self.factories.keys)
    guard let match = self.matcher.match(url, from: urlPatterns) else { return nil }
    guard let factory = self.factories[match.pattern] else { return nil }
    return factory(url, match.values, context)
  }


  // MARK: Push

  @discardableResult
  open func push(
    _ url: URLConvertible,
    context: Any? = nil,
    from: UINavigationControllerType? = nil,
    animated: Bool = true
  ) -> UIViewController? {
    guard let viewController = self.viewController(for: url, context: context) else { return nil }
    return self.push(viewController, from: from, animated: animated)
  }

  @discardableResult
  open func push(
    _ viewController: UIViewController,
    from: UINavigationControllerType? = nil,
    animated: Bool = true
  ) -> UIViewController? {
    guard (viewController is UINavigationController) == false else { return nil }
    guard let navigationController = from ?? UIViewController.topMost?.navigationController else {
      return nil
    }
    navigationController.pushViewController(viewController, animated: animated)
    return viewController
  }


  // MARK: Present

  @discardableResult
  open func present(
    _ url: URLConvertible,
    context: Any? = nil,
    wrap: UINavigationController.Type? = nil,
    from: UIViewControllerType? = nil,
    animated: Bool = true,
    completion: (() -> Void)? = nil
  ) -> UIViewController? {
    guard let viewController = self.viewController(for: url, context: context) else { return nil }
    return self.present(viewController, wrap: wrap, from: from, animated: animated, completion: completion)
  }

  @discardableResult
  open func present(
    _ viewController: UIViewController,
    wrap: UINavigationController.Type? = nil,
    from: UIViewControllerType? = nil,
    animated: Bool = true,
    completion: (() -> Void)? = nil
  ) -> UIViewController? {
    guard let fromViewController = from ?? UIViewController.topMost else { return nil }
    if let navigationControllerClass = wrap, (viewController is UINavigationController) == false {
      let navigationController = navigationControllerClass.init(rootViewController: viewController)
      fromViewController.present(navigationController, animated: animated, completion: completion)
    } else {
      fromViewController.present(viewController, animated: animated, completion: completion)
    }
    return viewController
  }


  // MARK: Open

  @discardableResult
  open func open(_ url: URLConvertible, context: Any? = nil) -> Bool {
    let urlPatterns = Array(self.handlers.keys)
    guard let match = self.matcher.match(url, from: urlPatterns) else { return false }
    guard let handler = self.handlers[match.pattern] else { return false }
    return handler(url, match.values, context)
  }
}
#endif
