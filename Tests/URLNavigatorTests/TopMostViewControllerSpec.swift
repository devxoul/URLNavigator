#if os(iOS) || os(tvOS)
import UIKit

import Nimble
import Quick

import URLNavigator

final class TopMostViewControllerSpec: QuickSpec {
  fileprivate static var currentWindow: UIWindow?

  override func spec() {
    var window: UIWindow!
    var topMost: UIViewController? {
      return UIViewController.topMost(of: window.rootViewController)
    }

    beforeEach {
      window = UIWindow(frame: UIScreen.main.bounds)
      TopMostViewControllerSpec.currentWindow = window
    }

    context("when the root view controller is a view controller") {
      context("when there is only a root view controller") {
        it("returns root view controller") {
          let viewController = UIViewController().asRoot()
          expect(topMost) == viewController
        }
      }

      context("when there is a presented view controller") {
        it("returns a presented view controller") {
          let A = UIViewController("A").asRoot()
          let B = UIViewController("B")
          A.present(B, animated: false, completion: nil)
          expect(topMost) == B
        }
      }

      context("when there is a presented tab bar controller") {
        it("returns the selected view controller of the presented tab bar controller") {
          let A = UIViewController("A").asRoot()
          let B = UIViewController("B")
          let C = UIViewController("C")
          let tabBarController = UITabBarController()
          tabBarController.viewControllers = [B, C]
          tabBarController.selectedIndex = 1
          A.present(tabBarController, animated: false, completion: nil)
          expect(topMost) == C
        }
      }

      context("when there is a presented navigation controller") {
        it("returns a top view controller of the presented navigation controller") {
          let A = UIViewController("A").asRoot()
          let B = UIViewController("B")
          let C = UIViewController("C")
          let D = UIViewController("D")
          let navigationController = UINavigationController(rootViewController: B)
          navigationController.pushViewController(C, animated: false)
          navigationController.pushViewController(D, animated: false)
          A.present(navigationController, animated: false, completion: nil)
          expect(topMost) == D
        }
      }

      context("when there is a presented page view controller") {
        it("returns the selected view controller of the presented page view controller") {
          let A = UIViewController("A").asRoot()
          let B = UIViewController("B")
          let pageViewController = UIPageViewController()
          pageViewController.setViewControllers([B], direction: .forward, animated: false, completion: nil)
          A.present(pageViewController, animated: false, completion: nil)
          expect(topMost) == B
        }
      }
    }

    context("when the root view controller is a tab bar controller") {
      context("when there is no view controller") {
        it("returns the tab bar controller") {
          let tabBarController = UITabBarController().asRoot()
          expect(topMost) == tabBarController
        }
      }

      context("when there is a single view controller") {
        it("returns the only view controller") {
          let A = UIViewController("A")
          let tabBarController = UITabBarController().asRoot()
          tabBarController.viewControllers = [A]
          expect(topMost) == A
        }
      }

      context("when there are multiple view controllers") {
        it("returns the selected view controller of the tab bar controller") {
          let A = UIViewController("A")
          let B = UIViewController("B")
          let C = UIViewController("C")
          let tabBarController = UITabBarController().asRoot()
          tabBarController.viewControllers = [A, B, C]
          tabBarController.selectedIndex = 1
          expect(topMost) == B
        }
      }

      context("when a view controller is presented from the view controller in the tab bar controller") {
        it("returns the presented view controller") {
          let A = UIViewController("A")
          let B = UIViewController("B")
          let C = UIViewController("C")
          let tabBarController = UITabBarController().asRoot()
          tabBarController.viewControllers = [A, B, C]
          tabBarController.selectedIndex = 2
          let D = UIViewController("D")
          C.present(D, animated: false, completion: nil)
          expect(topMost) == D
        }
      }
    }

    context("when the root view controller is a navigation controller") {
      context("when there is no view controller") {
        it("returns the navigation controller") {
          let navigationController = UINavigationController().asRoot()
          expect(topMost) == navigationController
        }
      }

      context("when there is only a root view controller") {
        it("returns the root view controller of the navigation controller") {
          let A = UIViewController("A")
          UINavigationController(rootViewController: A).asRoot()
          expect(topMost) == A
        }
      }

      context("when there are multiple view controllers") {
        it("returns the top view controller of the navigation controller") {
        let A = UIViewController("A")
          let B = UIViewController("B")
          let navigationController = UINavigationController(rootViewController: A).asRoot()
          navigationController.pushViewController(B, animated: false)
          expect(topMost) == B
        }
      }

      context("when a view controller is presented from the view controller in the navigation controller") {
        it("returns the presented view controller") {
          let A = UIViewController("A")
          let B = UIViewController("B")
          let C = UIViewController("C")
          let navigationController = UINavigationController(rootViewController: A).asRoot()
          navigationController.pushViewController(B, animated: false)
          navigationController.pushViewController(C, animated: false)
          let D = UIViewController("D")
          C.present(D, animated: false, completion: nil)
          expect(topMost) == D
        }
      }
    }

    context("when the root view controller is a page view controller") {
      context("when there is a view controller") {
        it("returns the visible view controller") {
          let A = UIViewController("A")
          let pageViewController = UIPageViewController().asRoot()
          pageViewController.setViewControllers([A], direction: .forward, animated: false, completion: nil)
          expect(topMost) == A
        }
      }

      context("when a view controller is presented from the view controller in the page view controller") {
        it("returns the presented view controller") {
          let A = UIViewController("A")
          let B = UIViewController("B")
          let pageViewController = UIPageViewController().asRoot()
          pageViewController.setViewControllers([A], direction: .forward, animated: false, completion: nil)
          A.present(B, animated: false, completion: nil)
          expect(topMost) == B
        }
      }
    }
  }
}

extension UIViewController {
  convenience init(_ title: String) {
    self.init()
    self.title = title
  }

  override open var description: String {
    let title = self.title ?? String(format: "0x%x", self)
    return "<\(type(of: self)): \(title)>"
  }

  @discardableResult
  func asRoot() -> Self {
    TopMostViewControllerSpec.currentWindow?.rootViewController = self
    TopMostViewControllerSpec.currentWindow?.addSubview(self.view)
    return self
  }
}
#endif

