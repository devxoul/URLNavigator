import Nimble
import Quick

@testable import URLMatcher

final class URLPathComponentSpec: QuickSpec {
  override func spec() {
    describe("init()") {
      it("is .plain with plain string") {
        expect(URLPathComponent("foo")) == URLPathComponent.plain("foo")
      }

      it("is .placeholder with untyped placeholder string") {
        expect(URLPathComponent("<name>")) == URLPathComponent.placeholder(type: nil, key: "name")
      }

      it("is .placeholder for typed placeholder string") {
        expect(URLPathComponent("<int:id>")) == URLPathComponent.placeholder(type: "int", key: "id")
      }
    }

    describe("==") {
      it("is true for both .plain with same values") {
        expect(URLPathComponent.plain("foo")) == URLPathComponent.plain("foo")
      }

      it("is true for both .plain with different values") {
        expect(URLPathComponent.plain("foo")) != URLPathComponent.plain("bar")
      }

      it("is true for both .placeholder with same types and same keys") {
        expect(URLPathComponent.placeholder(type: "int", key: "id")) == URLPathComponent.placeholder(type: "int", key: "id")
      }

      it("is false for both .placeholder with different types and same keys") {
        expect(URLPathComponent.placeholder(type: "int", key: "id")) != URLPathComponent.placeholder(type: "string", key: "id")
      }

      it("is false for both .placeholder with same types and different keys") {
        expect(URLPathComponent.placeholder(type: "int", key: "id")) != URLPathComponent.placeholder(type: "int", key: "name")
      }

      it("is false for both .placeholder with different types and different keys") {
        expect(URLPathComponent.placeholder(type: "int", key: "id")) != URLPathComponent.placeholder(type: "string", key: "name")
      }

      it("is false for different cases") {
        expect(URLPathComponent.plain("id")) != URLPathComponent.placeholder(type: "int", key: "id")
      }
    }
  }
}
