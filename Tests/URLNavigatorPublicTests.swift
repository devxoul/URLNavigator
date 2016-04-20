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
import URLNavigator

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
        self.navigator.map("http://<path:_>", WebViewController.self)
        self.navigator.map("https://<path:_>", WebViewController.self)

        XCTAssertNil(self.navigator.viewControllerForURL("myapp://user/"))
        XCTAssertNil(self.navigator.viewControllerForURL("myapp://user/awesome"))
        XCTAssert(self.navigator.viewControllerForURL("myapp://user/1") is UserViewController)

        XCTAssertNil(self.navigator.viewControllerForURL("myapp://post/"))
        XCTAssert(self.navigator.viewControllerForURL("myapp://post/123") is PostViewController)
        XCTAssert(self.navigator.viewControllerForURL("myapp://post/hello-world") is PostViewController)
        
        let pvc:PostViewController = self.navigator.viewControllerForURL("myapp://post/hello-world?param1=value1") as! PostViewController
        XCTAssert(pvc.postTitle == "hello-world")
        XCTAssert(pvc.queryParam == "value1")
        

        XCTAssertNil(self.navigator.viewControllerForURL("http://"))
        XCTAssertNil(self.navigator.viewControllerForURL("https://"))
        XCTAssert(self.navigator.viewControllerForURL("http://xoul.kr") is WebViewController)
        XCTAssert(self.navigator.viewControllerForURL("http://xoul.kr/resume") is WebViewController)
        XCTAssert(self.navigator.viewControllerForURL("http://google.com/search?q=URLNavigator") is WebViewController)
        XCTAssert(self.navigator.viewControllerForURL("http://google.com/search?q=URLNavigator") is WebViewController)
        XCTAssert(self.navigator.viewControllerForURL("http://google.com/search/?q=URLNavigator") is WebViewController)
    }
    
    func testDefaultScheme(){
        URLNavigator.defaultSchemeString = "myapp"
        
        self.navigator.map("myapp://user/<int:id>", UserViewController.self)
        self.navigator.map("/post/<title>", PostViewController.self)

        XCTAssertNil(self.navigator.viewControllerForURL("invalid://user/1"))
        XCTAssert(self.navigator.viewControllerForURL("myapp://user/1") is UserViewController)
        XCTAssert(self.navigator.viewControllerForURL("/user/1") is UserViewController)

        XCTAssert(self.navigator.viewControllerForURL("myapp://post/hello-world") is PostViewController)
        XCTAssert(self.navigator.viewControllerForURL("/post/hello-world") is PostViewController)

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
        self.navigator.map("myapp://ping") { URL, values in
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

}

private class UserViewController: UIViewController, URLNavigable {

    var userID: Int?

    convenience required init?(URL: URLConvertible, values: [String : AnyObject]) {
        guard let id = values["id"] as? Int else {
            return nil
        }
        self.init()
        self.userID = id
    }

}

private class PostViewController: UIViewController, URLNavigable {

    var postTitle: String?
    var queryParam: String?

    convenience required init?(URL: URLConvertible, values: [String : AnyObject]) {
        self.init()
        if let title = values["title"] as? String  {
            self.postTitle = title
        }
        if let param1 = values["param1"] as? String  {
            self.queryParam = param1
        }
    }
    
}

private class WebViewController: UIViewController, URLNavigable {

    var URL: URLConvertible?

    convenience required init?(URL: URLConvertible, values: [String : AnyObject]) {
        self.init()
        self.URL = URL
    }

}
