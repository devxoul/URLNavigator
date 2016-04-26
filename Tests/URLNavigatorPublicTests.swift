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

import XCTest
@testable import URLNavigator

class URLNavigatorPublicTests: XCTestCase {

    var navigator: URLNavigator!

    override func setUp() {
        super.setUp()
        self.navigator = URLNavigator()
    }

    func testDefaultNavigator() {
        XCTAssert(URLNavigator.defaultNavigator() === Navigator)
    }

    func testViewControllerForURL() {
        self.navigator.map("myapp://user/<int:id>", UserViewController.self)
        self.navigator.map("myapp://post/<title>", PostViewController.self)
        self.navigator.map("myapp://search", SearchViewController.self)
        self.navigator.map("http://<path:_>", WebViewController.self)
        self.navigator.map("https://<path:_>", WebViewController.self)

        XCTAssertNil(self.navigator.viewControllerForURL("myapp://user/"))
        XCTAssertNil(self.navigator.viewControllerForURL("myapp://user/awesome"))
        XCTAssert(self.navigator.viewControllerForURL("myapp://user/1") is UserViewController)

        XCTAssertNil(self.navigator.viewControllerForURL("myapp://post/"))
        XCTAssert(self.navigator.viewControllerForURL("myapp://post/123") is PostViewController)
        XCTAssert(self.navigator.viewControllerForURL("myapp://post/hello-world") is PostViewController)

        XCTAssertNil(self.navigator.viewControllerForURL("myapp://search"))
        XCTAssertNil(self.navigator.viewControllerForURL("myapp://search?"))
        XCTAssertNil(self.navigator.viewControllerForURL("myapp://search?query"))
        XCTAssert(self.navigator.viewControllerForURL("myapp://search?query=") is SearchViewController)
        XCTAssertEqual(
            (self.navigator.viewControllerForURL("myapp://search?query=Hello") as! SearchViewController).query,
            "Hello"
        )

        XCTAssertNil(self.navigator.viewControllerForURL("http://"))
        XCTAssertNil(self.navigator.viewControllerForURL("https://"))
        XCTAssert(self.navigator.viewControllerForURL("http://xoul.kr") is WebViewController)
        XCTAssert(self.navigator.viewControllerForURL("http://xoul.kr/resume") is WebViewController)
        XCTAssert(self.navigator.viewControllerForURL("http://google.com/search?q=URLNavigator") is WebViewController)
        XCTAssert(self.navigator.viewControllerForURL("http://google.com/search?q=URLNavigator") is WebViewController)
        XCTAssert(self.navigator.viewControllerForURL("http://google.com/search/?q=URLNavigator") is WebViewController)
    }
    
    func testViewControllerForURLWithViewFactory() {
        /// Class Factory

        self.navigator.map("myapp://user/<int:id>", URLNavigableWithClass(UserViewController.self))
        XCTAssert(self.navigator.viewControllerForURL("myapp://user/1") is UserViewController)

        
        self.navigator.map("myapp://user/<int:id>", UserViewController.self)
        XCTAssert(self.navigator.viewControllerForURL("myapp://user/1") is UserViewController)

        
        /// Storyboard Factory
        
        self.navigator.map("myapp://user/<int:id>", URLNavigableWithStoryboard("TestingStoryboard", identifier: "StoryboardIdentifier", bundle:NSBundle(forClass: self.dynamicType)))
        XCTAssertNotNil(self.navigator.viewControllerForURL("myapp://user/1"))
        XCTAssert(self.navigator.viewControllerForURL("myapp://user/1") is UserViewController)
        
        
        
        self.navigator.map("myapp://user/<int:id>", storyboard: "TestingStoryboard", identifier: "StoryboardIdentifier", bundle:NSBundle(forClass: self.dynamicType))
        XCTAssert(self.navigator.viewControllerForURL("myapp://user/1") is UserViewController)

        
        /// Block Factory
        
        self.navigator.map("myapp://user/<int:id>", URLNavigableWithBlock{ URL, values -> URLNavigable? in
            return UserViewController(URL:URL, values:values)
            })
        XCTAssertNil(self.navigator.viewControllerForURL("myapp://user/awesome"))
        XCTAssert(self.navigator.viewControllerForURL("myapp://user/1") is UserViewController)

        self.navigator.map("myapp://user/<int:id>"){ URL, values -> URLNavigable? in
            return UserViewController(URL:URL, values:values)
        }
        XCTAssertNil(self.navigator.viewControllerForURL("myapp://user/awesome"))
        XCTAssert(self.navigator.viewControllerForURL("myapp://user/1") is UserViewController)

        
    }

    func testPushURL_URLNavigable() {
        self.navigator.map("myapp://user/<int:id>", UserViewController.self)
        let navigationController = UINavigationController(rootViewController: UIViewController())
        let viewController = self.navigator.pushURL("myapp://user/1", from: navigationController, animated: false)
        XCTAssertNotNil(viewController)
        XCTAssertEqual(navigationController.viewControllers.count, 2)
    }

    func testPushURL_URLOpenHandler() {
        self.navigator.map("myapp://ping") { _ in return true }
        let navigationController = UINavigationController(rootViewController: UIViewController())
        let viewController = self.navigator.pushURL("myapp://ping", from: navigationController, animated: false)
        XCTAssertNil(viewController)
        XCTAssertEqual(navigationController.viewControllers.count, 1)
    }

    func testPresentURL_URLNavigable() {
        self.navigator.map("myapp://user/<int:id>", UserViewController.self)
        ;{
            let fromViewController = UIViewController()
            let viewController = self.navigator.presentURL("myapp://user/1", from: fromViewController)
            XCTAssertNotNil(viewController)
            XCTAssertNil(viewController?.navigationController)
        }();
        {
            let fromViewController = UIViewController()
            let viewController = self.navigator.presentURL("myapp://user/1", wrap: true, from: fromViewController)
            XCTAssertNotNil(viewController)
            XCTAssertNotNil(viewController?.navigationController)
        }();
    }

    func testPresentURL_URLOpenHandler() {
        self.navigator.map("myapp://ping") { _ in return true }
        let fromViewController = UIViewController()
        let viewController = self.navigator.presentURL("myapp://ping", from: fromViewController)
        XCTAssertNil(viewController)
    }

    func testOpenURL_URLOpenHandler() {
        self.navigator.map("myapp://ping") { URL, values -> Bool in
            NSNotificationCenter.defaultCenter().postNotificationName("Ping", object: nil, userInfo: nil)
            return true
        }
        self.expectationForNotification("Ping", object: nil, handler: nil)
        XCTAssertTrue(self.navigator.openURL("myapp://ping"))
        self.waitForExpectationsWithTimeout(1, handler: nil)
    }

    func testOpenURL_URLNavigable() {
        self.navigator.map("myapp://user/<id>", UserViewController.self)
        XCTAssertFalse(self.navigator.openURL("myapp://user/1"))
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

        XCTAssertNil(self.navigator.viewControllerForURL("/user/"))
        XCTAssertNil(self.navigator.viewControllerForURL("/user/awesome"))
        XCTAssert(self.navigator.viewControllerForURL("/user/1") is UserViewController)

        XCTAssertNil(self.navigator.viewControllerForURL("/post/"))
        XCTAssert(self.navigator.viewControllerForURL("/post/123") is PostViewController)
        XCTAssert(self.navigator.viewControllerForURL("/post/hello-world") is PostViewController)

        XCTAssertNil(self.navigator.viewControllerForURL("http://"))
        XCTAssertNil(self.navigator.viewControllerForURL("https://"))
        XCTAssert(self.navigator.viewControllerForURL("http://xoul.kr") is WebViewController)
        XCTAssert(self.navigator.viewControllerForURL("http://xoul.kr/resume") is WebViewController)
        XCTAssert(self.navigator.viewControllerForURL("http://google.com/search?q=URLNavigator") is WebViewController)
        XCTAssert(self.navigator.viewControllerForURL("http://google.com/search?q=URLNavigator") is WebViewController)
        XCTAssert(self.navigator.viewControllerForURL("http://google.com/search/?q=URLNavigator") is WebViewController)
    }

    func testSchemePushURL_URLNavigable() {
        self.navigator.scheme = "myapp"
        self.navigator.map("/user/<int:id>", UserViewController.self)
        let navigationController = UINavigationController(rootViewController: UIViewController())
        let viewController = self.navigator.pushURL("/user/1", from: navigationController, animated: false)
        XCTAssertNotNil(viewController)
        XCTAssertEqual(navigationController.viewControllers.count, 2)
    }

    func testSchemePushURL_URLOpenHandler() {
        self.navigator.scheme = "myapp"
        self.navigator.map("/ping") { _ in return true }
        let navigationController = UINavigationController(rootViewController: UIViewController())
        let viewController = self.navigator.pushURL("/ping", from: navigationController, animated: false)
        XCTAssertNil(viewController)
        XCTAssertEqual(navigationController.viewControllers.count, 1)
    }

    func testSchemePresentURL_URLNavigable() {
        self.navigator.scheme = "myapp"
        self.navigator.map("/user/<int:id>", UserViewController.self)
        ;{
            let fromViewController = UIViewController()
            let viewController = self.navigator.presentURL("/user/1", from: fromViewController)
            XCTAssertNotNil(viewController)
            XCTAssertNil(viewController?.navigationController)
        }();
        {
            let fromViewController = UIViewController()
            let viewController = self.navigator.presentURL("/user/1", wrap: true, from: fromViewController)
            XCTAssertNotNil(viewController)
            XCTAssertNotNil(viewController?.navigationController)
        }();
    }

    func testSchemePresentURL_URLOpenHandler() {
        self.navigator.scheme = "myapp"
        self.navigator.map("/ping") { _ in return true }
        let fromViewController = UIViewController()
        let viewController = self.navigator.presentURL("/ping", from: fromViewController)
        XCTAssertNil(viewController)
    }

    func testSchemeOpenURL_URLOpenHandler() {
        self.navigator.scheme = "myapp"
        self.navigator.map("/ping") { URL, values  -> Bool in
            NSNotificationCenter.defaultCenter().postNotificationName("Ping", object: nil, userInfo: nil)
            return true
        }
        self.expectationForNotification("Ping", object: nil, handler: nil)
        XCTAssertTrue(self.navigator.openURL("/ping"))
        self.waitForExpectationsWithTimeout(1, handler: nil)
    }

    func testSchemeOpenURL_URLNavigable() {
        self.navigator.scheme = "myapp"
        self.navigator.map("/user/<id>", UserViewController.self)
        XCTAssertFalse(self.navigator.openURL("/user/1"))
    }

}

public class UserViewController: UIViewController, URLNavigable {

    var userID: Int?

    convenience required public init?(URL: URLConvertible, values: [String : AnyObject]) {
        guard let id = values["id"] as? Int else {
            return nil
        }
        self.init()
        self.userID = id
    }

}

private class PostViewController: UIViewController, URLNavigable {

    var postTitle: String?

    convenience required init?(URL: URLConvertible, values: [String : AnyObject]) {
        guard let title = values["title"] as? String else {
            return nil
        }
        self.init()
        self.postTitle = title
    }
    
}

private class WebViewController: UIViewController, URLNavigable {

    var URL: URLConvertible?

    convenience required init?(URL: URLConvertible, values: [String : AnyObject]) {
        self.init()
        self.URL = URL
    }

}

private class SearchViewController: UIViewController, URLNavigable {

    let query: String

    init(query: String) {
        self.query = query
        super.init(nibName: nil, bundle: nil)
    }

    convenience required init?(URL: URLConvertible, values: [String: AnyObject]) {
        guard let query = URL.queryParameters["query"] else {
            return nil
        }
        self.init(query: query)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
