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

#if os(iOS) || os(tvOS)
import XCTest
import URLNavigator

class URLNavigatorPublicTests: XCTestCase {
  var navigator: URLNavigator!

  override func setUp() {
    super.setUp()
    self.navigator = URLNavigator()
  }

  func testDefaultNavigator() {
    XCTAssert(URLNavigator.default === Navigator)
  }

  func testViewControllerForURL() {
    self.navigator.map("myapp://user/<int:id>", UserViewController.self)
    self.navigator.map("myapp://post/<title>", PostViewController.self)
    self.navigator.map("myapp://search", SearchViewController.self)
    self.navigator.map("myapp://modal", ModalNavigationController.self)
    self.navigator.map("http://<path:_>", WebViewController.self)
    self.navigator.map("https://<path:_>", WebViewController.self)

    XCTAssertNil(self.navigator.viewController(for: "myapp://user/"))
    XCTAssertNil(self.navigator.viewController(for: "myapp://user/awesome"))
    XCTAssert(self.navigator.viewController(for: "myapp://user/1") is UserViewController)

    XCTAssertNil(self.navigator.viewController(for: "myapp://post/"))
    XCTAssert(self.navigator.viewController(for: "myapp://post/123") is PostViewController)
    XCTAssert(self.navigator.viewController(for: "myapp://post/hello-world") is PostViewController)

    XCTAssertNil(self.navigator.viewController(for: "myapp://search"))
    XCTAssertNil(self.navigator.viewController(for: "myapp://search?"))
    XCTAssertNil(self.navigator.viewController(for: "myapp://search?query"))
    XCTAssert(self.navigator.viewController(for: "myapp://search?query=") is SearchViewController)
    XCTAssertEqual(
      (self.navigator.viewController(for: "myapp://search?query=Hello") as! SearchViewController).query,
      "Hello"
    )

    XCTAssertNil(self.navigator.viewController(for: "myapp://modal"))
    XCTAssertNil(self.navigator.viewController(for: "myapp://modal?"))
    XCTAssertNil(self.navigator.viewController(for: "myapp://modal?title"))
    XCTAssertEqual(
      (self.navigator.viewController(for: "myapp://modal?title=HelloWorld") as! ModalNavigationController).viewControllers[0].title,
      "HelloWorld"
    )

    XCTAssert(self.navigator.viewController(for: "http://") is WebViewController)
    XCTAssert(self.navigator.viewController(for: "https://") is WebViewController)
    XCTAssert(self.navigator.viewController(for: "http://xoul.kr") is WebViewController)
    XCTAssert(self.navigator.viewController(for: "http://xoul.kr/resume") is WebViewController)
    XCTAssert(self.navigator.viewController(for: "http://google.com/search?q=URLNavigator") is WebViewController)
    XCTAssert(self.navigator.viewController(for: "http://google.com/search?q=URLNavigator") is WebViewController)
    XCTAssert(self.navigator.viewController(for: "http://google.com/search/?q=URLNavigator") is WebViewController)
  }

  func testViewControllerForURL_mappingContext() {
    self.navigator.map("myapp://user/<int:id>", UserViewController.self, context: "TestContext")
    let viewController = self.navigator.viewController(for: "myapp://user/1") as! UserViewController
    XCTAssertEqual(viewController.mappingContext as? String, "TestContext")
  }

  func testPushURL_URLNavigable() {
    self.navigator.map("myapp://user/<int:id>", UserViewController.self)
    let navigationController = UINavigationController(rootViewController: UIViewController())
    let viewController = self.navigator.push("myapp://user/1", from: navigationController, animated: false)
    XCTAssertNotNil(viewController)
    XCTAssertEqual(navigationController.viewControllers.count, 2)
  }

  func testPushURL_context() {
    self.navigator.map("myapp://user/<int:id>", UserViewController.self)
    let navigationController = UINavigationController(rootViewController: UIViewController())
    let passedValue = "abcde"
    let passedObject = NSObject()
    let context: [AnyHashable: Any] = ["info": passedValue, "object": passedObject]
    let viewController = self.navigator.push("myapp://user/1", context: context, from: navigationController, animated: false) as! UserViewController
    XCTAssertNotNil(viewController)
    XCTAssertEqual(navigationController.viewControllers.count, 2)
    XCTAssertNotNil(viewController.navigationContext)
    let getedValue = viewController.navigationContext as! [String: Any]
    XCTAssertEqual(getedValue["info"] as! String, passedValue)
    XCTAssertEqual(getedValue["object"] as! NSObject, passedObject)
  }

  func testPushURL_URLOpenHandler() {
    self.navigator.map("myapp://ping") { _, _ in return true }
    let navigationController = UINavigationController(rootViewController: UIViewController())
    let viewController = self.navigator.push("myapp://ping", from: navigationController, animated: false)
    XCTAssertNil(viewController)
    XCTAssertEqual(navigationController.viewControllers.count, 1)
  }

  func testPushURL_navigationController() {
    self.navigator.map("myapp://modal", ModalNavigationController.self)
    let navigationController = UINavigationController(rootViewController: UIViewController())
    let viewController = self.navigator.push("myapp://modal?title=HelloWorld", from: navigationController, animated: false)
    XCTAssertNil(viewController)
  }

  func testPresentURL_URLNavigable() {
    self.navigator.map("myapp://user/<int:id>", UserViewController.self)
    ;{
      let fromViewController = UIViewController()
      let viewController = self.navigator.present("myapp://user/1", from: fromViewController)
      XCTAssertNotNil(viewController)
      XCTAssertNil(viewController?.navigationController)
    }();
    {
      let fromViewController = UIViewController()
      let viewController = self.navigator.present("myapp://user/1", wrap: true, from: fromViewController)
      XCTAssertNotNil(viewController)
      XCTAssertNotNil(viewController?.navigationController)
    }();
  }

  func testPresentURL_URLOpenHandler() {
    self.navigator.map("myapp://ping") { _, _ in return true }
    let fromViewController = UIViewController()
    let viewController = self.navigator.present("myapp://ping", from: fromViewController)
    XCTAssertNil(viewController)
  }

  func testPresentURL_userInfo() {
    self.navigator.map("myapp://user/<int:id>", UserViewController.self)
    let navigationController = UINavigationController(rootViewController: UIViewController())
    let passedValue = "abcde"
    let passedObject = NSObject()
    let context: [AnyHashable: Any] = ["info": passedValue, "object": passedObject]
    let viewController = self.navigator.present("myapp://user/1", context: context, wrap: true, from: navigationController, animated: false, completion: nil) as! UserViewController
    XCTAssertNotNil(viewController.navigationContext)
    let getedValue = viewController.navigationContext as! [String: Any]
    XCTAssertEqual(getedValue["info"] as! String, passedValue)
    XCTAssertEqual(getedValue["object"] as! NSObject, passedObject)
  }

  func testPresentURL_wrapNavigationController() {
    self.navigator.map("myapp://modal", ModalNavigationController.self)
    let presentingViewController = UIViewController()
    let viewController = self.navigator.present("myapp://modal?title=HelloWorld", wrap: true, from: presentingViewController, animated: false, completion: nil)
    XCTAssertTrue(viewController is MyNavigationController)
  }

  func testOpenURL_URLOpenHandler() {
    self.navigator.map("myapp://ping") { URL, values in
      NotificationCenter.default.post(name: .init("Ping"), object: nil, userInfo: nil)
      return true
    }
    self.expectation(forNotification: .init(rawValue: "Ping"), object: nil, handler: nil)
    XCTAssertTrue(self.navigator.open("myapp://ping"))
    self.waitForExpectations(timeout: 1, handler: nil)
  }

  func testOpenURL_URLNavigable() {
    self.navigator.map("myapp://user/<id>", UserViewController.self)
    XCTAssertFalse(self.navigator.open("myapp://user/1"))
  }


  // MARK: Scheme

  func testSetScheme() {
    self.navigator.scheme = "myapp"
    XCTAssertEqual(self.navigator.scheme, "myapp")
    self.navigator.scheme = "myapp://"
    XCTAssertEqual(self.navigator.scheme, "myapp")
    self.navigator.scheme = "myapp://123123123"
    XCTAssertEqual(self.navigator.scheme, "myapp")
    self.navigator.scheme = "myapp://://"
    XCTAssertEqual(self.navigator.scheme, "myapp")
    self.navigator.scheme = "myapp://://://123123"
    XCTAssertEqual(self.navigator.scheme, "myapp")
  }

  func testSchemeViewControllerForURL() {
    self.navigator.scheme = "myapp"

    self.navigator.map("/user/<int:id>", UserViewController.self)
    self.navigator.map("/post/<title>", PostViewController.self)
    self.navigator.map("http://<path:_>", WebViewController.self)
    self.navigator.map("https://<path:_>", WebViewController.self)

    XCTAssertNil(self.navigator.viewController(for: "/user/"))
    XCTAssertNil(self.navigator.viewController(for: "/user/awesome"))
    XCTAssert(self.navigator.viewController(for: "/user/1") is UserViewController)

    XCTAssertNil(self.navigator.viewController(for: "/post/"))
    XCTAssert(self.navigator.viewController(for: "/post/123") is PostViewController)
    XCTAssert(self.navigator.viewController(for: "/post/hello-world") is PostViewController)

    XCTAssert(self.navigator.viewController(for: "http://") is WebViewController)
    XCTAssert(self.navigator.viewController(for: "https://") is WebViewController)
    XCTAssert(self.navigator.viewController(for: "http://xoul.kr") is WebViewController)
    XCTAssert(self.navigator.viewController(for: "http://xoul.kr/resume") is WebViewController)
    XCTAssert(self.navigator.viewController(for: "http://google.com/search?q=URLNavigator") is WebViewController)
    XCTAssert(self.navigator.viewController(for: "http://google.com/search?q=URLNavigator") is WebViewController)
    XCTAssert(self.navigator.viewController(for: "http://google.com/search/?q=URLNavigator") is WebViewController)
  }

  func testSchemePushURL_URLNavigable() {
    self.navigator.scheme = "myapp"
    self.navigator.map("/user/<int:id>", UserViewController.self)
    let navigationController = UINavigationController(rootViewController: UIViewController())
    let viewController = self.navigator.push("/user/1", from: navigationController, animated: false)
    XCTAssertNotNil(viewController)
    XCTAssertEqual(navigationController.viewControllers.count, 2)
  }

  func testSchemePushURL_URLOpenHandler() {
    self.navigator.scheme = "myapp"
    self.navigator.map("/ping") { _, _ in return true }
    let navigationController = UINavigationController(rootViewController: UIViewController())
    let viewController = self.navigator.push("/ping", from: navigationController, animated: false)
    XCTAssertNil(viewController)
    XCTAssertEqual(navigationController.viewControllers.count, 1)
  }

  func testSchemePresentURL_URLNavigable() {
    self.navigator.scheme = "myapp"
    self.navigator.map("/user/<int:id>", UserViewController.self)
    ;{
      let fromViewController = UIViewController()
      let viewController = self.navigator.present("/user/1", from: fromViewController)
      XCTAssertNotNil(viewController)
      XCTAssertNil(viewController?.navigationController)
    }();
    {
      let fromViewController = UIViewController()
      let viewController = self.navigator.present("/user/1", wrap: true, from: fromViewController)
      XCTAssertNotNil(viewController)
      XCTAssertNotNil(viewController?.navigationController)
    }();
  }

  func testSchemePresentURL_URLOpenHandler() {
    self.navigator.scheme = "myapp"
    self.navigator.map("/ping") { _, _ in return true }
    let fromViewController = UIViewController()
    let viewController = self.navigator.present("/ping", from: fromViewController)
    XCTAssertNil(viewController)
  }

  func testSchemeOpenURL_URLOpenHandler() {
    self.navigator.scheme = "myapp"
    self.navigator.map("/ping") { URL, values in
      NotificationCenter.default.post(name: .init("Ping"), object: nil, userInfo: nil)
      return true
    }
    self.expectation(forNotification: .init("Ping"), object: nil, handler: nil)
    XCTAssertTrue(self.navigator.open("/ping"))
    self.waitForExpectations(timeout: 1, handler: nil)
  }

  func testSchemeOpenURL_URLNavigable() {
    self.navigator.scheme = "myapp"
    self.navigator.map("/user/<id>", UserViewController.self)
    XCTAssertFalse(self.navigator.open("/user/1"))
  }
}

private class UserViewController: UIViewController, URLNavigable {
  var userID: Int?
  var mappingContext: Any?
  var navigationContext: Any?

  init(userID: Int) {
    self.userID = userID
    super.init(nibName: nil, bundle: nil)
  }

  convenience required init?(navigation: Navigation) {
    guard let id = navigation.values["id"] as? Int else {
      return nil
    }
    self.init(userID: id)
    self.mappingContext = navigation.mappingContext
    self.navigationContext = navigation.navigationContext
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

private class PostViewController: UIViewController, URLNavigable {
  var postTitle: String?

  convenience required init?(navigation: Navigation) {
    guard let title = navigation.values["title"] as? String else {
      return nil
    }
    self.init()
    self.postTitle = title
  }
}

private class WebViewController: UIViewController, URLNavigable {
  var url: URLConvertible?

  convenience required init?(navigation: Navigation) {
    self.init()
    self.url = navigation.url
  }
}

private class SearchViewController: UIViewController, URLNavigable {
  let query: String

  init(query: String) {
    self.query = query
    super.init(nibName: nil, bundle: nil)
  }

  convenience required init?(navigation: Navigation) {
    guard let query = navigation.url.queryParameters["query"] else {
      return nil
    }
    self.init(query: query)
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}


private class MyNavigationController: UINavigationController {
}

private class ModalNavigationController: MyNavigationController, URLNavigable {
  init(title: String) {
    let viewController = UIViewController()
    viewController.title = title
    super.init(rootViewController: viewController)
  }

  override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
    super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
  }

  override init(rootViewController: UIViewController) {
    super.init(rootViewController: rootViewController)
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  convenience required init?(navigation: Navigation) {
    guard let title = navigation.url.queryParameters["title"] else { return nil }
    self.init(title: title)
  }
}
#endif
