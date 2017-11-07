//
//  GitHub.swift
//  URLNavigatorExample
//
//  Created by Suyeol Jeon on 7/12/16.
//  Copyright © 2016 Suyeol Jeon. All rights reserved.
//

import Foundation

enum GitHub {
  static func repos(username: String, completion: @escaping (Result<[Repo]>) -> Void) {
    HTTP.request("/users/\(username)/repos?sort=updated") { result in
      result
        .map { data -> [Repo] in
          let repos = try? JSONDecoder().decode([Repo].self, from: data)
          return repos ?? []
        }
        .apply(completion)
    }
  }
}
