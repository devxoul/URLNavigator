//
//  API.swift
//  URLNavigator
//
//  Created by Suyeol Jeon on 7/12/16.
//  Copyright © 2016 Suyeol Jeon. All rights reserved.
//

import Foundation

struct API {

  static func repos(username: String, completion: @escaping (Result<[Repo]>) -> Void) {
    HTTP.request("/users/\(username)/repos?sort=updated") { result in
      let newResult = result.map { value -> [Repo] in
        let repoDicts = value as? [[String: AnyObject]] ?? []
        return repoDicts
          .flatMap { dict in
            guard let name = dict["name"] as? String,
              let starCount = dict["stargazers_count"] as? Int,
              let URLString = dict["html_url"] as? String
              else { return nil }
            let description = dict["description"] as? String
            return Repo(name: name,
                        descriptionText: description,
                        starCount: starCount,
                        URLString: URLString)
        }
      }
      completion(newResult)
    }
  }

}
