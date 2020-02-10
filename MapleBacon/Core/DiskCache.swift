//
//  Copyright © 2019 Jan Gorman. All rights reserved.
//

import UIKit

final class DiskCache {

  private static let prefix = "com.schnaub.DiskCache."

  let cachePath: String
  var maxCacheAgeSeconds: TimeInterval = 60 * 60 * 24 * 7

  private let backingStore: BackingStore
  private let diskQueue: DispatchQueue

  init(name: String, backingStore: BackingStore = FileManager.default) {
    self.backingStore = backingStore
    let queueLabel = Self.prefix + name
    self.diskQueue = DispatchQueue(label: queueLabel, qos: .background)

    let path = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).first!
    cachePath = (path as NSString).appendingPathComponent(name)

    let notifications = [UIApplication.willTerminateNotification, UIApplication.didEnterBackgroundNotification]
    notifications.forEach { notification in
      NotificationCenter.default.addObserver(self, selector: #selector(cleanDiskOnNotification), name: notification, object: nil)
    }
  }

  func insert(_ value: Data?, forKey key: String, completion: (() -> Void)?) {
    diskQueue.async {
      defer {
        DispatchQueue.main.async {
          completion?()
        }
      }
      if let value = value {
        self.storeDataToDisk(value, key: key)
      }
    }
  }

  func value(forKey key: String) -> Data? {
    let url = URL(fileURLWithPath: cachePath).appendingPathComponent(key)
    return try? backingStore.fileContents(at: url)
  }

  private func storeDataToDisk(_ data: Data, key: String) {
    createCacheDirectoryIfNeeded()
    let path = (cachePath as NSString).appendingPathComponent(key)
    backingStore.createFile(atPath: path, contents: data, attributes: nil)
  }

  private func createCacheDirectoryIfNeeded() {
    guard !backingStore.fileExists(atPath: cachePath) else {
      return
    }
    try? backingStore.createDirectory(atPath: cachePath, withIntermediateDirectories: true, attributes: nil)
  }

  func clearDisk(_ completion: (() -> Void)?) {
    diskQueue.async {
      defer {
        DispatchQueue.main.async {
          completion?()
        }
      }

      try? self.backingStore.removeItem(atPath: self.cachePath)
      self.createCacheDirectoryIfNeeded()
    }
  }

  @objc
  private func cleanDiskOnNotification() {
    cleanDisk(completion: nil)
  }

  func cleanDisk(completion: (() -> Void)?) {
    diskQueue.async {
      for url in self.expiredFileUrls() {
        _ = try? self.backingStore.removeItem(at: url)
      }
      DispatchQueue.main.async {
        completion?()
      }
    }
  }

  func expiredFileUrls() -> [URL] {
    let cacheDirectory = URL(fileURLWithPath: cachePath)
    let keys: Set<URLResourceKey> = [.isDirectoryKey, .contentModificationDateKey]
    let contents = try? backingStore.contentsOfDirectory(at: cacheDirectory, includingPropertiesForKeys: Array(keys),
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

}
