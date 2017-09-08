//
//  TopMostViewControllerTests.swift
//  URLNavigator
//
//  Created by Suyeol Jeon on 10/08/2017.
//  Copyright © 2017 Suyeol Jeon. All rights reserved.
//

#if os(iOS) || os(tvOS)
import XCTest
import URLNavigator

private var currentWindow: UIWindow?

extension UIViewController {
  convenience init(_ title: String) {
    self.init()
    self.title = title
  }

  override open var description: String {
    let title = self.title ?? String(format: "0x%x", self)
    return "<\(type(of: self)): \(title)>"
  }

  @discardableResult
  fileprivate func asRoot() -> Self {
    currentWindow?.rootViewController = self
    currentWindow?.addSubview(self.view)
    return self
  }
}

final class TopMostViewControllerTests: XCTestCase {
  var window: UIWindow!
  var topMost: UIViewController? {
    return UIViewController.topMost(of: self.window.rootViewController)
  }

  override func setUp() {
    self.window = UIWindow(frame: UIScreen.main.bounds)
    currentWindow = self.window
    super.setUp()
  }


  // MARK: UIViewController

  func testViewController_single() {
    let viewController = UIViewController().asRoot()
    XCTAssertEqual(self.topMost, viewController)
  }

  func testViewController_present() {
    let A = UIViewController("A").asRoot()
    let B = UIViewController("B")
    A.present(B, animated: false, completion: nil)
    XCTAssertEqual(self.topMost, B)
  }

  func testViewController_presentTabBarController() {
    let A = UIViewController("A").asRoot()
    let B = UIViewController("B")
    let C = UIViewController("C")
    let tabBarController = UITabBarController()
    tabBarController.viewControllers = [B, C]
    tabBarController.selectedIndex = 1
    A.present(tabBarController, animated: false, completion: nil)
    XCTAssertEqual(self.topMost, C)
  }

  func testViewController_presentNavigationController() {
    let A = UIViewController("A").asRoot()
    let B = UIViewController("B")
    let C = UIViewController("C")
    let D = UIViewController("D")
    let navigationController = UINavigationController(rootViewController: B)
    navigationController.pushViewController(C, animated: false)
    navigationController.pushViewController(D, animated: false)
    A.present(navigationController, animated: false, completion: nil)
    XCTAssertEqual(self.topMost, D)
  }

  func testViewController_presentPageViewController() {
    let A = UIViewController("A").asRoot()
    let B = UIViewController("B")
    let pageViewController = UIPageViewController()
    pageViewController.setViewControllers([B], direction: .forward, animated: false, completion: nil)
    A.present(pageViewController, animated: false, completion: nil)
    XCTAssertEqual(self.topMost, B)
  }


  // MARK: UITabBarController

  func testTabBarController_noViewControllers() {
    let tabBarController = UITabBarController().asRoot()
    XCTAssertEqual(self.topMost, tabBarController)
  }

  func testTabBarController_singleViewController() {
    let A = UIViewController("A")
    let tabBarController = UITabBarController().asRoot()
    tabBarController.viewControllers = [A]
    XCTAssertEqual(self.topMost, A)
  }

  func testTabBarController_multipleViewController() {
    let A = UIViewController("A")
    let B = UIViewController("B")
    let C = UIViewController("C")
    let tabBarController = UITabBarController().asRoot()
    tabBarController.viewControllers = [A, B, C]
    tabBarController.selectedIndex = 1
    XCTAssertEqual(self.topMost, B)
  }

  func testTabBarController_present() {
    let A = UIViewController("A")
    let B = UIViewController("B")
    let C = UIViewController("C")
    let tabBarController = UITabBarController().asRoot()
    tabBarController.viewControllers = [A, B, C]
    tabBarController.selectedIndex = 2
    let D = UIViewController("D")
    C.present(D, animated: false, completion: nil)
    XCTAssertEqual(self.topMost, D)
  }


  // MARK: UINavigationController

  func testNavigationController_noViewControllers() {
    let navigationController = UINavigationController().asRoot()
    XCTAssertEqual(self.topMost, navigationController)
  }

  func testNavigationController_rootViewControllerOnly() {
    let A = UIViewController("A")
    UINavigationController(rootViewController: A).asRoot()
    XCTAssertEqual(self.topMost, A)
  }

  func testNavigationController_multipleViewController() {
    let A = UIViewController("A")
    let B = UIViewController("B")
    let navigationController = UINavigationController(rootViewController: A).asRoot()
    navigationController.pushViewController(B, animated: false)
    XCTAssertEqual(self.topMost, B)
  }

  func testNavigationController_present() {
    let A = UIViewController("A")
    let B = UIViewController("B")
    let C = UIViewController("C")
    let navigationController = UINavigationController(rootViewController: A).asRoot()
    navigationController.pushViewController(B, animated: false)
    navigationController.pushViewController(C, animated: false)
    let D = UIViewController("D")
    C.present(D, animated: false, completion: nil)
    XCTAssertEqual(self.topMost, D)
  }


  // MARK: UIPageViewController

  func testPageViewController() {
    let A = UIViewController("A")
    let pageViewController = UIPageViewController().asRoot()
    pageViewController.setViewControllers([A], direction: .forward, animated: false, completion: nil)
    XCTAssertEqual(self.topMost, A)
  }

  func testPageViewController_present() {
    let A = UIViewController("A")
    let B = UIViewController("B")
    let pageViewController = UIPageViewController().asRoot()
    pageViewController.setViewControllers([A], direction: .forward, animated: false, completion: nil)
    A.present(B, animated: false, completion: nil)
    XCTAssertEqual(self.topMost, B)
  }
}
#endif
