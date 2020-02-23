//
//  Copyright © 2020 Schnaub. All rights reserved.
//

import Foundation

struct DiskCache {

  private static let domain = "com.schnaub.DiskCache"

  var maxCacheAgeSeconds: TimeInterval = 60 * 60 * 24 * 7

  private let diskQueue: DispatchQueue
  private let cacheName: String

  init(name: String) {
    let queueLabel = "\(Self.domain).\(name)"
    self.diskQueue = DispatchQueue(label: queueLabel, qos: .background)
    self.cacheName = "\(Self.domain).\(name)"
  }

  func insert(_ data: Data, forKey key: String, completion: ((Error?) -> Void)? = nil) {
    diskQueue.async {
      var writeError: Error?
      defer {
        DispatchQueue.main.async {
          completion?(writeError)
        }
      }
      do {
        try self.store(data: data, key: key)
      } catch {
        writeError = error
      }
    }
  }

  func clear(_ completion: ((Error?) -> Void)? = nil) {
    diskQueue.async {
      var clearError: Error?
      defer {
        DispatchQueue.main.async {
          completion?(clearError)
        }
      }
      do {
        let cacheDirectory = try self.cacheDirectory()
        try FileManager.default.removeItem(at: cacheDirectory)
      } catch {
        clearError = error
      }
    }
  }

  func clearExpired(_ completion: ((Error?) -> Void)? = nil) {
    diskQueue.async {
      var clearError: Error?
      defer {
        DispatchQueue.main.async {
          completion?(clearError)
        }
      }
      do {
        let expiredFiles = try self.expiredFileURLs()
        try expiredFiles.forEach { url in
          _ = try FileManager.default.removeItem(at: url)
        }
      } catch {
        clearError = error
      }
    }
  }

  func expiredFileURLs() throws -> [URL] {
    let cacheDirectory = try self.cacheDirectory()

    let keys: Set<URLResourceKey> = [.isDirectoryKey, .contentModificationDateKey]
    let contents = try? FileManager.default.contentsOfDirectory(at: cacheDirectory, includingPropertiesForKeys: Array(keys),
                                                                options: .skipsHiddenFiles)
    guard let files = contents else {
      return []
    }

    let expirationDate = Date(timeIntervalSinceNow: -maxCacheAgeSeconds)
    let expiredFileUrls = files.filter { url in
      let resource = try? url.resourceValues(forKeys: keys)
      let isDirectory = resource?.isDirectory
      guard let lastAccessDate = resource?.contentAccessDate else {
        return true
      }
      return isDirectory == false && lastAccessDate < expirationDate
    }
    return expiredFileUrls
  }

  private func store(data: Data, key: String) throws {
    let cacheDirectory = try self.cacheDirectory()
    let fileURL = cacheDirectory.appendingPathComponent(key)
    try data.write(to: fileURL)
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
