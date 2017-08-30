//
//  AppDelegate.swift
//  Example
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


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

  var window: UIWindow?

  func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?
  ) -> Bool {
    self.window = UIWindow(frame: UIScreen.main.bounds)
    guard let window = self.window else { return false }
    window.makeKeyAndVisible()
    window.backgroundColor = .white
    window.rootViewController = UINavigationController(rootViewController: UserListViewController())

    // Initialize navigation map
    NavigationMap.initialize()

    if let URL = launchOptions?[.url] as? URL {
      Navigator.present(URL)
    }

    return true
  }
  
  func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
    return self.openURL(url: url)
  }

  #if os(iOS)
  func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
    return self.openURL(url: url)
  }
  #endif
  
  private func openURL(url: URL) -> Bool {
    // Try open URL first
    if Navigator.open(url) {
      NSLog("Navigator: Open \(url)")
      return true
    }
    
    // Try present URL
    if Navigator.present(url, wrap: true) != nil {
      NSLog("Navigator: Present \(url)")
      return true
    }
    
    return false
  }

}
