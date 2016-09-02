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
///     Navigator.pushURL("myapp://user/123")
///     Navigator.presentURL("http://xoul.kr")
///
/// This is another example of mapping `URLOpenHandler` to URL:
///
///     Navigator.map("myapp://say-hello") { URL, values in
///         print("Hello, world!")
///         return true
///     }
///
/// Use `URLNavigator.openURL()` to execute closures.
///
///     Navigator.openURL("myapp://say-hello") // prints "Hello, world!"
///
/// - Note: Use `UIApplication.openURL()` method to launch other applications or to open URLs in application level.
///
/// - SeeAlso: `URLNavigable`
public class URLNavigator {

    /// A closure type which has URL and values for parameters.
    public typealias URLOpenHandler = (URL: URLConvertible, values: [String: AnyObject]) -> Bool

    /// A dictionary to store URLNaviables by URL patterns.
    private(set) var URLMap = [String: URLNavigable.Type]()

    /// A dictionary to store URLOpenHandlers by URL patterns.
    private(set) var URLOpenHandlers = [String: URLOpenHandler]()

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
    public var scheme: String? {
        didSet {
            if let scheme = self.scheme where scheme.containsString("://") == true {
                self.scheme = scheme.componentsSeparatedByString("://")[0]
            }
        }
    }


    // MARK: Initializing

    public init() {
        // ⛵ I'm an URLNavigator!
    }


    // MARK: Singleton

    /// Returns a default navigator. A global constant `Navigator` is a shortcut of `URLNavigator.defaultNavigator()`.
    ///
    /// - SeeAlso: `Navigator`
    public static func defaultNavigator() -> URLNavigator {
        struct Shared {
            static let defaultNavigator = URLNavigator()
        }
        return Shared.defaultNavigator
    }


    // MARK: URL Mapping

    /// Map an `URLNavigable` to an URL pattern.
    public func map(URLPattern: URLConvertible, _ navigable: URLNavigable.Type) {
        let URLString = URLMatcher.defaultMatcher().normalizedURL(URLPattern, scheme: self.scheme).URLStringValue
        self.URLMap[URLString] = navigable
    }

    /// Map an `URLOpenHandler` to an URL pattern.
    public func map(URLPattern: URLConvertible, _ handler: URLOpenHandler) {
        let URLString = URLMatcher.defaultMatcher().normalizedURL(URLPattern, scheme: self.scheme).URLStringValue
        self.URLOpenHandlers[URLString] = handler
    }

    /// Returns a matched view controller from a specified URL.
    ///
    /// - Parameter URL: The URL to find view controllers.
    /// - Returns: A match view controller or `nil` if not matched.
    public func viewControllerForURL(URL: URLConvertible) -> UIViewController? {
        if let urlMatchComponents = URLMatcher.defaultMatcher().matchURL(URL, scheme: self.scheme, from: Array(self.URLMap.keys)) {
            let navigable = self.URLMap[urlMatchComponents.pattern]
            return navigable?.init(URL: URL, values: urlMatchComponents.values) as? UIViewController
        }
        return nil
    }

    // MARK: Pushing View Controllers with URL

    /// Pushes a view controller using `UINavigationController.pushViewController()`.
    ///
    /// This is an example of pushing a view controller to the top-most view contoller:
    ///
    ///     Navigator.pushURL("myapp://user/123")
    ///
    /// Use the return value to access a view controller.
    ///
    ///     let userViewController = Navigator.pushURL("myapp://user/123")
    ///     userViewController?.doSomething()
    ///
    /// - Parameter URL: The URL to find view controllers.
    /// - Parameter from: The navigation controller which is used to push a view controller. Use application's top-most
    ///     view controller if `nil` is specified. `nil` by default.
    /// - Parameter animated: Whether animates view controller transition or not. `true` by default.
    ///
    /// - Returns: The pushed view controller. Returns `nil` if there's no matching view controller or failed to push
    ///            a view controller.
    public func pushURL(URL: URLConvertible,
                        from: UINavigationController? = nil,
                        animated: Bool = true) -> UIViewController? {
        guard let viewController = self.viewControllerForURL(URL) else {
            return nil
        }
        return self.push(viewController, from: from, animated: animated)
    }

    /// Pushes a view controller using `UINavigationController.pushViewController()`.
    ///
    /// - Parameter viewController: The `UIViewController` instance to be pushed.
    /// - Parameter from: The navigation controller which is used to push a view controller. Use application's top-most
    ///     view controller if `nil` is specified. `nil` by default.
    /// - Parameter animated: Whether animates view controller transition or not. `true` by default.
    ///
    /// - Returns: The pushed view controller. Returns `nil` if failed to push a view controller.
    public func push(viewController: UIViewController,
                     from: UINavigationController? = nil,
                     animated: Bool = true) -> UIViewController? {
        guard let navigationController = from ?? UIViewController.topMostViewController()?.navigationController else {
            return nil
        }
        navigationController.pushViewController(viewController, animated: animated)
        return viewController
    }


    // MARK: Presenting View Controllers with URL

    /// Presents a view controller using `UIViewController.presentViewController()`.
    ///
    /// This is an example of presenting a view controller to the top-most view contoller:
    ///
    ///     Navigator.presentURL("myapp://user/123")
    ///
    /// Use the return value to access a view controller.
    ///
    ///     let userViewController = Navigator.presentURL("myapp://user/123")
    ///     userViewController?.doSomething()
    ///
    /// - Parameter URL: The URL to find view controllers.
    /// - Parameter wrap: Wraps the view controller with a `UINavigationController` if `true` is specified. `false` by 
    ///     default.
    /// - Parameter from: The view controller which is used to present a view controller. Use application's top-most
    ///     view controller if `nil` is specified. `nil` by default.
    /// - Parameter animated: Whether animates view controller transition or not. `true` by default.
    /// - Parameter completion: Called after the transition has finished.
    ///
    /// - Returns: The presented view controller. Returns `nil` if there's no matching view controller or failed to
    ///     present a view controller.
    public func presentURL(URL: URLConvertible,
                           wrap: Bool = false,
                           from: UIViewController? = nil,
                           animated: Bool = true,
                           completion: (() -> Void)? = nil) -> UIViewController? {
        guard let viewController = self.viewControllerForURL(URL) else {
            return nil
        }
        return self.present(viewController, wrap: wrap, from: from, animated: animated, completion: completion)
    }

    /// Presents a view controller using `UIViewController.presentViewController()`.
    ///
    /// - Parameter viewController: The `UIViewController` instance to be presented.
    /// - Parameter wrap: Wraps the view controller with a `UINavigationController` if `true` is specified. `false` by
    ///     default.
    /// - Parameter from: The view controller which is used to present a view controller. Use application's top-most
    ///     view controller if `nil` is specified. `nil` by default.
    /// - Parameter animated: Whether animates view controller transition or not. `true` by default.
    /// - Parameter completion: Called after the transition has finished.
    ///
    /// - Returns: The presented view controller. Returns `nil` if failed to present a view controller.
    public func present(viewController: UIViewController,
                        wrap: Bool = false,
                        from: UIViewController? = nil,
                        animated: Bool = true,
                        completion: (() -> Void)? = nil) -> UIViewController? {
        guard let fromViewController = from ?? UIViewController.topMostViewController() else {
            return nil
        }
        if wrap {
            let navigationController = UINavigationController(rootViewController: viewController)
            fromViewController.presentViewController(navigationController, animated: animated, completion: nil)
        } else {
            fromViewController.presentViewController(viewController, animated: animated, completion: nil)
        }
        return viewController
    }


    // MARK: Opening URL

    /// Executes the registered `URLOpenHandler`.
    ///
    /// - Parameter URL: The URL to find `URLOpenHandler`s.
    ///
    /// - Returns: The return value of the matching `URLOpenHandler`. Returns `false` if there's no match.
    public func openURL(URL: URLConvertible) -> Bool {
        let URLOpenHandlersKeys = Array(self.URLOpenHandlers.keys)
        if let urlMatchComponents = URLMatcher.defaultMatcher().matchURL(URL, scheme: self.scheme, from: URLOpenHandlersKeys) {
            let handler = self.URLOpenHandlers[urlMatchComponents.pattern]
            if handler?(URL: URL, values: urlMatchComponents.values) == true {
                return true
            }
        }
        return false
    }
}


// MARK: - Default Navigator

public let Navigator = URLNavigator.defaultNavigator()
