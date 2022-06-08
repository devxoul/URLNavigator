#if os(iOS) || os(tvOS)
import UIKit

import Nimble
import Quick

import URLNavigator

final class NavigatorSpec: QuickSpec {
  override func spec() {
    var navigator: NavigatorProtocol!

    beforeEach {
      navigator = Navigator()
    }

    describe("viewController(for:context:)") {
      context("when there is no registered view controller") {
        it("returns nil") {
          let viewController = navigator.viewController(for: "/article/123")
          expect(viewController).to(beNil())
        }
      }

      context("when there is a registered view controller") {
        beforeEach {
          navigator.register("myapp://article/<int:id>") { url, values, context in
            guard let articleID = values["id"] as? Int, articleID > 0 else { return nil }
            return ArticleViewController(articleID: articleID, context: context)
          }
        }

        it("returns nil for not matching url") {
          let viewController = navigator.viewController(for: "myapp://article")
          expect(viewController).to(beNil())
        }

        it("returns nil for not matching value type") {
          let viewController = navigator.viewController(for: "myapp://article/hello")
          expect(viewController).to(beNil())
        }

        it("returns nil when the factory returns nil") {
          let viewController = navigator.viewController(for: "myapp://article/-1") as? ArticleViewController
          expect(viewController).to(beNil())
        }

        it("returns a matching view controller") {
          let viewController = navigator.viewController(for: "myapp://article/123") as? ArticleViewController
          expect(viewController).notTo(beNil())
          expect(viewController?.articleID) == 123
          expect(viewController?.context).to(beNil())
        }

        it("returns a matching view controller with a context") {
          let viewController = navigator.viewController(for: "myapp://article/123", context: "Hello") as? ArticleViewController
          expect(viewController).notTo(beNil())
          expect(viewController?.articleID) == 123
          expect(viewController?.context as? String) == "Hello"
        }
      }
    }

    describe("push(url:context:from:animated:)") {
      beforeEach {
        navigator.register("myapp://article/<int:id>") { url, values, context in
          guard let articleID = values["id"] as? Int, articleID > 0 else { return nil }
          return ArticleViewController(articleID: articleID, context: context)
        }
      }

      it("pushes a view controller to a navigation controller") {
        let navigationController = StubNavigationController()
        let viewController = navigator.push("myapp://article/123", from: navigationController) as? ArticleViewController
        expect(viewController?.articleID) == 123
        expect(viewController?.context).to(beNil())
      }

      it("pushes a view controller to a navigation controller with a context") {
        let navigationController = StubNavigationController()
        let viewController = navigator.push("myapp://article/123", context: 456, from: navigationController) as? ArticleViewController
        expect(viewController?.articleID) == 123
        expect(viewController?.context as? Int) == 456
      }

      it("executes pushViewController() with default arguments") {
        let navigationController = StubNavigationController()
        navigator.push("myapp://article/123", from: navigationController)

        expect(navigationController.pushViewControllerCallCount) == 1
        expect(navigationController.pushViewControllerParams?.viewController).to(beAKindOf(ArticleViewController.self))
        expect(navigationController.pushViewControllerParams?.animated) == true
      }

      it("executes pushViewController() with given arguments") {
        let navigationController = StubNavigationController()
        navigator.push("myapp://article/123", from: navigationController, animated: false)

        expect(navigationController.pushViewControllerCallCount) == 1
        expect(navigationController.pushViewControllerParams?.viewController).to(beAKindOf(ArticleViewController.self))
        expect(navigationController.pushViewControllerParams?.animated) == false
      }
    }

    describe("present(url:context:wrap:from:animated:completion:)") {
      beforeEach {
        navigator.register("myapp://article/<int:id>") { url, values, context in
          guard let articleID = values["id"] as? Int, articleID > 0 else { return nil }
          return ArticleViewController(articleID: articleID, context: context)
        }
      }

      it("presents a view controller") {
        let rootViewController = StubViewController()
        let viewController = navigator.present("myapp://article/123", from: rootViewController) as? ArticleViewController
        expect(viewController?.articleID) == 123
        expect(viewController?.context).to(beNil())
      }

      it("presents a view controller with a context") {
        let rootViewController = StubViewController()
        let viewController = navigator.present("myapp://article/123", context: "Hello", from: rootViewController) as? ArticleViewController
        expect(viewController?.articleID) == 123
        expect(viewController?.context as? String) == "Hello"
      }

      it("executes present() with default arguments") {
        let rootViewController = StubViewController()
        navigator.present("myapp://article/123", from: rootViewController)

        expect(rootViewController.presentCallCount) == 1
        expect(rootViewController.presentParams?.viewControllerToPresent).to(beAKindOf(ArticleViewController.self))
        expect(rootViewController.presentParams?.animated) == true
        expect(rootViewController.presentParams?.completion).to(beNil())
      }

      it("executes present() with given arguments") {
        let rootViewController = StubViewController()
        var completionExecutionCount = 0
        navigator.present("myapp://article/123", wrap: MyNavigationController.self, from: rootViewController, animated: false, completion: {
          completionExecutionCount += 1
        })

        expect(rootViewController.presentCallCount) == 1
        expect(rootViewController.presentParams?.viewControllerToPresent).to(beAKindOf(MyNavigationController.self))
        expect(rootViewController.presentParams?.animated) == false
        expect(rootViewController.presentParams?.completion).notTo(beNil())
      }
    }

    describe("handler(for:context:)") {
      context("when there is no handler") {
        it("returns nil") {
          let handler = navigator.handler(for: "myapp://alert")
          expect(handler).to(beNil())
        }
      }

      context("when there is registered handlers") {
        beforeEach {
          navigator.handle("myapp://alert") { url, values, context in
            return true
          }
        }

        it("returns false for not matching url") {
          let handler = navigator.handler(for: "myapp://alerthello")
          expect(handler).to(beNil())
        }

        it("returns a matching handler") {
          let handler = navigator.handler(for: "myapp://alert?title=Hello%2C%20world!&message=It%27s%20me!")
          expect(handler).notTo(beNil())
        }

        it("returns a matching handler with a context") {
          let handler = navigator.handler(for: "myapp://alert?title=Hello%2C%20world!", context: "Hi")
          expect(handler).notTo(beNil())
        }
      }
    }

    describe("open(url:context:)") {
      var alerts: [(title: String, message: String?, context: Any?)]!

      beforeEach {
        alerts = []
      }

      context("when there is no handler") {
        it("returns false") {
          let result = navigator.open("myapp://alert")
          expect(result) == false
          expect(alerts.count) == 0
        }
      }

      context("when there is registered handlers") {
        beforeEach {
          navigator.handle("myapp://alert") { url, values, context in
            guard let title = url.queryParameters["title"] else { return false }
            let message = url.queryParameters["message"]
            alerts.append((title: title, message: message, context: context))
            return true
          }
        }

        it("returns false for not matching url") {
          let result = navigator.open("myapp://alerthello")
          expect(result) == false
          expect(alerts.count) == 0
        }

        it("executes a matching handler") {
          let result = navigator.open("myapp://alert?title=Hello%2C%20world!&message=It%27s%20me!")
          expect(result) == true
          expect(alerts.count) == 1
          expect(alerts.first?.title) == "Hello, world!"
          expect(alerts.first?.message) == "It's me!"
          expect(alerts.first?.context).to(beNil())
        }

        it("executes a matching handler with a context") {
          let result = navigator.open("myapp://alert?title=Hello%2C%20world!", context: "Hi")
          expect(result) == true
          expect(alerts.count) == 1
          expect(alerts.first?.title) == "Hello, world!"
          expect(alerts.first?.message).to(beNil())
          expect(alerts.first?.context as? String) == "Hi"
        }
      }
    }

    describe("delegate") {
      var delegate: StubNavigatorDelegate!
      var fromNavigationController: StubNavigationController!
      var fromViewController: StubViewController!
      var alerts: [(title: String, message: String?, context: Any?)]!

      beforeEach {
        delegate = StubNavigatorDelegate()
        fromNavigationController = StubNavigationController()
        fromViewController = StubViewController()
        alerts = []

        navigator.delegate = delegate
        navigator.register("myapp://article/<int:id>") { url, values, context in
          guard let articleID = values["id"] as? Int, articleID > 0 else { return nil }
          return ArticleViewController(articleID: articleID, context: context)
        }
        navigator.handle("myapp://alert") { url, values, context in
          guard let title = url.queryParameters["title"] else { return false }
          let message = url.queryParameters["message"]
          alerts.append((title: title, message: message, context: context))
          return true
        }
      }

      describe("shouldPush(viewController:from:)") {
        context("on push()") {
          it("doesn't get called for a not matching url") {
            navigator.push("myapp://user/10", from: fromNavigationController)
            expect(delegate.shouldPushCallCount) == 0
          }

          it("doesn't get called when the factory returns nil") {
            navigator.push("myapp://article/-1", from: fromNavigationController)
            expect(delegate.shouldPushCallCount) == 0
          }

          it("gets called for a valid url") {
            navigator.push("myapp://article/123", from: fromNavigationController)
            expect(delegate.shouldPushCallCount) == 1
            expect(delegate.shouldPushParams?.viewController).to(beAKindOf(ArticleViewController.self))
            expect(delegate.shouldPushParams?.from) === fromNavigationController
          }

          it("doesn't prevent from pushing when returns true") {
            delegate.shouldPushStub = true
            navigator.push("myapp://article/123", from: fromNavigationController)
            expect(fromNavigationController.pushViewControllerCallCount) == 1
          }

          it("prevents from pushing when returns false") {
            delegate.shouldPushStub = false
            navigator.push("myapp://article/123", from: fromNavigationController)
            expect(fromNavigationController.pushViewControllerCallCount) == 0
          }
        }

        context("on present()") {
          it("doesn't get called") {
            navigator.present("myapp://article/1", from: fromViewController)
          }
        }
      }

      describe("shouldPresent(viewController:from:)") {
        context("on push()") {
          it("doesn't get called") {
            navigator.push("myapp://article/1", from: fromNavigationController)
          }
        }

        context("on present()") {
          it("doesn't get called for a not matching url") {
            navigator.present("myapp://user/10", from: fromViewController)
            expect(delegate.shouldPresentCallCount) == 0
          }

          it("doesn't get called when the factory returns nil") {
            navigator.present("myapp://article/-1", from: fromViewController)
            expect(delegate.shouldPresentCallCount) == 0
          }

          it("gets called for a valid url") {
            navigator.present("myapp://article/123", from: fromViewController)
            expect(delegate.shouldPresentCallCount) == 1
            expect(delegate.shouldPresentParams?.viewController).to(beAKindOf(ArticleViewController.self))
            expect(delegate.shouldPresentParams?.from) === fromViewController
          }

          it("doesn't prevent from presenting when returns true") {
            delegate.shouldPresentStub = true
            navigator.present("myapp://article/123", from: fromViewController)
            expect(fromViewController.presentCallCount) == 1
          }

          it("prevents from presenting when returns false") {
            delegate.shouldPresentStub = false
            navigator.present("myapp://article/123", from: fromViewController)
            expect(fromViewController.presentCallCount) == 0
          }
        }
      }
    }
  }
}
#endif
