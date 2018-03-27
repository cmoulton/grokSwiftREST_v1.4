//
//  PersistenceManager.swift
//  grokSwiftREST
//
//  Created by Christina Moulton on 2018-03-27.
//  Copyright © 2018 Christina Moulton. All rights reserved.
//

import Foundation


class PersistenceManager {
  enum Path: String {
    case Public = "Public"
    case Starred = "Starred"
    case MyGists = "MyGists"
  }

  class private func cachesDirectory() -> URL? {
    return FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first
  }

  class func save<T: Encodable>(_ itemToSave: T, path: Path) -> Bool {
    guard let directory = cachesDirectory() else {
      print("could not save - no caches directory")
      return false
    }
    let file = directory.appendingPathComponent(path.rawValue)
    let encoder = JSONEncoder()
    encoder.dateEncodingStrategy = .iso8601
    do {
      let itemAsData = try encoder.encode(itemToSave)
      // check for existing file
      if FileManager.default.fileExists(atPath: file.path) {
        try FileManager.default.removeItem(at: file)
      }
      // add the file
      FileManager.default.createFile(atPath: file.path, contents: itemAsData, attributes: nil)
    } catch {
      print(error)
      return false
    }
    return true
  }

  class func load<T: Decodable>(path: Path) -> T? {
    guard let directory = cachesDirectory() else {
      print("could not load - no caches directory")
      return nil
    }

    let file = directory.appendingPathComponent(path.rawValue)
    if !FileManager.default.fileExists(atPath: file.path) {
      print("could not load - no file at expected path")
      return nil
    }
    guard let itemAsData = FileManager.default.contents(atPath: directory.path) else {
      print("could not load - no data in file at expected path")
      return nil
    }

    let decoder = JSONDecoder()
    decoder.dateDecodingStrategy = .iso8601
    do {
      let item = try decoder.decode(T.self, from: itemAsData)
      return item
    } catch {
      print(error)
      return nil
    }
  }
}
