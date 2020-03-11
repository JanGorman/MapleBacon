//
//  Copyright © 2020 Schnaub. All rights reserved.
//

import UIKit

enum CacheError: Error {
  case dataConversion
}

final class Cache<T: DataConvertible> where T.Result == T {

  typealias CacheCompletion = (Result<CacheResult<T>, Error>) -> Void

  var maxCacheAgeSeconds: TimeInterval {
    get {
      diskCache.maxCacheAgeSeconds
    }
    set {
      diskCache.maxCacheAgeSeconds = newValue
    }
  }

  private let memoryCache: MemoryCache<String, Data>
  private let diskCache: DiskCache

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

  func value(forKey key: String, completion: CacheCompletion? = nil) {
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

  func clear(_ options: CacheClearOptions, completion: ((Error?) -> Void)? = nil) {
    if options.contains(.memory) {
      memoryCache.clear()
      if !options.contains(.disk) {
        completion?(nil)
      }
    }
    if options.contains(.disk) {
      diskCache.clear(completion)
    }
  }

  func isCached(forKey key: String) throws -> Bool {
    let safeKey = safeCacheKey(key)
    if memoryCache.isCached(forKey: safeKey) {
      return true
    }
    return try diskCache.isCached(forKey: safeKey)
  }

  @objc private func cleanDiskOnNotification() {
    clear(.disk)
  }

}

private extension Cache {

  func convertToTargetType(_ data: Data, type: CacheType) -> Result<CacheResult<T>, Error> {
    guard let targetType = T.convert(from: data) else {
      return .failure(CacheError.dataConversion)
    }
    return .success(.init(value: targetType, type: type))
  }

  func safeCacheKey(_ key: String) -> String {
    #if canImport(CryptoKit)
    if #available(iOS 13.0, *) {
      return cryptoSafeCacheKey(key)
    }
    #endif
    return key.components(separatedBy: CharacterSet(charactersIn: "()/")).joined(separator: "-")
  }

}

#if canImport(CryptoKit)
import CryptoKit

@available(iOS 13.0, *)
private extension Cache {

  func cryptoSafeCacheKey(_ key: String) -> String {
    let hash = Insecure.MD5.hash(data: Data(key.utf8))
    return hash.compactMap { String.init(format: "%02x", $0) }.joined()
  }

}
#endif
