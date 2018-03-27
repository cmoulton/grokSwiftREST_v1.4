//
//  BackendError.swift
//  grokSwiftREST
//
//  Created by Christina Moulton on 2018-03-22.
//  Copyright © 2018 Christina Moulton. All rights reserved.
//

import Foundation

enum BackendError: Error {
  case network(error: Error)
  case unexpectedResponse(reason: String)
  case parsing(error: Error)
  case apiProvidedError(reason: String)
  case authCouldNot(reason: String)
  case authLost(reason: String)
  case missingRequiredInput(reason: String)
}

struct APIProvidedError: Codable {
  let message: String
}
