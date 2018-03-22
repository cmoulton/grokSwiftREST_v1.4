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

  func printPublicGists() {
    Alamofire.request(GistRouter.getPublic())
      .responseString { response in
        if let receivedString = response.result.value {
          print(receivedString)
        }
    }
  }

  func fetchPublicGists(completionHandler: @escaping (Result<[Gist]>) -> Void) {
    Alamofire.request(GistRouter.getPublic())
      .responseData { response in
        let decoder = JSONDecoder()
        let result: Result<[Gist]> = decoder.decodeResponse(from: response)
        completionHandler(result)
    }
  }
}
