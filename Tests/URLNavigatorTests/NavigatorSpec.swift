#if os(iOS) || os(tvOS)
import UIKit

import Nimble
import Quick
import Stubber

import URLNavigator

final class NavigatorSpec: QuickSpec {
  override func spec() {
    var navigator: NavigatorType!

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

        let executions = Stubber.executions(navigationController.pushViewController)
        expect(executions.count) == 1
        expect(executions[0].arguments.0).to(beAKindOf(ArticleViewController.self))
        expect(executions[0].arguments.1) == true
      }

      it("executes pushViewController() with given arguments") {
        let navigationController = StubNavigationController()
        navigator.push("myapp://article/123", from: navigationController, animated: false)

        let executions = Stubber.executions(navigationController.pushViewController)
        expect(executions.count) == 1
        expect(executions[0].arguments.0).to(beAKindOf(ArticleViewController.self))
        expect(executions[0].arguments.1) == false
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

        let executions = Stubber.executions(rootViewController.present)
        expect(executions.count) == 1
        expect(executions[0].arguments.0).to(beAKindOf(ArticleViewController.self))
        expect(executions[0].arguments.1) == true
        expect(executions[0].arguments.2).to(beNil())
      }

      it("executes present() with given arguments") {
        let rootViewController = StubViewController()
        var completionExecutionCount = 0
        navigator.present("myapp://article/123", wrap: MyNavigationController.self, from: rootViewController, animated: false, completion: {
          completionExecutionCount += 1
        })

        let executions = Stubber.executions(rootViewController.present)
        expect(executions.count) == 1
        expect(executions[0].arguments.0).to(beAKindOf(MyNavigationController.self))
        expect(executions[0].arguments.1) == false
        expect(executions[0].arguments.2).notTo(beNil())
        expect(completionExecutionCount) == 1
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
  }
}
#endif
