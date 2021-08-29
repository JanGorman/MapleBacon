//
//  Copyright © 2021 Schnaub. All rights reserved.
//

import CryptoKit
import Foundation

struct BaconDiskCache {

  private static let domain = "com.schnaub.BaconDiskCache"

  var maxCacheAgeSeconds: TimeInterval = 7.days

  private let cacheName: String

  init(name: String) {
    cacheName = "\(Self.domain).\(name)"
  }

  func insert(_ data: Data, forKey key: String) throws {
    try store(data: data, key: key)
  }

  func value(forKey key: String) throws -> Data? {
    try read(key: key)
  }
}

extension BaconDiskCache {

  private func store(data: Data, key: String) throws {
    let cacheDirectory = try self.cacheDirectory()
    let fileURL = cacheDirectory.appendingPathComponent(key.SHA1())
    try data.write(to: fileURL)
  }

  private func read(key: String) throws -> Data? {
    let url = try self.cacheDirectory().appendingPathComponent(key.SHA1())
    return try FileManager.default.fileContents(at: url)
  }

  private func cacheDirectory() throws -> URL {
    let fileManger = FileManager.default

    let folderURL = try FileManager.default.url(for: .cachesDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
    let cacheDirectory = folderURL.appendingPathComponent(cacheName, isDirectory: true)
    guard !fileManger.fileExists(atPath: cacheDirectory.absoluteString) else {
      return cacheDirectory
    }
    try fileManger.createDirectory(at: cacheDirectory, withIntermediateDirectories: true, attributes: nil)
    return cacheDirectory
  }
}

extension String {
  func SHA1() -> Self {
    let hash = Insecure.SHA1.self
    let data = Data(self.utf8)
    return hash.hash(data: data).prefix(hash.byteCount).map { String(format: "%02hhx", $0) }.joined()
  }
}
