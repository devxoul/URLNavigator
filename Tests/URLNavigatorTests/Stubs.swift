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
