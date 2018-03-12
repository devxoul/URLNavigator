#if os(iOS) || os(tvOS)
import UIKit

extension UIViewController {
  private class var sharedApplication: UIApplication? {
    let selector = NSSelectorFromString("sharedApplication")
    return UIApplication.perform(selector)?.takeUnretainedValue() as? UIApplication
  }

  /// Returns the current application's top most view controller.
  open class var topMost: UIViewController? {
    guard let currentWindows = self.sharedApplication?.windows else { return nil }
    return self.topMost(of: currentWindows)
  }
  
  /// Returns the top most view controller from windows.
  internal class func topMost(of windows: [UIWindow], keyWindowChecker: KeyWindowCheckerType = KeyWindowChecker()) -> UIViewController? {
    let currentKeyWindows = windows.filter(keyWindowChecker.isKeyWindow)
    var rootViewController: UIViewController?
    for window in currentKeyWindows {
      if let windowRootViewController = window.rootViewController {
        rootViewController = windowRootViewController
        break
      }
    }

    return self.topMost(of: rootViewController)
  }

  /// Returns the top most view controller from given view controller's stack.
  open class func topMost(of viewController: UIViewController?) -> UIViewController? {
    // presented view controller
    if let presentedViewController = viewController?.presentedViewController {
      return self.topMost(of: presentedViewController)
    }

    // UITabBarController
    if let tabBarController = viewController as? UITabBarController,
      let selectedViewController = tabBarController.selectedViewController {
      return self.topMost(of: selectedViewController)
    }

    // UINavigationController
    if let navigationController = viewController as? UINavigationController,
      let visibleViewController = navigationController.visibleViewController {
      return self.topMost(of: visibleViewController)
    }

    // UIPageController
    if let pageViewController = viewController as? UIPageViewController,
      pageViewController.viewControllers?.count == 1 {
      return self.topMost(of: pageViewController.viewControllers?.first)
    }

    // child view controller
    for subview in viewController?.view?.subviews ?? [] {
      if let childViewController = subview.next as? UIViewController {
        return self.topMost(of: childViewController)
      }
    }

    return viewController
  }
}

internal protocol KeyWindowCheckerType {
  func isKeyWindow(_ window: UIWindow) -> Bool
}

internal class KeyWindowChecker: KeyWindowCheckerType {
  func isKeyWindow(_ window: UIWindow) -> Bool {
    return window.isKeyWindow
  }
}
#endif
