import Nimble
import Quick

@testable import URLMatcher

final class URLMatcherInternalSpec: QuickSpec {
  override func spec() {
    var matcher: URLMatcher!

    beforeEach {
      matcher = URLMatcher()
    }

    describe("normalizeURL(_:)") {
      it("doesn't change anything if there is nothing to normalize") {
        expect(matcher.normalizeURL("myapp://user/<id>/hello").urlStringValue) == "myapp://user/<id>/hello"
        expect(matcher.normalizeURL("https://<path:_>").urlStringValue) == "https://<path:_>"
        expect(matcher.normalizeURL("https://").urlStringValue) == "https://"
      }

      it("removes redundant slashes and query parameters and hashbangs") {
        let dirtyURL = "myapp:///////user///<id>//hello/??/#abc=/def"
        expect(matcher.normalizeURL(dirtyURL).urlStringValue) == "myapp://user/<id>/hello"
      }
    }

    describe("pathComponents(from:)") {
      it("returns proper path components") {
        let components = matcher.pathComponents(from: "myapp://foo/bar/<name>/<int:id>")
        expect(components) == [
          .plain("foo"),
          .plain("bar"),
          .placeholder(type: nil, key: "name"),
          .placeholder(type: "int", key: "id"),
        ]
      }
    }

    describe("replaceRegex(_:_:_:)") {
      it("replaces regular expression") {
        expect(matcher.replaceRegex("a", "0", "abc")) == "0bc"
        expect(matcher.replaceRegex("\\d", "A", "1234567abc098")) == "AAAAAAAabcAAA"
      }
    }
  }
}
