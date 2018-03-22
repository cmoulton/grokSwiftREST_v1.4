//
//  Gist.swift
//  grokSwiftREST
//
//  Created by Christina Moulton on 2018-03-22.
//  Copyright © 2018 Christina Moulton. All rights reserved.
//

import Foundation

struct Gist: Codable {
  struct Owner: Codable {
    var login: String
    var avatarURL: URL?

    enum CodingKeys: String, CodingKey {
      case login
      case avatarURL = "avatar_url"
    }
  }

  var id: String
  var gistDescription: String?
  var url: String
  var owner: Owner?
}

