#if os(iOS) || os(tvOS)
import UIKit
import URLNavigator

final class StubNavigationController: UINavigationControllerType {

  var pushViewControllerCallCount: Int = 0
  var pushViewControllerParams: (viewController: UIViewController, animated: Bool)?

  func pushViewController(_ viewController: UIViewController, animated: Bool) {
    self.pushViewControllerCallCount += 1
    self.pushViewControllerParams = (viewController, animated)
  }
}

final class StubViewController: UIViewControllerType {

  var presentCallCount: Int = 0
  var presentParams: (viewControllerToPresent: UIViewController, animated: Bool, completion: (() -> Void)?)?

  func present(_ viewControllerToPresent: UIViewController, animated flag: Bool, completion: (() -> Void)?) {
    completion?()
    self.presentCallCount += 1
    self.presentParams = (viewControllerToPresent, flag, completion)
  }
}

final class StubNavigatorDelegate: NavigatorDelegate {

  var shouldPushCallCount: Int = 0
  var shouldPushParams: (viewController: UIViewController, from: UINavigationControllerType)?
  var shouldPushStub: Bool = true

  func shouldPush(viewController: UIViewController, from: UINavigationControllerType) -> Bool {
    self.shouldPushCallCount += 1
    self.shouldPushParams = (viewController, from)
    return self.shouldPushStub
  }

  var shouldPresentCallCount: Int = 0
  var shouldPresentParams: (viewController: UIViewController, from: UIViewControllerType)?
  var shouldPresentStub: Bool = true

  func shouldPresent(viewController: UIViewController, from: UIViewControllerType) -> Bool {
    self.shouldPresentCallCount += 1
    self.shouldPresentParams = (viewController, from)
    return self.shouldPresentStub
  }
}
#endif
