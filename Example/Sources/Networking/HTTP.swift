//
//  HTTP.swift
//  URLNavigatorExample
//
//  Created by Suyeol Jeon on 7/12/16.
//  Copyright © 2016 Suyeol Jeon. All rights reserved.
//

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

  func map<R>(_ selector: (T) throws -> R) rethrows -> Result<R> {
    switch self {
    case let .success(value):
      return .success(try selector(value))

    case let .failure(error):
      return .failure(error)
    }
  }

  func flatMap<R>(_ selector: (T) throws -> Result<R>) rethrows -> Result<R> {
    switch self {
    case let .success(value):
      return try selector(value)

    case let .failure(error):
      return .failure(error)
    }
  }

  func apply(_ f: (Result<T>) throws -> Void) rethrows -> Void {
    try f(self)
  }
}

struct HTTP {
  static let baseURLString: String = "https://api.github.com"

  /// Send a simple HTTP GET request
  static func request(_ urlString: String, completion: ((Result<Data>) -> Void)? = nil) {
    guard let url = URL(string: self.baseURLString + urlString) else { return }
    let task = URLSession.shared.dataTask(with: url) { data, response, error in
      DispatchQueue.main.async {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
      }
      if let error = error {
        DispatchQueue.main.async { completion?(.failure(error)) }
      } else if let data = data {
        DispatchQueue.main.async { completion?(.success(data)) }
      }
    }
    task.resume()
    UIApplication.shared.isNetworkActivityIndicatorVisible = true
  }
}
