#if os(iOS) || os(tvOS)
import XCTest

import URLNavigator

final class TopMostViewControllerTests: XCTestCase {
  fileprivate static var currentWindow: UIWindow?

  var window: UIWindow!
  var topMost: UIViewController? {
    UIViewController.topMost(of: window.rootViewController)
  }

  override func setUp() {
    super.setUp()

    window = UIWindow(frame: UIScreen.main.bounds)
    Self.currentWindow = window
  }

  func test_returns_root_view_controller_when_there_is_only_a_root_view_controller() {
    // given
    let viewController = UIViewController().asRoot()

    // then
    XCTAssertIdentical(topMost, viewController)
  }

  func test_returns_a_presented_view_controller_when_there_is_a_presented_view_controller() {
    // given
    let A = UIViewController("A").asRoot()
    let B = UIViewController("B")

    A.present(B, animated: false, completion: nil)

    // then
    XCTAssertIdentical(topMost, B)
  }

  func test_returns_the_selected_view_controller_of_the_presented_tab_bar_controller() {
    // given
    let A = UIViewController("A").asRoot()
    let B = UIViewController("B")
    let C = UIViewController("C")

    let tabBarController = UITabBarController()
    tabBarController.viewControllers = [B, C]
    tabBarController.selectedIndex = 1

    A.present(tabBarController, animated: false, completion: nil)

    // then
    XCTAssertIdentical(topMost, C)
  }

  func test_returns_a_top_view_controller_of_the_presented_navigation_controller() {
    // given
    let A = UIViewController("A").asRoot()
    let B = UIViewController("B")
    let C = UIViewController("C")
    let D = UIViewController("D")

    let navigationController = UINavigationController(rootViewController: B)
    navigationController.pushViewController(C, animated: false)
    navigationController.pushViewController(D, animated: false)

    A.present(navigationController, animated: false, completion: nil)

    // then
    XCTAssertIdentical(topMost, D)
  }

  func test_returns_the_selected_view_controller_of_the_presented_page_view_controller() {
    // given
    let A = UIViewController("A").asRoot()
    let B = UIViewController("B")

    let pageViewController = UIPageViewController()
    pageViewController.setViewControllers([B], direction: .forward, animated: false, completion: nil)

    A.present(pageViewController, animated: false, completion: nil)

    // then
    XCTAssertIdentical(topMost, B)
  }

  func test_returns_the_tab_bar_controller_when_there_is_no_view_controller() {
    // given
    let tabBarController = UITabBarController().asRoot()

    // then
    XCTAssertIdentical(topMost, tabBarController)
  }

  func test_returns_the_only_view_controller_when_there_single_view_controller_in_tab_bar_controller() {
    // given

    let A = UIViewController("A")

    let tabBarController = UITabBarController().asRoot()
    tabBarController.viewControllers = [A]

    // then
    XCTAssertIdentical(topMost, A)
  }

  func test_returns_the_selected_view_controller_of_the_tab_bar_controller() {
    // given
    let A = UIViewController("A")
    let B = UIViewController("B")
    let C = UIViewController("C")

    let tabBarController = UITabBarController().asRoot()
    tabBarController.viewControllers = [A, B, C]
    tabBarController.selectedIndex = 1

    // then
    XCTAssertIdentical(topMost, B)
  }

  func test_returns_the_presented_view_controller_when_it__presented_from_tab_bar_controller() {
    // given
    let A = UIViewController("A")
    let B = UIViewController("B")
    let C = UIViewController("C")

    let tabBarController = UITabBarController().asRoot()
    tabBarController.viewControllers = [A, B, C]
    tabBarController.selectedIndex = 2

    let D = UIViewController("D")
    C.present(D, animated: false, completion: nil)

    // then
    XCTAssertIdentical(topMost, D)
  }

  func test_returns_the_navigation_controller_when_ther_is_no_view_controller_in_navigation_controller() {
    // given
    let navigationController = UINavigationController().asRoot()

    // then
    XCTAssertIdentical(topMost, navigationController)
  }

  func test_returns_the_root_view_controller_of_the_navigation_controller() {
    // given
    let A = UIViewController("A")

    UINavigationController(rootViewController: A).asRoot()

    // then
    XCTAssertIdentical(topMost, A)
  }

  func test_returns_the_top_view_controller_of_the_navigation_controller() {
    // given
    let A = UIViewController("A")
    let B = UIViewController("B")

    let navigationController = UINavigationController(rootViewController: A).asRoot()
    navigationController.pushViewController(B, animated: false)

    // then
    XCTAssertIdentical(topMost, B)
  }

  func test_returns_the_presented_view_controller_when_it_presented_from_navigation_controller() {
    // given
    let A = UIViewController("A")
    let B = UIViewController("B")
    let C = UIViewController("C")

    let navigationController = UINavigationController(rootViewController: A).asRoot()
    navigationController.pushViewController(B, animated: false)
    navigationController.pushViewController(C, animated: false)

    let D = UIViewController("D")
    C.present(D, animated: false, completion: nil)

    // then
    XCTAssertIdentical(topMost, D)
  }

  func test_returns_the_visible_view_controller_when_there_is_a_view_controller_in_page_view_controller() {
    // given
    let A = UIViewController("A")
    let pageViewController = UIPageViewController().asRoot()

    pageViewController.setViewControllers([A], direction: .forward, animated: false, completion: nil)

    // then
    XCTAssertIdentical(topMost, A)
  }

  func test_returns_the_presented_view_controller_from_page_view_controller() {
    // given
    let A = UIViewController("A")
    let B = UIViewController("B")

    let pageViewController = UIPageViewController().asRoot()
    pageViewController.setViewControllers([A], direction: .forward, animated: false, completion: nil)

    A.present(B, animated: false, completion: nil)

    // then
    XCTAssertIdentical(topMost, B)
  }
}


// MARK: - Test

extension UIViewController {
  fileprivate convenience init(_ title: String) {
    self.init()
    self.title = title
  }

  @discardableResult
  fileprivate func asRoot() -> Self {
    TopMostViewControllerTests.currentWindow?.rootViewController = self
    TopMostViewControllerTests.currentWindow?.addSubview(view)
    return self
  }
}
#endif
