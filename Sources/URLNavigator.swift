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
    
    /// String with the value of the fallback scheme when normalize the url
    public static var defaultSchemeString:String?


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
        let URLString = URLNavigator.normalizedURL(URLPattern).URLStringValue
        self.URLMap[URLString] = navigable
    }

    /// Map an `URLOpenHandler` to an URL pattern.
    public func map(URLPattern: URLConvertible, _ handler: URLOpenHandler) {
        let URLString = URLNavigator.normalizedURL(URLPattern).URLStringValue
        self.URLOpenHandlers[URLString] = handler
    }


    // MARK: Matching URLs

    /// Returns a matching URL pattern and placeholder values from specified URL and URL patterns. Returns `nil` if the
    /// URL is not contained in URL patterns.
    ///
    /// For example:
    ///
    ///     let (URLPattern, values) = URLNavigator.matchURL("myapp://user/123", from: ["myapp://user/<int:id>"])
    ///
    /// The value of the `URLPattern` from an example above is `"myapp://user/<int:id>"` and the value of the `values` 
    /// is `["id": 123]`.
    ///
    /// - Parameter URL: The placeholder-filled URL.
    /// - Parameter from: The array of URL patterns.
    ///
    /// - Returns: A tuple of URL pattern string and a dictionary of URL placeholder values.
    static func matchURL(URL: URLConvertible, from URLPatterns: [String]) -> (String, [String: AnyObject])? {
        // e.g. ["myapp:", "user", "123"]
        let URLPathComponents = URLNavigator.normalizedURL(URL).URLStringValue.componentsSeparatedByString("/")

        outer: for URLPattern in URLPatterns {
            // e.g. ["myapp:", "user", "<int:id>"]
            let URLPatternPathComponents = URLPattern.componentsSeparatedByString("/")
            let containsPathPlaceholder = URLPatternPathComponents.contains({ $0.hasPrefix("<path:") })
            guard containsPathPlaceholder || URLPatternPathComponents.count == URLPathComponents.count else {
                continue
            }

            var values = [String: AnyObject]()

            // e.g. ["user", "<int:id>"]
            for (i, component) in URLPatternPathComponents.enumerate() {
                guard i < URLPathComponents.count else {
                    continue outer
                }
                let info = self.placeholderKeyValueFromURLPatternPathComponent(component,
                    URLPathComponents: URLPathComponents,
                    atIndex: i
                )
                if let key = info?.0, value = info?.1 {
                    values[key] = value // e.g. ["id": 123]
                    if component.hasPrefix("<path:") {
                        break // there's no more placeholder after <path:>
                    }
                } else if component != URLPathComponents[i] {
                    continue outer
                }
            }

            return (URLPattern, values)
        }
        return nil
    }

    /// Returns a matched view controller from a specified URL.
    ///
    /// - Parameter URL: The URL to find view controllers.
    /// - Returns: A match view controller or `nil` if not matched.
    public func viewControllerForURL(URL: URLConvertible) -> UIViewController? {
        if let (URLPattern, values) = URLNavigator.matchURL(URL, from: Array(self.URLMap.keys)) {
            let navigable = self.URLMap[URLPattern]
            return navigable?.init(URL: URL, values: values) as? UIViewController
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
        if let (URLPattern, values) = URLNavigator.matchURL(URL, from: Array(self.URLOpenHandlers.keys)) {
            let handler = self.URLOpenHandlers[URLPattern]
            if handler?(URL: URL, values: values) == true {
                return true
            }
        }
        return false
    }


    // MARK: Utils

    /// Returns the URL by
    ///
    /// - Removing redundant trailing slash(/) on scheme
    /// - Removing redundant double-slashes(//)
    /// - Removing trailing slash(/)
    ///
    /// - Parameter URL: The dirty URL to be normalized.
    ///
    /// - Returns: The normalized URL. Returns `nil` if the pecified URL is invalid.
    static func normalizedURL(dirtyURL: URLConvertible) -> URLConvertible {
        guard dirtyURL.URLValue != nil else {
            return dirtyURL
        }

        var URLString = dirtyURL.URLStringValue.componentsSeparatedByString("?")[0].componentsSeparatedByString("#")[0]

        if (dirtyURL.URLValue?.scheme == nil || dirtyURL.URLValue?.scheme == "" ) && self.defaultSchemeString != nil{
            URLString = "\(self.defaultSchemeString!)://\(URLString)"
        }

        URLString = self.replaceRegex(":/{3,}", "://", URLString)
        URLString = self.replaceRegex("(?<!:)/{2,}", "/", URLString)
        URLString = self.replaceRegex("/+$", "", URLString)
        return URLString
    }

    static func placeholderKeyValueFromURLPatternPathComponent(component: String,
                                                               URLPathComponents: [String],
                                                               atIndex index: Int) -> (String, AnyObject)? {
        guard component.hasPrefix("<") && component.hasSuffix(">") else {
            return nil
        }

        let start = component.startIndex.advancedBy(1)
        let end = component.endIndex.advancedBy(-1)
        let placeholder = component[start..<end] // e.g. "<int:id>" -> "int:id"

        let typeAndKey = placeholder.componentsSeparatedByString(":") // e.g. ["int", "id"]
        if typeAndKey.count == 0 { // e.g. component is "<>"
            return nil
        }
        if typeAndKey.count == 1 { // untyped placeholder
            return (placeholder, URLPathComponents[index])
        }

        let (type, key) = (typeAndKey[0], typeAndKey[1]) // e.g. ("int", "id")
        let value: AnyObject?
        switch type {
        case "int": value = Int(URLPathComponents[index]) // e.g. 123
        case "float": value = Float(URLPathComponents[index]) // e.g. 123.0
        case "path": value = URLPathComponents[index..<URLPathComponents.count].joinWithSeparator("/")
        default: value = URLPathComponents[index]
        }

        if let value = value {
            return (key, value)
        }
        return nil
    }

    static func replaceRegex(pattern: String, _ repl: String, _ string: String) -> String {
        guard let regex = try? NSRegularExpression(pattern: pattern, options: []) else {
            return string
        }
        let mutableString = NSMutableString(string: string)
        let range = NSMakeRange(0, string.characters.count)
        regex.replaceMatchesInString(mutableString, options: [], range: range, withTemplate: repl)
        return mutableString as String
    }

}


// MARK: - Default Navigator

public let Navigator = URLNavigator.defaultNavigator()
