URLNavigator
============

![Swift](https://img.shields.io/badge/Swift-3.0-orange.svg)
[![CocoaPods](http://img.shields.io/cocoapods/v/URLNavigator.svg)](https://cocoapods.org/pods/URLNavigator)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![Build Status](https://travis-ci.org/devxoul/URLNavigator.svg?branch=master)](https://travis-ci.org/devxoul/URLNavigator)
[![CodeCov](https://img.shields.io/codecov/c/github/devxoul/URLNavigator.svg)](https://codecov.io/gh/devxoul/URLNavigator)
[![CocoaDocs](https://img.shields.io/cocoapods/metrics/doc-percent/URLNavigator.svg)](http://cocoadocs.org/docsets/URLNavigator/)

⛵️ URLNavigator provides an elegant way to navigate through view controllers by URLs. URL patterns can be mapped by using `URLNavigator.map(_:_:)` function.

URLNavigator can be used for mapping URL patterns with 2 kind of types: `URLNavigable` and `URLOpenHandler`. `URLNavigable` is a type which defines an custom initializer and `URLOpenHandler` is a closure which can be executed. Both an initializer and a closure receive an URL and placeholder values.


Getting Started
---------------

#### 1. Mapping URL Patterns

URL patterns can contain placeholders. Placeholders will be replaced with matching values from URLs. Use `<` and `>` to make placeholders. Placeholders can have types: `string`(default), `int`, `float`, and `path`.

Here's an example of mapping URL patterns with view controllers and a closure. View controllers should conform a protocol `URLNavigable` to be mapped with URL patterns. See [Implementing URLNavigable](#implementing-urlnavigable) section for details.

```swift
Navigator.map("myapp://user/<int:id>", UserViewController.self)
Navigator.map("myapp://post/<title>", PostViewController.self)

Navigator.map("myapp://alert") { url, values in
  print(url.queryParameters["title"])
  print(url.queryParameters["message"])
  return true
}
```

> **Note**: Global constant `Navigator` is a shortcut for `URLNavigator.default`.

#### 2. Pushing, Presenting and Opening URLs

URLNavigator can push and present view controllers and execute closures with URLs.

Provide the `from` parameter to `push()` to specify the navigation controller which the new view controller will be pushed. Similarly, provide the `from` parameter to `present()` to specify the view controller which the new view controller will be presented. If the `nil` is passed, which is a default value, current application's top most view controller will be used to push or present view controllers.

`present()` takes an extra parameter: `wrap`. If `true` is specified, the new view controller will be wrapped with a `UINavigationController`. Default value is `false`.

```swift
Navigator.push("myapp://user/123")
Navigator.present("myapp://post/54321", wrap: true)

Navigator.open("myapp://alert?title=Hello&message=World")
```

For full documentation, see [URLNavigator Class Reference](http://cocoadocs.org/docsets/URLNavigator/1.2.0/Classes/URLNavigator.html).

#### 3. Implementing URLNavigable

View controllers should conform a protocol `URLNavigable` to be mapped with URLs. A protocol `URLNavigable` defines an failable initializer with parameter `navigation` which contains `url`, `values`, `mappingContext` and `navigationContext` as properties.

Property `url` is an URL that is passed from `URLNavigator.push()` and `URLNavigator.present()`. Parameter `values` is a dictionary that contains URL placeholder keys and values. Parameter `mappingContext` is a context passed from a `map()` function. Parameter `navigationContext` is a dictionary which contains extra values passed from `push()` or `present()`.

```swift
final class UserViewController: UIViewController, URLNavigable {

  init(userID: Int) {
    super.init(nibName: nil, bundle: nil)
    // Initialize here...
  }

  convenience init?(navigation: Navigation) {
    // Let's assume that the user id is required
    guard let userID = navigation.values["id"] as? Int else { return nil }
    self.init(userID: userID)
  }
    
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

}
```

> **Note**: `URLConvertible` is a protocol that `URL` and `String` conforms.


Installation
------------

- **For iOS 8+ projects** with [CocoaPods](https://cocoapods.org):

    ```ruby
    pod 'URLNavigator'
    ```

- **For iOS 8+ projects** with [Carthage](https://github.com/Carthage/Carthage):

    ```
    github "devxoul/URLNavigator"
    ```


Example
-------

You can find an example app [here](https://github.com/devxoul/URLNavigator/tree/master/Example).

1. Build and install the example app.
2. Open Safari app
3. Enter `navigator://user/devxoul` in the URL bar.
4. The example app will be launched.


Tips and Tricks
---------------

#### Where to Map URLs

I'd prefer using separated URL map file.

```swift
struct URLNavigationMap {

  static func initialize() {
    Navigator.map("myapp://user/<int:id>", UserViewController.self)
    Navigator.map("myapp://post/<title>", PostViewController.self)

    Navigator.map("myapp://alert") { url, values in
      print(url.queryParameters["title"])
      print(url.queryParameters["message"])
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

  func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?
  ) -> Bool {
    // Navigator
    URLNavigationMap.initialize()
    
    // Do something else...
  }
}
```


#### Implementing AppDelegate Launch Option URL

It's available to open your app with URLs if custom schemes are registered. In order to navigate to view controllers with URLs, you'll have to implement `application:didFinishLaunchingWithOptions:` method.

```swift
func application(
  _ application: UIApplication,
  didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?
) -> Bool {
  // ...
  if let url = launchOptions?[.url] as? URL {
    if let opened = Navigator.open(url)
    if !opened {
      Navigator.push(url)
    }
  }
  return true
}

```


#### Implementing AppDelegate Open URL Method

You'll might want to implement custom URL open handler. Here's an example of using URLNavigator with other URL open handlers.

```swift
func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
  // If you're using Facebook SDK
  let fb = FBSDKApplicationDelegate.sharedInstance()
  if fb.application(application, open: url, sourceApplication: sourceApplication, annotation: annotation) {
    return true
  }

  // URLNavigator Handler
  if Navigator.open(url) {
    return true
  }

  // URLNavigator View Controller
  if Navigator.present(url, wrap: true) != nil {
    return true
  }

  return false
}
```


#### Using with Storyboard

It's not yet available to initialize view controllers from Storyboard. However, you can map the closures alternatively.

```swift
Navigator.map("myapp://post/<int:id>") { url, values in
  guard let postID = values["id"] as? Int,
    let postViewController = UIStoryboard(name: "Main", bundle: nil).instantiateInitialViewController()
    else { return false }
  Navigator.push(postViewController)
  return true
}
```

Then use `Navigator.open()` instead of `Navigator.push()`:

```swift
Navigator.open("myapp://post/12345")
```


#### Setting Default Scheme

Set `scheme` property on `URLNavigator` instance to get rid of schemes in every URLs.

```swift
Navigator.scheme = "myapp"
Navigator.map("/user/<int:id>", UserViewController.self)
Navigator.push("/user/10")
```

This is totally equivalent to:

```swift
Navigator.map("myapp://user/<int:id>", UserViewController.self)
Navigator.push("myapp://user/10")
```

Setting `scheme` property will not affect other URLs that already have schemes.

```swift
Navigator.scheme = "myapp"
Navigator.map("/user/<int:id>", UserViewController.self) // `myapp://user/<int:id>`
Navigator.map("http://<path>", MyWebViewController.self) // `http://<path>`
```

#### Passing Context when Mapping

```swift
let context = Foo()
Navigator.map("myapp://user/10", UserViewController.self, context: context)
```


#### Passing Extra Values when Pushing or Presenting

```swift
let context: [AnyHashable: Any] = [
  "fromViewController": self
]
Navigator.push("myapp://user/10", context: context)
Navigator.present("myapp://user/10", context: context)
```


License
-------

URLNavigator is under MIT license. See the [LICENSE](LICENSE) file for more info.
