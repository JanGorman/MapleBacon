//
//  Copyright © 2018 Jan Gorman. All rights reserved.
//

import Foundation

public protocol BackingStore {
  
  func fileContents(at url: URL) throws -> Data
  
  func fileExists(atPath path: String) -> Bool
  
  @discardableResult
  func createFile(atPath path: String, contents data: Data?, attributes attr: [FileAttributeKey : Any]?) -> Bool
  func createDirectory(atPath path: String, withIntermediateDirectories createIntermediates: Bool,
                       attributes: [FileAttributeKey : Any]?) throws
  func removeItem(atPath path: String) throws
  func removeItem(at URL: URL) throws

  func contentsOfDirectory(at url: URL, includingPropertiesForKeys keys: [URLResourceKey]?,
                           options mask: FileManager.DirectoryEnumerationOptions) throws -> [URL]
  
}

extension FileManager: BackingStore {
  
  public func fileContents(at url: URL) throws -> Data {
    try Data(contentsOf: url, options: .mappedIfSafe)
  }
  
}
