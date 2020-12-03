#if os(iOS) || os(tvOS)
import UIKit

extension UIViewController {
  private class var sharedApplication: UIApplication? {
    let selector = NSSelectorFromString("sharedApplication")
    return UIApplication.perform(selector)?.takeUnretainedValue() as? UIApplication
  }

  /// Returns the current application's top most view controller.
  open class var topMost: UIViewController? {
    var keyWindow:UIWindow?
    keyWindow = self.sharedApplication?.delegate?.window ?? self.sharedApplication?.windows.filter({ (window) -> Bool in
        return window.isKeyWindow && (window.rootViewController != nil)
    }).first
    guard let currentWindow = keyWindow else { return nil }
    return self.topMost(of: currentWindow.rootViewController)
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
#endif
