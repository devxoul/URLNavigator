#if os(iOS) || os(tvOS)
import UIKit
import URLNavigator

final class StubNavigationController: UINavigationControllerType {

  var pushViewControllerCallCount = 0
  var pushViewControllerParams: (viewController: UIViewController, animated: Bool)?

  func pushViewController(_ viewController: UIViewController, animated: Bool) {
    pushViewControllerCallCount += 1
    pushViewControllerParams = (viewController, animated)
  }
}

final class StubViewController: UIViewControllerType {

  var presentCallCount = 0
  var presentParams: (viewControllerToPresent: UIViewController, animated: Bool, completion: (() -> Void)?)?

  func present(_ viewControllerToPresent: UIViewController, animated flag: Bool, completion: (() -> Void)?) {
    completion?()
    presentCallCount += 1
    presentParams = (viewControllerToPresent, flag, completion)
  }
}

final class StubNavigatorDelegate: NavigatorDelegate {

  var shouldPushCallCount = 0
  var shouldPushParams: (viewController: UIViewController, from: UINavigationControllerType)?
  var shouldPushStub = true

  func shouldPush(viewController: UIViewController, from: UINavigationControllerType) -> Bool {
    shouldPushCallCount += 1
    shouldPushParams = (viewController, from)
    return shouldPushStub
  }

  var shouldPresentCallCount = 0
  var shouldPresentParams: (viewController: UIViewController, from: UIViewControllerType)?
  var shouldPresentStub = true

  func shouldPresent(viewController: UIViewController, from: UIViewControllerType) -> Bool {
    shouldPresentCallCount += 1
    shouldPresentParams = (viewController, from)
    return shouldPresentStub
  }
}
#endif
