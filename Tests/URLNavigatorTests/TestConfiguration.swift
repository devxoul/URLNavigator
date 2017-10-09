import Quick
import Stubber

final class TestConfiguration: QuickConfiguration {
  override class func configure(_ configuration: Configuration) {
    configuration.beforeEach {
      Stubber.clear()
    }
  }
}
