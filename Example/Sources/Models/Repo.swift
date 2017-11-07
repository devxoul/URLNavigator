//
//  Repo.swift
//  URLNavigatorExample
//
//  Created by Suyeol Jeon on 7/12/16.
//  Copyright © 2016 Suyeol Jeon. All rights reserved.
//

struct Repo: Decodable {
  var name: String
  var descriptionText: String?
  var starCount: Int
  var urlString: String

  enum CodingKeys: String, CodingKey {
    case name = "name"
    case descriptionText = "description"
    case starCount = "stargazers_count"
    case urlString = "html_url"
  }
}
