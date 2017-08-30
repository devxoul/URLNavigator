//
//  NavigationMap.swift
//  URLNavigator
//
//  Created by Suyeol Jeon on 7/12/16.
//  Copyright © 2016 Suyeol Jeon. All rights reserved.
//

import UIKit

#if os(tvOS)
  import URLNavigator_tvOS
#else
  import URLNavigator
#endif


struct NavigationMap {

  static func initialize() {
    Navigator.map("navigator://user/<username>", UserViewController.self)
    Navigator.map("http://<path:_>", WebViewController.self)
    Navigator.map("https://<path:_>", WebViewController.self)
    Navigator.map("navigator://alert", self.alert)
    
    Navigator.map("navigator://<path:_>") { (url, values) -> Bool in
        // No navigator match, do analytics or fallback function here
        print("global fallback function called")
        return true
    }

  }

  private static func alert(URL: URLConvertible, values: [String: Any]) -> Bool {
    let title = URL.queryParameters["title"]
    let message = URL.queryParameters["message"]
    let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
    alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
    Navigator.present(alertController)
    return true
  }

}
