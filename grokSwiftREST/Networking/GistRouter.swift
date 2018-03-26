//
//  GistRouter.swift
//  grokSwiftREST
//
//  Created by Christina Moulton on 2018-03-22.
//  Copyright © 2018 Christina Moulton. All rights reserved.
//

import Foundation
import Alamofire

enum GistRouter: URLRequestConvertible {
  static let baseURLString = "https://api.github.com/"

  case getPublic()
  case getMyStarred()
  case getAtPath(String)

  func asURLRequest() throws -> URLRequest {
    var method: HTTPMethod {
      switch self {
      case .getAtPath, .getPublic, .getMyStarred:
        return .get

      }
    }

    let url: URL = {
      let relativePath: String
      switch self {
      case .getAtPath(let path):
        // already have the full URL, so just return it
        return URL(string: path)!
      case .getPublic():
        relativePath = "gists/public"
      case .getMyStarred:
        relativePath = "gists/starred"
      }

      var url = URL(string: GistRouter.baseURLString)!
      url.appendPathComponent(relativePath)
      return url
    }()

    // for now, ignore params

    var urlRequest = URLRequest(url: url)
    urlRequest.httpMethod = method.rawValue

    // Set OAuth token if we have one
    if let token = GitHubAPIManager.shared.OAuthToken {
      urlRequest.setValue("token \(token)", forHTTPHeaderField: "Authorization")
    }

    return urlRequest
  }
}
