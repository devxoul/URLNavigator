#if os(iOS) || os(tvOS)
import UIKit

final class ArticleViewController: UIViewController {
  let articleID: Int
  let context: Any?

  init(articleID: Int, context: Any? = nil) {
    self.articleID = articleID
    self.context = context
    super.init(nibName: nil, bundle: nil)
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

final class MyNavigationController: UINavigationController {
}
#endif
