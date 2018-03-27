//
//  File.swift
//  grokSwiftREST
//
//  Created by Christina Moulton on 2018-03-26.
//  Copyright © 2018 Christina Moulton. All rights reserved.
//

import Foundation

struct File: Codable {
  enum CodingKeys: String, CodingKey {
    case url = "raw_url"
    case content
  }

  let url: URL?
  let content: String?
}
