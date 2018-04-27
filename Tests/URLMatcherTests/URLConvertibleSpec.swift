import Foundation

import Nimble
import Quick

import URLMatcher

final class URLConvertibleSpec: QuickSpec {
  override func spec() {
    describe("urlValue") {
      it("returns an URL instance") {
        let url = URL(string: "https://xoul.kr")!
        expect(url.urlValue) == url
        expect(url.absoluteString.urlValue) == url
      }

      it("returns an URL instance from unicode string") {
        let urlString = "https://xoul.kr/한글"
        expect(urlString.urlValue) == URL(string: "https://xoul.kr/%ED%95%9C%EA%B8%80")!
      }
    }

    describe("urlStringValue") {
      it("returns a URL string value") {
        let url = URL(string: "https://xoul.kr")!
        expect(url.urlStringValue) == url.absoluteString
        expect(url.absoluteString.urlStringValue) == url.absoluteString
      }
    }

    describe("queryParameters") {
      context("when there is no query string") {
        it("returns empty dictionary") {
          let url = "https://xoul.kr"
          expect(url.urlValue?.queryParameters) == [:]
          expect(url.urlStringValue.queryParameters) == [:]
        }
      }

      context("when there is an empty query string") {
        it("returns empty dictionary") {
          let url = "https://xoul.kr?"
          expect(url.urlValue?.queryParameters) == [:]
          expect(url.urlStringValue.queryParameters) == [:]
        }
      }

      context("when there is a query string") {
        let url = "https://xoul.kr?key=this%20is%20a%20value&greeting=hello+world!&int=12&int=34&url=https://foo/bar?hello=world"

        it("has proper keys") {
          expect(Set(url.urlValue!.queryParameters.keys)) == ["key", "greeting", "int", "url"]
          expect(Set(url.urlStringValue.queryParameters.keys)) == ["key", "greeting", "int", "url"]
        }

        it("decodes a percent encoding") {
          expect(url.urlValue?.queryParameters["key"]) == "this is a value"
          expect(url.urlStringValue.queryParameters["key"]) == "this is a value"
        }

        it("doesn't convert + to whitespace") {
          expect(url.urlValue?.queryParameters["greeting"]) == "hello+world!"
          expect(url.urlStringValue.queryParameters["greeting"]) == "hello+world!"
        }

        it("takes last value from duplicated keys") {
          expect(url.urlValue?.queryParameters["int"]) == "34"
          expect(url.urlStringValue.queryParameters["int"]) == "34"
        }

        it("has an url") {
          expect(url.urlValue?.queryParameters["url"]) == "https://foo/bar?hello=world"
        }
      }
    }

    describe("queryItems") {
      context("when there is no query string") {
        it("returns nil") {
          let url = "https://xoul.kr"
          expect(url.urlValue?.queryItems).to(beNil())
          expect(url.urlStringValue.queryItems).to(beNil())
        }
      }

      context("when there is an empty query string") {
        it("returns an empty array") {
          let url = "https://xoul.kr?"
          expect(url.urlValue?.queryItems) == []
          expect(url.urlStringValue.queryItems) == []
        }
      }

      context("when there is a query string") {
        let url = "https://xoul.kr?key=this%20is%20a%20value&greeting=hello+world!&int=12&int=34"

        it("has exact number of items") {
          expect(url.urlValue?.queryItems?.count) == 4
          expect(url.urlStringValue.queryItems?.count) == 4
        }

        it("decodes a percent encoding") {
          expect(url.urlValue?.queryItems?[0]) == URLQueryItem(name: "key", value: "this is a value")
          expect(url.urlStringValue.queryItems?[0]) == URLQueryItem(name: "key", value: "this is a value")
        }

        it("doesn't convert + to whitespace") {
          expect(url.urlValue?.queryItems?[1]) == URLQueryItem(name: "greeting", value: "hello+world!")
          expect(url.urlStringValue.queryItems?[1]) == URLQueryItem(name: "greeting", value: "hello+world!")
        }

        it("takes all duplicated keys") {
          expect(url.urlValue?.queryItems?[2]) == URLQueryItem(name: "int", value: "12")
          expect(url.urlValue?.queryItems?[3]) == URLQueryItem(name: "int", value: "34")
          expect(url.urlStringValue.queryItems?[2]) == URLQueryItem(name: "int", value: "12")
          expect(url.urlStringValue.queryItems?[3]) == URLQueryItem(name: "int", value: "34")
        }
      }
    }
  }
}
