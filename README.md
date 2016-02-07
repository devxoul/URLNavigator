URLNavigator
============

⛵️ URLNavigator provides an elegant way to navigate through view controllers by URLs. URL patterns can be mapped by using `URLNavigator.map(_:_:)` function.

URLNavigator can be used for mapping URL patterns with 2 kind of types: `URLNavigable` and `URLOpenHandler`. `URLNavigable` is a type which defines an custom initializer and `URLOpenHandler` is a closure which can be executed. Both an initializer and a closure receive an URL and placeholder values.


At a Glance
-----------

#### Mapping URL Patterns

URL patterns can contain placeholders. Placeholders will be replaced with matching values from URLs. Use `{` and `}` to make placeholders.

Here's an example of mapping URL patterns with view controllers and a closure. View controllers should conform a protocol `URLNavigable` to be mapped with URL patterns. See [Implementing URLNavigable](#implementing-urlnavigable) section for details.

```swift
Navigator.map("myapp://user/{id}", UserViewController.self)
Navigator.map("myapp://post/{id}", PostViewController.self)

Navigator.map("myapp://alert") { URL, values in
    print(URL.parameters["title"])
    print(URL.parameters["message"])
    return true
}
```

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


License
-------

URLNavigable is under MIT license. See the [LICENSE](LICENSE) file for more info.
