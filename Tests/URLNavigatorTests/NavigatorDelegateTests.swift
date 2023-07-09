#if os(iOS) || os(tvOS)
import UIKit
import XCTest

import URLNavigator

final class NavigatorDelegateTests: XCTestCase {

  private var delegate: NavigatorDelegateObject!

  override func setUp() {
    super.setUp()

    delegate = .init()
  }

  func test_shouldPush_returns_true_as_default() {
    // given
    let result = delegate.shouldPush(viewController: UIViewController(), from: UINavigationController())

    // then
    XCTAssertTrue(result)
  }

  func test_shouldPresent_returns_true_as_default() {
    // given
    let result = delegate.shouldPresent(viewController: UIViewController(), from: UIViewController())

    // then
    XCTAssertTrue(result)
  }
}

fileprivate final class NavigatorDelegateObject: NavigatorDelegate {}
#endif
