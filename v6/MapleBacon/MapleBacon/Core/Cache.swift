//
//  Copyright © 2020 Schnaub. All rights reserved.
//

import CryptoKit
import UIKit

enum CacheError: Error {
  case dataConversion
}

final class Cache<T: DataConvertible> where T.Result == T {

  private let memoryCache: MemoryCache<String, Data>
  private let diskCache: DiskCache

  private var observer: NSObjectProtocol!

  init(name: String) {
    self.memoryCache = MemoryCache(name: name)
    self.diskCache = DiskCache(name: name)

    let notifications = [UIApplication.willTerminateNotification, UIApplication.didEnterBackgroundNotification]
    notifications.forEach { notification in
      NotificationCenter.default.addObserver(self, selector: #selector(cleanDiskOnNotification), name: notification, object: nil)
    }
  }

  func store(value: T, forKey key: String, completion: ((Error?) -> Void)? = nil) {
    let safeKey = safeCacheKey(key)
    memoryCache[safeKey] = value.toData()
    diskCache.insert(value.toData(), forKey: safeKey, completion: completion)
  }

  func value(forKey key: String, completion: ((Result<CacheResult<T>, Error>) -> Void)? = nil) {
    let safeKey = safeCacheKey(key)

    if let value = memoryCache[safeKey] {
      completion?(convertToTargetType(value, type: .memory))
    } else {
      diskCache.value(forKey: safeKey) { [weak self] result in
        guard let self = self else {
          return
        }

        switch result {
        case .success(let data):
          // Promote to in-memory cache for faster access the next time
          self.memoryCache[safeKey] = data

          completion?(self.convertToTargetType(data, type: .disk))
        case .failure(let error):
          completion?(.failure(error))
        }
      }
    }
  }

  func clear(_ options: CacheClearOptions) {
    if options.contains(.memory) {
      memoryCache.clear()
    }
    if options.contains(.disk) {
      diskCache.clear()
    }
  }

  private func convertToTargetType(_ data: Data, type: CacheType) -> Result<CacheResult<T>, Error> {
    guard let targetType = T.convert(from: data) else {
      return .failure(CacheError.dataConversion)
    }
    return .success(.init(value: targetType, type: type))
  }

  private func safeCacheKey(_ key: String) -> String {
    if #available(iOS 13.0, *) {
      return cryptoSafeCacheKey(key)
    }
    return key.components(separatedBy: CharacterSet(charactersIn: "()/")).joined(separator: "-")
  }

  @objc private func cleanDiskOnNotification() {
    clear(.disk)
  }

}

@available(iOS 13.0, *)
private extension Cache {

  func cryptoSafeCacheKey(_ key: String) -> String {
    let hash = Insecure.MD5.hash(data: Data(key.utf8))
    return hash.compactMap { String.init(format: "%02x", $0) }.joined()
  }

}
