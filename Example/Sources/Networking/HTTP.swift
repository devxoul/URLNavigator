//
//  HTTP.swift
//  URLNavigator
//
//  Created by Suyeol Jeon on 7/12/16.
//  Copyright © 2016 Suyeol Jeon. All rights reserved.
//

import Foundation
import UIKit

enum Result<T> {
    case Success(T)
    case Failure(ErrorType)

    var value: T? {
        switch self {
        case .Success(let value):
            return value

        case .Failure:
            return nil
        }
    }

    func map<R>(selector: T -> R) -> Result<R> {
        switch self {
        case .Success(let value):
            return .Success(selector(value))

        case .Failure(let error):
            return .Failure(error)
        }
    }

    func flatMap<R>(selector: T -> Result<R>) -> Result<R> {
        switch self {
        case .Success(let value):
            return selector(value)

        case .Failure(let error):
            return .Failure(error)
        }
    }

}

struct HTTP {

    static var baseURLString: String? = "https://api.github.com"

    /// Send a simple HTTP GET request
    static func request(URLString: String, completion: (Result<AnyObject> -> Void)? = nil) {
        let URLString = (self.baseURLString ?? "") + URLString
        guard let URL = URL(string: URLString) else { return }
        let task = NSURLSession.sharedSession().dataTaskWithURL(URL) { data, response, error in
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
            if let error = error {
                NSLog("FAILURE: GET \(URLString) error=\(error)")
                dispatch_async(dispatch_get_main_queue()) {
                    completion?(.Failure(error))
                }
                return
            }
            NSLog("SUCCESS: GET \(URLString)")
            if let data = data,
               let JSONObject = try? NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments) {
                dispatch_async(dispatch_get_main_queue()) {
                    completion?(.Success(JSONObject))
                }
            } else {
                let JSONObject = [String: AnyObject]()
                dispatch_async(dispatch_get_main_queue()) {
                    completion?(.Success(JSONObject))
                }
            }
        }
        task.resume()
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        NSLog("REQUEST: GET \(URLString)")
    }

}
