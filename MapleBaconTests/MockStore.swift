//
//  Copyright © 2019 Jan Gorman. All rights reserved.
//

import Foundation
import MapleBacon

final class MockStore: BackingStore {

  private var backingStore: [String: Data] = [:]

  func fileContents(at url: URL) throws -> Data {
    guard let data = backingStore[path(from: url)] else {
      return Data()
    }
    return data
  }

  private func path(from url: URL) -> String {
    return url.absoluteString.deletingPrefix("file://")
  }

  func fileExists(atPath path: String) -> Bool {
    return false
  }

  func createFile(atPath path: String, contents data: Data?, attributes attr: [FileAttributeKey : Any]?) -> Bool {
    guard let data = data else {
      return false
    }
    backingStore[path] = data
    return true
  }

  func createDirectory(atPath path: String, withIntermediateDirectories createIntermediates: Bool,
                       attributes: [FileAttributeKey : Any]?) throws {
  }

  func removeItem(atPath path: String) throws {
    backingStore.removeAll()
  }

  func removeItem(at URL: URL) throws {
    backingStore[path(from: URL)] = nil
  }

  func contentsOfDirectory(at url: URL, includingPropertiesForKeys keys: [URLResourceKey]?,
                           options mask: FileManager.DirectoryEnumerationOptions) throws -> [URL] {
    let urls = backingStore.keys.map { URL(fileURLWithPath: $0) }
    return urls
  }

}
