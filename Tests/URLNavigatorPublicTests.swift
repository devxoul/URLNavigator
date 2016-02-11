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
        self.navigator.map("myapp://user/<id>", UserViewController.self)
        self.navigator.map("myapp://post/<id>", PostViewController.self)

        XCTAssertNil(self.navigator.viewControllerForURL("myapp://user/"))
        XCTAssertNil(self.navigator.viewControllerForURL("myapp://user/awesome"))
        XCTAssert(self.navigator.viewControllerForURL("myapp://user/1") is UserViewController)

        XCTAssertNil(self.navigator.viewControllerForURL("myapp://post/"))
        XCTAssert(self.navigator.viewControllerForURL("myapp://post/123") is PostViewController)
    }

    func testPushURL_URLNavigable() {
        self.navigator.map("myapp://user/<id>", UserViewController.self)
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
        self.navigator.map("myapp://user/<id>", UserViewController.self)
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

    convenience required init?(URL: URLStringConvertible, values: [String : AnyObject]) {
        guard let id = values["id"]?.integerValue where id > 0 else {
            return nil
        }
        self.init()
        self.userID = id
    }

}

private class PostViewController: UIViewController, URLNavigable {

    var postID: Int?

    convenience required init?(URL: URLStringConvertible, values: [String : AnyObject]) {
        guard let id = values["id"]?.integerValue where id > 0 else {
            return nil
        }
        self.init()
        self.postID = id
    }
    
}
