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
  case success(T)
  case failure(Error)

  var value: T? {
    switch self {
    case .success(let value):
      return value

    case .failure:
      return nil
    }
  }

  func map<R>(_ selector: (T) -> R) -> Result<R> {
    switch self {
    case .success(let value):
      return .success(selector(value))

    case .failure(let error):
      return .failure(error)
    }
  }

  func flatMap<R>(_ selector: (T) -> Result<R>) -> Result<R> {
    switch self {
    case .success(let value):
      return selector(value)

    case .failure(let error):
      return .failure(error)
    }
  }

}

struct HTTP {

  static var baseURLString: String? = "https://api.github.com"

  /// Send a simple HTTP GET request
  static func request(_ URLString: String, completion: ((Result<Any>) -> Void)? = nil) {
    let URLString = (self.baseURLString ?? "") + URLString
    guard let URL = URL(string: URLString) else { return }
    let task = URLSession.shared.dataTask(with: URL) { data, response, error in
      UIApplication.shared.isNetworkActivityIndicatorVisible = false
      if let error = error {
        NSLog("FAILURE: GET \(URLString) error=\(error)")
        DispatchQueue.main.async {
          completion?(.failure(error))
        }
        return
      }
      NSLog("SUCCESS: GET \(URLString)")
      if let data = data,
        let JSONObject = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) {
        DispatchQueue.main.async {
          completion?(.success(JSONObject))
        }
      } else {
        let JSONObject = [String: AnyObject]()
        DispatchQueue.main.async {
          completion?(.success(JSONObject))
        }
      }
    }
    task.resume()
    UIApplication.shared.isNetworkActivityIndicatorVisible = true
    NSLog("REQUEST: GET \(URLString)")
  }

}
