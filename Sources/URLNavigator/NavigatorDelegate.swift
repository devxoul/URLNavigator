#if os(iOS) || os(tvOS)
import UIKit

public protocol NavigatorDelegate: AnyObject {
  /// Returns whether the navigator should push the view controller or not. It returns `true` for
  /// default.
  func shouldPush(viewController: UIViewController, from: UINavigationControllerType) -> Bool

  /// Returns whether the navigator should present the view controller or not. It returns `true`
  /// for default.
  func shouldPresent(viewController: UIViewController, from: UIViewControllerType) -> Bool
}

extension NavigatorDelegate {
  public func shouldPush(viewController: UIViewController, from: UINavigationControllerType) -> Bool {
    return true
  }

  public func shouldPresent(viewController: UIViewController, from: UIViewControllerType) -> Bool {
    return true
  }
}
#endif
