//
//  URLNavigatorDelegate.swift
//  URLNavigator
//
//  Created by David Le on 1/8/17.
//  Copyright © 2017 Suyeol Jeon. All rights reserved.
//

import UIKit

///
/// Delegate methods to be called prior to opening a URL or presenting a view controller.
///
/// Each delegate method corresponds to a method of opening URLs or presenting view controllers in URLNavigator.
///
public protocol URLNavigatorDelegate: class {

    // MARK: Pushing View Controllers with URL
    
    /// Called before opening the URL. Default does nothing.
    /// This is called regardless if the presentation was successful.    
    ///
    /// - parameter url: The URL to find view controllers.
    /// - parameter from: The navigation controller which is used to push a view controller. Use application's top-most
    ///     view controller if `nil` is specified. `nil` by default.
    /// - parameter animated: Whether animates view controller transition or not. `true` by default.
    ///
    func willPush(url: URLConvertible, userInfo: [AnyHashable: Any]?, from: UINavigationController?, animated: Bool)
    
    
    /// Called before view controller is pushed. Default does nothing.
    ///
    /// - parameter viewController: The `UIViewController` instance to be pushed.
    /// - parameter from: The navigation controller which is used to push a view controller. Use application's top-most
    ///     view controller if `nil` is specified. `nil` by default.
    /// - parameter animated: Whether animates view controller transition or not. `true` by default.
    ///
    func willPush(viewController: UIViewController, from: UINavigationController?, animated: Bool)
    
    
    // MARK: Presenting View Controllers with URL
    
    /// Called before opening the URL. Default does nothing.
    /// This is called regardless if the presentation was successful.
    ///
    /// - parameter url: The URL to find view controllers.
    /// - parameter wrap: Wraps the view controller with a `UINavigationController` if `true` is specified. `false` by
    ///     default.
    /// - parameter from: The view controller which is used to present a view controller. Use application's top-most
    ///     view controller if `nil` is specified. `nil` by default.
    /// - parameter animated: Whether animates view controller transition or not. `true` by default.
    func willPresent(url: URLConvertible, userInfo: [AnyHashable: Any]?, wrap: Bool, from: UIViewController?, animated: Bool)
    
    
    /// Called before the view controller is presented. Default does nothing.
    /// This is called regardless if the presentation was successful.
    ///
    /// - parameter viewController: The `UIViewController` instance to be presented.
    /// - parameter wrap: Wraps the view controller with a `UINavigationController` if `true` is specified. `false` by
    ///     default.
    /// - parameter from: The view controller which is used to present a view controller. Use application's top-most
    ///     view controller if `nil` is specified. `nil` by default.
    /// - parameter animated: Whether animates view controller transition or not. `true` by default.
    func willPresent(viewController: UIViewController, wrap: Bool, from: UIViewController?, animated: Bool)
    
    
    // MARK: Opening URL
    
    /// Called when before opening the url. Default does nothing.
    /// This is called regardless if the presentation was successful.
    ///
    /// - parameter url: The URL to find `URLOpenHandler`s.
    func willOpen(url: URLConvertible)
}

public extension URLNavigatorDelegate {
    
    func willPush(url: URLConvertible, userInfo: [AnyHashable: Any]?, from: UINavigationController?, animated: Bool) {
        
    }

    func willPush(viewController: UIViewController, from: UINavigationController?, animated: Bool) {
        
    }
    
    func willPresent(url: URLConvertible, userInfo: [AnyHashable: Any]?, wrap: Bool, from: UIViewController?, animated: Bool) {
        
    }
    
    func willPresent(viewController: UIViewController, wrap: Bool, from: UIViewController?, animated: Bool) {
        
    }
    
    func willOpen(url: URLConvertible) {
        
    }
}
