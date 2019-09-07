import Foundation

import Nimble
import Quick

import URLMatcher

final class URLMatcherSpec: QuickSpec {
  override func spec() {
    var matcher: URLMatcher!

    beforeEach {
      matcher = URLMatcher()
    }

    it("returns nil when there's no candidates") {
      let result = matcher.match("myapp://user/1", from: [])
      expect(result).to(beNil())
    }

    it("returns nil for unmatching scheme") {
      let result = matcher.match("myapp://user/1", from: ["yourapp://user/<id>"])
      expect(result).to(beNil())
    }

    it("returns nil for totally unmatching url") {
      let result = matcher.match("myapp://user/1", from: ["myapp://comment/<id>"])
      expect(result).to(beNil())
    }

    it("returns nil for partially unmatching url") {
      let result = matcher.match("myapp://user/1", from: ["myapp://user/<id>/hello"])
      expect(result).to(beNil())
    }

    it("returns nil for an unmatching value type") {
      let result = matcher.match("myapp://user/devxoul", from: ["myapp://user/<int:id>"])
      expect(result).to(beNil())
    }

    it("returns a result for totally matching url") {
      let candidates = ["myapp://hello/<name>", "myapp://hello/world"]
      let result = matcher.match("myapp://hello/world", from: candidates)
      expect(result).notTo(beNil())
      expect(result?.pattern) == "myapp://hello/world"
      expect(result?.values.count) == 0
    }

    it("returns a result for the longest matching url") {
      let candidates = ["myapp://<path:path>", "myapp://hello/<name>"]
      let result = matcher.match("myapp://hello/world", from: candidates)
      expect(result).notTo(beNil())
      expect(result?.pattern) == "myapp://hello/<name>"
      expect(result?.values.count) == 1
    }

    it("returns a result with an url value for matching url") {
      let candidates = ["myapp://user/<id>/hello", "myapp://user/<id>"]
      let result = matcher.match("myapp://user/1", from: candidates)
      expect(result).notTo(beNil())
      expect(result?.pattern) == "myapp://user/<id>"
      expect(result?.values.count) == 1
      expect(result?.values["id"] as? String) == "1"
    }

    it("returns a result with an string-type url value for matching url") {
      let candidates = ["myapp://user/<string:id>"]
      let result = matcher.match("myapp://user/123", from: candidates)
      expect(result).notTo(beNil())
      expect(result?.pattern) == "myapp://user/<string:id>"
      expect(result?.values.count) == 1
      expect(result?.values["id"] as? String) == "123"
    }

    it("returns a result with an int-type url value for matching url") {
      let candidates = ["myapp://user/<int:id>"]
      let result = matcher.match("myapp://user/123", from: candidates)
      expect(result).notTo(beNil())
      expect(result?.pattern) == "myapp://user/<int:id>"
      expect(result?.values.count) == 1
      expect(result?.values["id"] as? Int) == 123
    }

    it("returns a result with a float-type url value for matching url") {
      let candidates = ["myapp://user/<float:id>"]
      let result = matcher.match("myapp://user/123.456", from: candidates)
      expect(result).notTo(beNil())
      expect(result?.pattern) == "myapp://user/<float:id>"
      expect(result?.values.count) == 1
      expect(result?.values["id"] as? Float) == 123.456
    }

    it("returns a result with an uuid-type url value for matching url") {
      let candidates = ["myapp://user/<uuid:id>"]
      let uuidString = "621425B8-42D1-4AB4-9A58-1E69D708A84B"
      let result = matcher.match("myapp://user/\(uuidString)" ,from: candidates)
      expect(result).notTo(beNil())
      expect(result?.pattern) == "myapp://user/<uuid:id>"
      expect(result?.values.count) == 1
      expect(result?.values["id"] as? UUID) == UUID(uuidString: uuidString)
    }

    it("returns a result with a custom-type url value for matching url") {
      matcher.valueConverters["greeting"] = { pathComponents, index in
        return "Hello, \(pathComponents[index])!"
      }
      let candidates = ["myapp://hello/<greeting:name>"]
      let result = matcher.match("myapp://hello/devxoul" ,from: candidates)
      expect(result).notTo(beNil())
      expect(result?.pattern) == "myapp://hello/<greeting:name>"
      expect(result?.values.count) == 1
      expect(result?.values["name"] as? String) == "Hello, devxoul!"
    }

    it("returns a result with multiple url values for matching url") {
      let candidates = ["myapp://user/<id>", "myapp://user/<id>/<object>"]
      let result = matcher.match("myapp://user/1/posts", from: candidates)
      expect(result).notTo(beNil())
      expect(result?.pattern) == "myapp://user/<id>/<object>"
      expect(result?.values.count) == 2
      expect(result?.values["id"] as? String) == "1"
      expect(result?.values["object"] as? String) == "posts"
    }

    it("returns a result with ignoring a query string") {
      let candidates = ["myapp://alert"]
      let result = matcher.match("myapp://alert?title=hello&message=world", from: candidates)
      expect(result).notTo(beNil())
      expect(result?.pattern) == "myapp://alert"
      expect(result?.values.count) == 0
    }

    it("returns a result with a path-type url value") {
      let candidates = ["https://<path:url>"]
      let result = matcher.match("https://google.com/search?q=URLNavigator", from: candidates)
      expect(result).notTo(beNil())
      expect(result?.pattern) == "https://<path:url>"
      expect(result?.values["url"] as? String) == "google.com/search"
    }

    it("returns a result with a path url value ending with trailing slash") {
      let candidates = ["https://<path:url>"]
      let result = matcher.match("https://google.com/search/?q=URLNavigator", from: candidates)
      expect(result).notTo(beNil())
      expect(result?.pattern) == "https://<path:url>"
      expect(result?.values["url"] as? String) == "google.com/search"
    }

    it("returns nil when there's no candidates (issues-109)") {
        let candidates = ["/anything/<path:url>"]
        let result = matcher.match("", from: candidates)
        expect(result).to(beNil())
    }

    it("returns nil when there's no candidates (issues-109)") {
        let candidates = ["http://host/anything/<path:url>"]
        let result = matcher.match("http://host/anything", from: candidates)
        expect(result).to(beNil())
    }

    it("returns same candidate (issues-109)") {
        let candidates1 = ["http://host/anything/<path:url>", "http://host/anything"]
        let result1 = matcher.match("http://host/anything", from: candidates1)
        let candidates2 = ["http://host/anything", "http://host/anything/<path:url>"]
        let result2 = matcher.match("http://host/anything", from: candidates2)
        expect(result1?.pattern).to(equal(result2?.pattern))
    }

    it("returns nil when there is anotehr url in the path (#123)") {
      let candidates = ["myapp://browser/<url>"]
      let result = matcher.match("myapp://browser/http://google.fr", from: candidates)
      expect(result).to(beNil())
    }
  }
}
