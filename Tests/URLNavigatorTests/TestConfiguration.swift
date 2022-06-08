import Quick
import Stubber

final class TestConfiguration: QuickConfiguration {
  override class func configure(_ configuration: QCKConfiguration) {
    configuration.beforeEach {
      Stubber.clear()
    }
  }
}
