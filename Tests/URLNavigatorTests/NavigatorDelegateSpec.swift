#if os(iOS) || os(tvOS)
import UIKit

import Nimble
import Quick

import URLNavigator

final class NavigatorDelegateSpec: QuickSpec {
  override func spec() {
    var delegate: NavigatorDelegateObject!

    beforeEach {
      delegate = NavigatorDelegateObject()
    }

    describe("shouldPush(viewController:from:)") {
      it("returns true as default") {
        let result = delegate.shouldPush(viewController: UIViewController(), from: UINavigationController())
        expect(result) == true
      }
    }

    describe("shouldPresent(viewController:from:)") {
      it("returns true as default") {
        let result = delegate.shouldPresent(viewController: UIViewController(), from: UIViewController())
        expect(result) == true
      }
    }
  }
}

private final class NavigatorDelegateObject: NavigatorDelegate {
}
#endif
