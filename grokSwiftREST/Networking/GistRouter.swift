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
  case getMine()
  case isStarred(String)
  case star(String)
  case unstar(String)
  case delete(String)

  func asURLRequest() throws -> URLRequest {
    var method: HTTPMethod {
      switch self {
      case .getAtPath, .getPublic, .getMyStarred, .getMine, .isStarred:
        return .get
      case .star:
        return .put
      case .unstar, .delete:
        return .delete
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
      case .getMine():
        relativePath = "gists"
      case .isStarred(let id):
        relativePath = "gists/\(id)/star"
      case .star(let id):
        relativePath = "gists/\(id)/star"
      case .unstar(let id):
        relativePath = "gists/\(id)/star"
      case .delete(let id):
        relativePath = "gists/\(id)"
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
