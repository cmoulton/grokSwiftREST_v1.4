//
//  GitHubAPIManager.swift
//  grokSwiftREST
//
//  Created by Christina Moulton on 2018-03-22.
//  Copyright © 2018 Christina Moulton. All rights reserved.
//

import Foundation
import Alamofire

class GitHubAPIManager {
  static let shared = GitHubAPIManager()

  // MARK: - Basic Auth
  func printMyStarredGistsWithBasicAuth() {
    Alamofire.request(GistRouter.getMyStarred())
      .responseString { response in
        guard let receivedString = response.result.value else {
          print("didn't get a string in the response")
          return
        }
        print(receivedString)
    }
  }

  func doGetWithBasicAuth() {
    let username = "myUsername"
    let password = "myPassword"
    Alamofire.request("https://httpbin.org/basic-auth/\(username)/\(password)")
      .authenticate(user: username, password: password)
      .responseString { response in
        if let receivedString = response.result.value {
          print(receivedString)
        } else if let error = response.result.error {
          print(error)
        }
    }
  }

  func doGetWithBasicAuthCredential() {
    let username = "myUsername"
    let password = "myPassword"

    let credential = URLCredential(user: username, password: password,
                                   persistence: .forSession)

    Alamofire.request("https://httpbin.org/basic-auth/\(username)/\(password)")
      .authenticate(usingCredential: credential)
      .responseString { response in
        if let receivedString = response.result.value {
          print(receivedString)
        } else if let error = response.result.error {
          print(error)
        }
    }
  }

  func clearCache() {
    let cache = URLCache.shared
    cache.removeAllCachedResponses()
  }

  func imageFrom(url: URL,
                 completionHandler: @escaping (UIImage?, Error?) -> Void) {
    Alamofire.request(url)
      .responseData { response in
        guard let data = response.data else {
          completionHandler(nil, response.error)
          return
        }

        let image = UIImage(data: data)
        completionHandler(image, nil)
    }
  }

  func printPublicGists() {
    Alamofire.request(GistRouter.getPublic())
      .responseString { response in
        if let receivedString = response.result.value {
          print(receivedString)
        }
    }
  }

  func fetchGists(_ urlRequest: URLRequestConvertible,
                  completionHandler: @escaping (Result<[Gist]>, String?) -> Void) {
    Alamofire.request(urlRequest)
      .responseData { response in
        let decoder = JSONDecoder()
        let result: Result<[Gist]> = decoder.decodeResponse(from: response)
        let next = self.parseNextPageFromHeaders(response: response.response)
        completionHandler(result, next)
    }
  }

  func fetchPublicGists(pageToLoad: String?,
                        completionHandler: @escaping (Result<[Gist]>, String?) -> Void) {
    if let urlString = pageToLoad {
      self.fetchGists(GistRouter.getAtPath(urlString), completionHandler: completionHandler)
    } else {
      self.fetchGists(GistRouter.getPublic(), completionHandler: completionHandler)
    }
  }

  private func parseNextPageFromHeaders(response: HTTPURLResponse?) -> String? {
    guard let linkHeader = response?.allHeaderFields["Link"] as? String else {
      return nil
    }
    /* looks like: <https://...?page=2>; rel="next", <https://...?page=6>; rel="last" */
    // so split on ","
    let components = linkHeader.components(separatedBy: ",")
    // now we have separate lines like '<https://...?page=2>; rel="next"'
    for item in components {
      // see if it's "next"
      let rangeOfNext = item.range(of: "rel=\"next\"", options: [])
      guard rangeOfNext != nil else {
        continue
      }
      // this is the "next" item, extract the URL
      let rangeOfPaddedURL = item.range(of: "<(.*)>;",
                                        options: .regularExpression,
                                        range: nil,
                                        locale: nil)
      guard let range = rangeOfPaddedURL else {
        return nil
      }
      // strip off the < and >;
      let start = item.index(range.lowerBound, offsetBy: 1)
      let end = item.index(range.upperBound, offsetBy: -2)
      let trimmedSubstring = item[start..<end]
      return String(trimmedSubstring)
    }
    return nil
  }
}
