#if os(iOS) || os(tvOS)
import UIKit
import XCTest

import URLNavigator

final class NavigatorTests: XCTestCase {

  var navigator: NavigatorProtocol!

  override func setUp() {
    super.setUp()
    navigator = Navigator()
  }
}


// MARK: - viewController(for:context:)

extension NavigatorTests {

  func test_viewController_returns_nil_when_there_is_no_registered_view_controller() {
    // given
    let viewController = navigator.viewController(for: "/article/123")

    // then
    XCTAssertNil(viewController)
  }

  func test_viewController_returns_nil_for_not_matching_url_when_there_is_a_registered_view_controller() {
    // given
    navigator.register("myapp://article/<int:id>") { url, values, context in
      guard let articleID = values["id"] as? Int, articleID > 0 else { return nil }
      return ArticleViewController(articleID: articleID, context: context)
    }

    let viewController = navigator.viewController(for: "/article/123")

    // then
    XCTAssertNil(viewController)
  }

  func test_viewController_returns_nil_for_not_matching_value_type_when_there_is_a_registered_view_controller() {
    // given
    navigator.register("myapp://article/<int:id>") { url, values, context in
      guard let articleID = values["id"] as? Int, articleID > 0 else { return nil }
      return ArticleViewController(articleID: articleID, context: context)
    }

    let viewController = navigator.viewController(for: "myapp://article/hello")

    // then
    XCTAssertNil(viewController)
  }

  func test_viewController_returns_nil_for_not_matching_factory_when_there_is_a_registered_view_controller() {
    // given
    navigator.register("myapp://article/<int:id>") { url, values, context in
      guard let articleID = values["id"] as? Int, articleID > 0 else { return nil }
      return ArticleViewController(articleID: articleID, context: context)
    }

    let viewController = navigator.viewController(for: "myapp://article/-1") as? ArticleViewController

    // then
    XCTAssertNil(viewController)
  }

  func test_viewController_returns_matching_view_controller_when_there_is_a_registered_view_controller() {
    // given
    navigator.register("myapp://article/<int:id>") { url, values, context in
      guard let articleID = values["id"] as? Int, articleID > 0 else { return nil }
      return ArticleViewController(articleID: articleID, context: context)
    }

    let viewController = navigator.viewController(for: "myapp://article/123") as? ArticleViewController

    // then
    XCTAssertNotNil(viewController)
    XCTAssertEqual(viewController?.articleID, 123)
    XCTAssertNil(viewController?.context)
  }

  func test_viewController_returns_matching_view_controller_with_a_context_when_there_is_a_registered_view_controller() {
    // given
    navigator.register("myapp://article/<int:id>") { url, values, context in
      guard let articleID = values["id"] as? Int, articleID > 0 else { return nil }
      return ArticleViewController(articleID: articleID, context: context)
    }

    let viewController = navigator.viewController(for: "myapp://article/123", context: "Hello") as? ArticleViewController

    // then
    XCTAssertNotNil(viewController)
    XCTAssertEqual(viewController?.articleID, 123)
    XCTAssertEqual(viewController?.context as? String, "Hello")
  }
}


// MARK: - push(url:context:from:animated:)

extension NavigatorTests {

  func test_pushes_a_view_controller_to_a_navigation_controller() {
    // given
    navigator.register("myapp://article/<int:id>") { url, values, context in
      guard let articleID = values["id"] as? Int, articleID > 0 else { return nil }
      return ArticleViewController(articleID: articleID, context: context)
    }

    let navigationController = StubNavigationController()

    // when
    let viewController = navigator.push("myapp://article/123", from: navigationController) as? ArticleViewController

    // then
    XCTAssertEqual(viewController?.articleID, 123)
    XCTAssertNil(viewController?.context)
  }

  func test_pushes_a_view_controller_to_a_navigation_controller_with_a_context() {
    // given
    navigator.register("myapp://article/<int:id>") { url, values, context in
      guard let articleID = values["id"] as? Int, articleID > 0 else { return nil }
      return ArticleViewController(articleID: articleID, context: context)
    }

    let navigationController = StubNavigationController()

    // when
    let viewController = navigator.push("myapp://article/123", context: 456, from: navigationController) as? ArticleViewController

    // then
    XCTAssertEqual(viewController?.articleID, 123)
    XCTAssertEqual(viewController?.context as? Int, 456)
  }

  func test_executes_pushViewController_with_default_arguments() {
    // given
    navigator.register("myapp://article/<int:id>") { url, values, context in
      guard let articleID = values["id"] as? Int, articleID > 0 else { return nil }
      return ArticleViewController(articleID: articleID, context: context)
    }

    let navigationController = StubNavigationController()

    // when
    navigator.push("myapp://article/123", from: navigationController)

    // then
    XCTAssertEqual(navigationController.pushViewControllerCallCount, 1)
    XCTAssertTrue(navigationController.pushViewControllerParams?.viewController is ArticleViewController)
    XCTAssertEqual(navigationController.pushViewControllerParams?.animated, true)
  }

  func test_executes_pushViewController_with_given_arguments() {
    // given
    navigator.register("myapp://article/<int:id>") { url, values, context in
      guard let articleID = values["id"] as? Int, articleID > 0 else { return nil }
      return ArticleViewController(articleID: articleID, context: context)
    }

    let navigationController = StubNavigationController()

    // when
    navigator.push("myapp://article/123", from: navigationController, animated: false)

    // then
    XCTAssertEqual(navigationController.pushViewControllerCallCount, 1)
    XCTAssertTrue(navigationController.pushViewControllerParams?.viewController is ArticleViewController)
    XCTAssertEqual(navigationController.pushViewControllerParams?.animated, false)
  }
}


// MARK: - present(url:context:wrap:from:animated:completion:)

extension NavigatorTests {

  func test_presents_a_view_controller() {
    // given
    navigator.register("myapp://article/<int:id>") { url, values, context in
      guard let articleID = values["id"] as? Int, articleID > 0 else { return nil }
      return ArticleViewController(articleID: articleID, context: context)
    }
    let rootViewController = StubViewController()

    // when
    let viewController = navigator.present("myapp://article/123", from: rootViewController) as? ArticleViewController

    // then
    XCTAssertEqual(viewController?.articleID, 123)
    XCTAssertNil(viewController?.context)
  }

  func test_presents_a_view_controller_with_a_context() {
    // given
    navigator.register("myapp://article/<int:id>") { url, values, context in
      guard let articleID = values["id"] as? Int, articleID > 0 else { return nil }
      return ArticleViewController(articleID: articleID, context: context)
    }
    let rootViewController = StubViewController()

    // when
    let viewController = navigator.present(
      "myapp://article/123",
      context: "Hello",
      from: rootViewController
    ) as? ArticleViewController

    // then
    XCTAssertEqual(viewController?.articleID, 123)
    XCTAssertEqual(viewController?.context as? String, "Hello")
  }

  func test_executes_present_with_default_arguments() {
    // given
    navigator.register("myapp://article/<int:id>") { url, values, context in
      guard let articleID = values["id"] as? Int, articleID > 0 else { return nil }
      return ArticleViewController(articleID: articleID, context: context)
    }
    let rootViewController = StubViewController()

    // when
    navigator.present("myapp://article/123", from: rootViewController)

    // then
    XCTAssertEqual(rootViewController.presentCallCount, 1)
    XCTAssertTrue(rootViewController.presentParams?.viewControllerToPresent is ArticleViewController)
    XCTAssertEqual(rootViewController.presentParams?.animated, true)
    XCTAssertNil(rootViewController.presentParams?.completion)
  }

  func test_executes_present_with_given_arguments() {
    // given
    navigator.register("myapp://article/<int:id>") { url, values, context in
      guard let articleID = values["id"] as? Int, articleID > 0 else { return nil }
      return ArticleViewController(articleID: articleID, context: context)
    }
    let rootViewController = StubViewController()
    var completionExecutionCount = 0

    // when
    navigator.present(
      "myapp://article/123",
      wrap: MyNavigationController.self,
      from: rootViewController,
      animated: false,
      completion: {
        completionExecutionCount += 1
      }
    )

    // then
    XCTAssertEqual(rootViewController.presentCallCount, 1)
    XCTAssertTrue(rootViewController.presentParams?.viewControllerToPresent is MyNavigationController)
    XCTAssertEqual(rootViewController.presentParams?.animated, false)
    XCTAssertNotNil(rootViewController.presentParams?.completion)
  }
}


// MARK: - handler(for:context:)

extension NavigatorTests {

  func test_handler_returns_nil_when_there_is_no_handler() {
    // when
    let handler = navigator.handler(for: "myapp://alert")

    // then
    XCTAssertNil(handler)
  }

  func test_handler_returns_nil_for_not_matching_url() {
    // given
    navigator.handle("myapp://alert") { url, values, context in
      true
    }

    // when
    let handler = navigator.handler(for: "myapp://alerthello")

    // then
    XCTAssertNil(handler)
  }

  func test_handler_returns_a_matching_handler() {
    // given
    navigator.handle("myapp://alert") { url, values, context in
      true
    }

    // when
    let handler = navigator.handler(for: "myapp://alert?title=Hello%2C%20world!&message=It%27s%20me!")

    // then
    XCTAssertNotNil(handler)
  }

  func test_handler_returns_a_matching_handler_with_a_context() {
    // given
    navigator.handle("myapp://alert") { url, values, context in
      true
    }

    // when
    let handler = navigator.handler(for: "myapp://alert?title=Hello%2C%20world!", context: "Hi")

    // then
    XCTAssertNotNil(handler)
  }
}


// MARK: - open(url:context:)

extension NavigatorTests {

  func test_open_returns_false_when_there_is_no_handler() {
    // when
    let result = navigator.open("myapp://alert")

    // then
    XCTAssertFalse(result)
  }

  func test_open_returns_false_for_not_matching_url() {
    // given
    var alerts: [(title: String, message: String?, context: Any?)]! = []
    navigator.handle("myapp://alert") { url, values, context in
      guard let title = url.queryParameters["title"] else { return false }
      let message = url.queryParameters["message"]
      alerts.append((title: title, message: message, context: context))
      return true
    }

    // when
    let result = navigator.open("myapp://alerthello")

    // then
    XCTAssertFalse(result)
    XCTAssertTrue(alerts.isEmpty)
  }

  func test_open_executes_a_matching_handler() {
    // given
    var alerts: [(title: String, message: String?, context: Any?)]! = []
    navigator.handle("myapp://alert") { url, values, context in
      guard let title = url.queryParameters["title"] else { return false }
      let message = url.queryParameters["message"]
      alerts.append((title: title, message: message, context: context))
      return true
    }

    // when
    let result = navigator.open("myapp://alert?title=Hello%2C%20world!&message=It%27s%20me!")

    // then
    XCTAssertTrue(result)
    XCTAssertEqual(alerts.count, 1)
    XCTAssertEqual(alerts.first?.title, "Hello, world!")
    XCTAssertEqual(alerts.first?.message, "It's me!")
    XCTAssertNil(alerts.first?.context)
  }

  func test_open_executes_a_matching_handler_with_context() {
    // given
    var alerts: [(title: String, message: String?, context: Any?)]! = []
    navigator.handle("myapp://alert") { url, values, context in
      guard let title = url.queryParameters["title"] else { return false }
      let message = url.queryParameters["message"]
      alerts.append((title: title, message: message, context: context))
      return true
    }

    // when
    let result = navigator.open("myapp://alert?title=Hello%2C%20world!", context: "Hi")

    // then
    XCTAssertTrue(result)
    XCTAssertEqual(alerts.count, 1)
    XCTAssertEqual(alerts.first?.title, "Hello, world!")
    XCTAssertNil(alerts.first?.message)
    XCTAssertEqual(alerts.first?.context as? String, "Hi")
  }
}


// MARK: - delegate > shouldPush

extension NavigatorTests {

  func test_shouldPush_does_not_get_called_for_a_not_matching_url_on_push() {
    // given
    let delegate: StubNavigatorDelegate = .init()

    navigator.delegate = delegate

    let fromNavigationController = StubNavigationController()

    // when
    navigator.push("myapp://user/10", from: fromNavigationController)

    // then
    XCTAssertEqual(delegate.shouldPushCallCount, 0)
  }

  func test_shouldPush_does_not_get_called_when_the_factory_returns_nil_on_push() {
    // given
    let delegate: StubNavigatorDelegate = .init()

    navigator.delegate = delegate
    navigator.register("myapp://article/<int:id>") { url, values, context in
      guard let articleID = values["id"] as? Int, articleID > 0 else { return nil }
      return ArticleViewController(articleID: articleID, context: context)
    }

    let fromNavigationController = StubNavigationController()

    // when
    navigator.push("myapp://article/-1", from: fromNavigationController)

    // then
    XCTAssertEqual(delegate.shouldPushCallCount, 0)
  }

  func test_shouldPush_gets_called_for_a_valid_url_on_push() {
    // given
    let delegate: StubNavigatorDelegate = .init()

    navigator.delegate = delegate
    navigator.register("myapp://article/<int:id>") { url, values, context in
      guard let articleID = values["id"] as? Int, articleID > 0 else { return nil }
      return ArticleViewController(articleID: articleID, context: context)
    }

    let fromNavigationController = StubNavigationController()

    // when
    navigator.push("myapp://article/123", from: fromNavigationController)

    // then
    XCTAssertEqual(delegate.shouldPushCallCount, 1)
    XCTAssertTrue(delegate.shouldPushParams?.viewController is ArticleViewController)
    XCTAssertIdentical(delegate.shouldPushParams?.from, fromNavigationController)
  }

  func test_shouldPush_does_not_prevent_from_pushing_when_returns_true_on_push() {
    // given
    let delegate: StubNavigatorDelegate = .init()
    delegate.shouldPushStub = true

    navigator.delegate = delegate
    navigator.register("myapp://article/<int:id>") { url, values, context in
      guard let articleID = values["id"] as? Int, articleID > 0 else { return nil }
      return ArticleViewController(articleID: articleID, context: context)
    }

    let fromNavigationController = StubNavigationController()

    // when
    navigator.push("myapp://article/123", from: fromNavigationController)

    // then
    XCTAssertEqual(fromNavigationController.pushViewControllerCallCount, 1)
  }

  func test_shouldPush_prevents_from_pushing_when_returns_false_on_push() {
    // given
    let delegate: StubNavigatorDelegate = .init()
    delegate.shouldPushStub = false

    navigator.delegate = delegate
    navigator.register("myapp://article/<int:id>") { url, values, context in
      guard let articleID = values["id"] as? Int, articleID > 0 else { return nil }
      return ArticleViewController(articleID: articleID, context: context)
    }

    let fromNavigationController = StubNavigationController()

    // when
    navigator.push("myapp://article/123", from: fromNavigationController)

    // then
    XCTAssertEqual(fromNavigationController.pushViewControllerCallCount, 0)
  }

  func test_shouldPush_does_not_get_called_on_present() {
    // given
    let delegate: StubNavigatorDelegate = .init()

    navigator.delegate = delegate
    navigator.register("myapp://article/<int:id>") { url, values, context in
      guard let articleID = values["id"] as? Int, articleID > 0 else { return nil }
      return ArticleViewController(articleID: articleID, context: context)
    }

    let fromViewController = StubViewController()

    // when
    navigator.present("myapp://article/1", from: fromViewController)

    // then
    XCTAssertEqual(delegate.shouldPushCallCount, 0)
  }
}


// MARK: - delegate > shouldPresent

extension NavigatorTests {

  func test_shouldPresent_does_not_get_called_on_push() {
    // given
    let delegate: StubNavigatorDelegate = .init()

    navigator.delegate = delegate
    navigator.register("myapp://article/<int:id>") { url, values, context in
      guard let articleID = values["id"] as? Int, articleID > 0 else { return nil }
      return ArticleViewController(articleID: articleID, context: context)
    }

    let fromNavigationController = StubNavigationController()

    // when
    navigator.push("myapp://article/1", from: fromNavigationController)

    // then
    XCTAssertEqual(delegate.shouldPresentCallCount, 0)
  }

  func test_shouldPresent_does_not_get_called_for_a_not_matching_url_on_present() {
    // given
    let delegate: StubNavigatorDelegate = .init()

    navigator.delegate = delegate

    let fromViewController = StubViewController()

    // when
    navigator.present("myapp://user/10", from: fromViewController)

    // then
    XCTAssertEqual(delegate.shouldPresentCallCount, 0)
  }

  func test_shouldPresent_does_not_get_called_when_the_factory_returns_nil_on_present() {
    // given
    let delegate: StubNavigatorDelegate = .init()

    navigator.delegate = delegate
    navigator.register("myapp://article/<int:id>") { url, values, context in
      guard let articleID = values["id"] as? Int, articleID > 0 else { return nil }
      return ArticleViewController(articleID: articleID, context: context)
    }

    let fromViewController = StubViewController()

    // when
    navigator.present("myapp://article/-1", from: fromViewController)

    // then
    XCTAssertEqual(delegate.shouldPresentCallCount, 0)
  }

  func test_shouldPresent_gets_called_for_valid_url_on_present() {
    // given
    let delegate: StubNavigatorDelegate = .init()

    navigator.delegate = delegate
    navigator.register("myapp://article/<int:id>") { url, values, context in
      guard let articleID = values["id"] as? Int, articleID > 0 else { return nil }
      return ArticleViewController(articleID: articleID, context: context)
    }

    let fromViewController = StubViewController()

    // when
    navigator.present("myapp://article/123", from: fromViewController)

    // then
    XCTAssertEqual(delegate.shouldPresentCallCount, 1)
    XCTAssertTrue(delegate.shouldPresentParams?.viewController is ArticleViewController)
    XCTAssertIdentical(delegate.shouldPresentParams?.from, fromViewController)
  }

  func test_shouldPresent_does_not_prevent_from_presenting_when_delegate_returns_true() {
    // given
    let delegate: StubNavigatorDelegate = .init()
    delegate.shouldPresentStub = true

    navigator.delegate = delegate
    navigator.register("myapp://article/<int:id>") { url, values, context in
      guard let articleID = values["id"] as? Int, articleID > 0 else { return nil }
      return ArticleViewController(articleID: articleID, context: context)
    }

    let fromViewController = StubViewController()

    // when
    navigator.present("myapp://article/123", from: fromViewController)

    // then
    XCTAssertEqual(fromViewController.presentCallCount, 1)
  }

  func test_shouldPresent_prevents_from_presenting_when_delegate_returns_false() {
    // given
    let delegate: StubNavigatorDelegate = .init()
    delegate.shouldPresentStub = false

    navigator.delegate = delegate
    navigator.register("myapp://article/<int:id>") { url, values, context in
      guard let articleID = values["id"] as? Int, articleID > 0 else { return nil }
      return ArticleViewController(articleID: articleID, context: context)
    }

    let fromViewController = StubViewController()

    // when
    navigator.present("myapp://article/123", from: fromViewController)

    // then
    XCTAssertEqual(fromViewController.presentCallCount, 0)
  }
}
#endif
