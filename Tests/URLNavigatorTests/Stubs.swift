#if os(iOS) || os(tvOS)
import UIKit
import Stubber
import URLNavigator

final class StubNavigationController: UINavigationControllerType {
  func pushViewController(_ viewController: UIViewController, animated: Bool) {
    return Stubber.invoke(pushViewController, args: (viewController, animated), default: Void())
  }
}

final class StubViewController: UIViewControllerType {
  func present(_ viewControllerToPresent: UIViewController, animated flag: Bool, completion: (() -> Void)?) {
    completion?()
    return Stubber.invoke(present, args: (viewControllerToPresent, flag, completion), default: Void())
  }
}

final class StubNavigatorDelegate: NavigatorDelegate {
  func shouldPush(viewController: UIViewController, from: UINavigationControllerType) -> Bool {
    return Stubber.invoke(shouldPush, args: (viewController, from), default: true)
  }

  func shouldPresent(viewController: UIViewController, from: UIViewControllerType) -> Bool {
    return Stubber.invoke(shouldPresent, args: (viewController, from), default: true)
  }
}
#endif
