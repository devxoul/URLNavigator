import Nimble
import Quick

import URLMatcher

final class URLMatcherSpec: QuickSpec {
  override func spec() {
    var matcher: URLMatcher!

    beforeEach {
      matcher = URLMatcher()
    }
  }
}
