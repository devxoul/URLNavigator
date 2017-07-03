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

import UIKit

/// A typealias for avoiding namespace conflict.
public typealias _URLConvertible = URLConvertible

/// URLNavigator provides an elegant way to navigate through view controllers by URLs. URLs should be mapped by using
/// `URLNavigator.map(_:_:)` function.
///
/// URLNavigator can be used to map URLs with 2 kind of types: `URLNavigable` and `URLOpenHandler`. `URLNavigable` is
/// a type which defines an custom initializer and `URLOpenHandler` is a closure. Both an initializer and a closure
/// have URL and values for its parameters.
///
/// URLs can have
///
/// Here's an example of mapping URLNaviable-conforming class `UserViewController` to URL:
///
///     Navigator.map("myapp://user/<int:id>", UserViewController.self)
///     Navigator.map("http://<path:_>", MyWebViewController.self)
///
/// This URL can be used to push or present the `UserViewController` by providing URLs:
///
///     Navigator.push("myapp://user/123")
///     Navigator.present("http://xoul.kr")
///
/// This is another example of mapping `URLOpenHandler` to URL:
///
///     Navigator.map("myapp://say-hello") { URL, values in
///       print("Hello, world!")
///       return true
///     }
///
/// Use `URLNavigator.openURL()` to execute closures.
///
///     Navigator.openURL("myapp://say-hello") // prints "Hello, world!"
///
/// - note: Use `UIApplication.openURL()` method to launch other applications or to open URLs in application level.
///
/// - seealso: `URLNavigable`
open class URLNavigator {

  struct URLMapItem {
    let navigable: URLNavigable.Type
    let mappingContext: MappingContext?
  }

  /// A typealias for avoiding namespace conflict.
  public typealias URLConvertible = _URLConvertible

  /// A closure type which has URL and values for parameters.
  public typealias URLOpenHandler = (_ url: URLConvertible, _ values: [String: Any]) -> Bool

  /// A dictionary to store URLNaviables by URL patterns.
  private(set) var urlMap = [String: URLMapItem]()

  /// A dictionary to store URLOpenHandlers by URL patterns.
  private(set) var urlOpenHandlers = [String: URLOpenHandler]()

  /// A default scheme. If this value is set, it's available to map URL paths without schemes.
  ///
  ///     Navigator.scheme = "myapp"
  ///     Navigator.map("/user/<int:id>", UserViewController.self)
  ///     Navigator.map("/post/<title>", PostViewController.self)
  ///
  /// this is equivalent to:
  ///
  ///     Navigator.map("myapp://user/<int:id>", UserViewController.self)
  ///     Navigator.map("myapp://post/<title>", PostViewController.self)
  open var scheme: String? {
    didSet {
      if let scheme = self.scheme, scheme.contains("://") {
        self.scheme = scheme.components(separatedBy: "://")[0]
      }
    }
  }


  // MARK: Singleton

  /// Returns a default navigator. A global constant `Navigator` is a shortcut of `URLNavigator.default`.
  ///
  /// - seealso: `Navigator`
  open static let `default` = URLNavigator()


  // MARK: Initializing

  public init() {
    // ⛵ I'm an URLNavigator!
  }


  // MARK: URL Mapping

  /// Map an `URLNavigable` to an URL pattern.
  open func map(_ urlPattern: URLConvertible, _ navigable: URLNavigable.Type, context: MappingContext? = nil) {
    let URLString = URLMatcher.default.normalized(urlPattern, scheme: self.scheme).urlStringValue
    self.urlMap[URLString] = URLMapItem(navigable: navigable, mappingContext: context)
  }

  /// Map an `URLOpenHandler` to an URL pattern.
  open func map(_ urlPattern: URLConvertible, _ handler: @escaping URLOpenHandler) {
    let URLString = URLMatcher.default.normalized(urlPattern, scheme: self.scheme).urlStringValue
    self.urlOpenHandlers[URLString] = handler
  }

  /// Returns a matched view controller from a specified URL.
  ///
  /// - parameter url: The URL to find view controllers.
  /// - parameter context: The user extra parameters you want add.
  /// - returns: A match view controller or `nil` if not matched.
  open func viewController(for url: URLConvertible, context: NavigationContext? = nil) -> UIViewController? {
    if let urlMatchComponents = URLMatcher.default.match(url, scheme: self.scheme, from: Array(self.urlMap.keys)) {
      guard let item = self.urlMap[urlMatchComponents.pattern] else { return nil }
      let navigation = Navigation(
        url: url,
        values: urlMatchComponents.values,
        mappingContext: item.mappingContext,
        navigationContext: context
      )
      return item.navigable.init(navigation: navigation) as? UIViewController
    }
    return nil
  }

  // MARK: Pushing View Controllers with URL

  /// Pushes a view controller using `UINavigationController.pushViewController()`.
  ///
  /// This is an example of pushing a view controller to the top-most view contoller:
  ///
  ///     Navigator.push("myapp://user/123")
  ///
  /// Use the return value to access a view controller.
  ///
  ///     let userViewController = Navigator.push("myapp://user/123")
  ///     userViewController?.doSomething()
  ///
  /// - parameter url: The URL to find view controllers.
  /// - parameter from: The navigation controller which is used to push a view controller. Use application's top-most
  ///     view controller if `nil` is specified. `nil` by default.
  /// - parameter animated: Whether animates view controller transition or not. `true` by default.
  ///
  /// - returns: The pushed view controller. Returns `nil` if there's no matching view controller or failed to push
  ///            a view controller.
  @discardableResult
  open func push(
    _ url: URLConvertible,
    context: NavigationContext? = nil,
    from: UINavigationController? = nil,
    animated: Bool = true
  ) -> UIViewController? {
    guard let viewController = self.viewController(for: url, context: context) else {
      return nil
    }
    return self.push(viewController, from: from, animated: animated)
  }

  /// Pushes a view controller using `UINavigationController.pushViewController()`.
  ///
  /// - parameter viewController: The `UIViewController` instance to be pushed.
  /// - parameter from: The navigation controller which is used to push a view controller. Use application's top-most
  ///     view controller if `nil` is specified. `nil` by default.
  /// - parameter animated: Whether animates view controller transition or not. `true` by default.
  ///
  /// - returns: The pushed view controller. Returns `nil` if failed to push a view controller.
  @discardableResult
  open func push(
    _ viewController: UIViewController,
    from: UINavigationController? = nil,
    animated: Bool = true
  ) -> UIViewController? {
    guard let navigationController = from ?? UIViewController.topMost?.navigationController else {
      return nil
    }
    guard (viewController is UINavigationController) == false else { return nil }
    navigationController.pushViewController(viewController, animated: animated)
    return viewController
  }


  // MARK: Presenting View Controllers with URL

  /// Presents a view controller using `UIViewController.presentViewController()`.
  ///
  /// This is an example of presenting a view controller to the top-most view contoller:
  ///
  ///     Navigator.present("myapp://user/123")
  ///
  /// Use the return value to access a view controller.
  ///
  ///     let userViewController = Navigator.present("myapp://user/123")
  ///     userViewController?.doSomething()
  ///
  /// - parameter url: The URL to find view controllers.
  /// - parameter wrap: Wraps the view controller with a `UINavigationController` if `true` is specified. `false` by
  ///     default.
  /// - parameter from: The view controller which is used to present a view controller. Use application's top-most
  ///     view controller if `nil` is specified. `nil` by default.
  /// - parameter animated: Whether animates view controller transition or not. `true` by default.
  /// - parameter completion: Called after the transition has finished.
  ///
  /// - returns: The presented view controller. Returns `nil` if there's no matching view controller or failed to
  ///     present a view controller.
  @discardableResult
  open func present(
    _ url: URLConvertible,
    context: NavigationContext? = nil,
    wrap: Bool = false,
    from: UIViewController? = nil,
    animated: Bool = true,
    completion: (() -> Void)? = nil
  ) -> UIViewController? {
    guard let viewController = self.viewController(for: url, context: context) else { return nil }
    return self.present(viewController, wrap: wrap, from: from, animated: animated, completion: completion)
  }

  /// Presents a view controller using `UIViewController.presentViewController()`.
  ///
  /// - parameter viewController: The `UIViewController` instance to be presented.
  /// - parameter wrap: Wraps the view controller with a `UINavigationController` if `true` is specified. `false` by
  ///     default.
  /// - parameter from: The view controller which is used to present a view controller. Use application's top-most
  ///     view controller if `nil` is specified. `nil` by default.
  /// - parameter animated: Whether animates view controller transition or not. `true` by default.
  /// - parameter completion: Called after the transition has finished.
  ///
  /// - returns: The presented view controller. Returns `nil` if failed to present a view controller.
  @discardableResult
  open func present(
    _ viewController: UIViewController,
    wrap: Bool = false,
    from: UIViewController? = nil,
    animated: Bool = true,
    completion: (() -> Void)? = nil
  ) -> UIViewController? {
    guard let fromViewController = from ?? UIViewController.topMost else { return nil }
    let wrap = wrap && (viewController is UINavigationController) == false
    if wrap {
      let navigationController = UINavigationController(rootViewController: viewController)
      fromViewController.present(navigationController, animated: animated, completion: nil)
    } else {
      fromViewController.present(viewController, animated: animated, completion: nil)
    }
    return viewController
  }


  // MARK: Opening URL

  /// Executes the registered `URLOpenHandler`.
  ///
  /// - parameter url: The URL to find `URLOpenHandler`s.
  ///
  /// - returns: The return value of the matching `URLOpenHandler`. Returns `false` if there's no match.
  @discardableResult
  open func open(_ url: URLConvertible) -> Bool {
    let urlOpenHandlersKeys = Array(self.urlOpenHandlers.keys)
    if let urlMatchComponents = URLMatcher.default.match(url, scheme: self.scheme, from: urlOpenHandlersKeys) {
      let handler = self.urlOpenHandlers[urlMatchComponents.pattern]
      if handler?(url, urlMatchComponents.values) == true {
        return true
      }
    }
    return false
  }
}


// MARK: - Default Navigator

public let Navigator = URLNavigator.default
