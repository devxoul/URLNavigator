URLNavigator
============

![Swift](https://img.shields.io/badge/Swift-2.1-orange.svg)
[![Build Status](https://travis-ci.org/devxoul/URLNavigator.svg)](https://travis-ci.org/devxoul/URLNavigator)
[![CocoaPods](http://img.shields.io/cocoapods/v/URLNavigator.svg)](https://cocoapods.org/pods/URLNavigator)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)

⛵️ URLNavigator provides an elegant way to navigate through view controllers by URLs. URL patterns can be mapped by using `URLNavigator.map(_:_:)` function.

URLNavigator can be used for mapping URL patterns with 2 kind of types: `URLNavigable` and `URLOpenHandler`. `URLNavigable` is a type which defines an custom initializer and `URLOpenHandler` is a closure which can be executed. Both an initializer and a closure receive an URL and placeholder values.


At a Glance
-----------

#### Mapping URL Patterns

URL patterns can contain placeholders. Placeholders will be replaced with matching values from URLs. Use `<` and `>` to make placeholders.

Here's an example of mapping URL patterns with view controllers and a closure. View controllers should conform a protocol `URLNavigable` to be mapped with URL patterns. See [Implementing URLNavigable](#implementing-urlnavigable) section for details.

```swift
Navigator.map("myapp://user/<id>", UserViewController.self)
Navigator.map("myapp://post/<id>", PostViewController.self)

Navigator.map("myapp://alert") { URL, values in
    print(URL.parameters["title"])
    print(URL.parameters["message"])
    return true
}
```

> **Note**: Global constant `Navigator` is a shortcut for `URLNavigator.defaultNavigator()`.

#### Pushing, Presenting and Opening URLs

URLNavigator can push and present view controllers and execute closures with URLs.

Provide the `from` parameter to `pushURL()` to specify the navigation controller which the new view controller will be pushed. Similarly, provide the `from` parameter to `presentURL()` to specify the view controller which the new view controller will be presented. If the `nil` is passed, which is a default value, current application's top most view controller will be used to push or present view controllers.

`presentURL()` takes an extra parameter: `wrap`. If `true` is specified, the new view controller will be wrapped with a `UINavigationController`. Default value is `false`.

```swift
Navigator.pushURL("myapp://user/123")
Navigator.presentURL("myapp://post/54321", wrap: true)

Navigator.openURL("myapp://alert?title=Hello&message=World")
```

#### Implementing URLNavigable

View controllers should conform a protocol `URLNavigable` to be mapped with URLs. A protocol `URLNavigable` defines an failable initializer with parameter: `URL` and `values`.

Parameter `URL` is an URL that is passed from `URLNavigator.pushURL()` and `URLNavigator.presentURL()`. Parameter `values` is a dictionary that contains URL placeholder keys and values.

```swift
class UserViewController: UIViewController, URLNavigable {

    convenience init?(URL: URLStringConvertible, values: [String : AnyObject]) {
        // User id from URL placeholder is required!
        guard let userID = values["id"]?.integerValue where id > 0 else {
            return nil
        }
        self.init()
    }

}
```


Installation
------------

- **For iOS 8+ projects** with [CocoaPods](https://cocoapods.org):

    ```ruby
    pod 'URLNavigator', '~> 0.2'
    ```

- **For iOS 8+ projects** with [Carthage](https://github.com/Carthage/Carthage):

    ```
    github "devxoul/URLNavigator" ~> 0.2
    ```

- **For iOS 7 projects** with [CocoaSeeds](https://github.com/devxoul/CocoaSeeds):

    ```ruby
    github 'devxoul/URLNavigator', '0.2.0', :files => 'Sources/*.swift'
    ```

- **Using [Swift Package Manager](https://swift.org/package-manager)**:

    ```swift
    import PackageDescription

    let package = Package(
        name: "MyAwesomeApp",
        dependencies: [
            .Package(url: "https://github.com/devxoul/URLNavigator", "0.2.0"),
        ]
    )
    ```
    

Tips and Tricks
---------------

#### Where to Map URLs

I'd prefer using separated URL map file.

```swift
struct URLNavigationMap {

    static func initialize() {
        Navigator.map("myapp://user/<id>", UserViewController.self)
        Navigator.map("myapp://post/<id>", PostViewController.self)

        Navigator.map("myapp://alert") { URL, values in
            print(URL.parameters["title"])
            print(URL.parameters["message"])
            self.someUtilityMethod()
            return true
        }
    }

    private static func someUtilityMethod() {
        print("This method is really useful")
    }

}
```

Then call `initialize()` at `AppDelegate`'s `application:didFinishLaunchingWithOptions:`.

```swift
@UIApplicationMain
final class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Navigator
        URLNavigationMap.initialize()
        
        // Do something else...
    }
}
```


#### Implementing AppDelegate Launch Option URL

It is available to open your app if custom schemes are registered. In this case, you'll have to implement `application:didFinishLaunchingWithOptions:` method to navigate to URL.

```swift
func application(application: UIApplication,
                 didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
    // ...

    if let URL = launchOptions?[UIApplicationLaunchOptionsURLKey] as? NSURL {
        self.window?.rootViewController = Navigator.viewControllerForURL(URL)
    }
    return true
}

```


#### Implementing AppDelegate Open URL Method

You'll might want to implement custom URL open handler. Here's an example of using URLNavigator with other URL open handlers.

```swift
func application(application: UIApplication,
                 openURL url: NSURL,
                 sourceApplication: String?,
                 annotation: AnyObject) -> Bool {
    // If you're using Facebook SDK
    let fb = FBSDKApplicationDelegate.sharedInstance()
    if fb.application(application, openURL: url, sourceApplication: sourceApplication, annotation: annotation) {
        return true
    }

    // URLNavigator Handler
    if Navigator.openURL(url) {
        return true
    }

    // URLNavigator View Controller
    if Navigator.presentURL(url, wrap: true) != nil {
        return true
    }

    return false
}
```


License
-------

URLNavigator is under MIT license. See the [LICENSE](LICENSE) file for more info.
