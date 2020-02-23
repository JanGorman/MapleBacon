//
//  Copyright © 2020 Schnaub. All rights reserved.
//

import CryptoKit
import Foundation

enum CacheError: Error {
  case dataConversion
}

struct Cache<T: DataConvertible> where T.Result == T {

  private let memoryCache: MemoryCache<String, Data>
  private let diskCache: DiskCache

  init(name: String) {
    self.memoryCache = MemoryCache(name: name)
    self.diskCache = DiskCache(name: name)
  }

  func store<T: DataConvertible>(value: T, forKey key: String, completion: ((Error?) -> Void)? = nil) {
    let safeKey = safeCacheKey(key)
    memoryCache[safeKey] = value.toData()
    diskCache.insert(value.toData(), forKey: safeKey, completion: completion)
  }

  func value(forKey key: String, completion: ((Result<T, Error>) -> Void)? = nil) {
    let safeKey = safeCacheKey(key)

    if let value = memoryCache[safeKey] {
      completion?(convertToTargetType(value))
    } else {
      diskCache.value(forKey: safeKey) { result in
        switch result {
        case .success(let data):
          completion?(self.convertToTargetType(data))
        case .failure(let error):
          completion?(.failure(error))
        }
      }
    }
  }

  private func convertToTargetType(_ data: Data) -> Result<T, Error> {
    guard let targetType = T.convert(from: data) else {
      return .failure(CacheError.dataConversion)
    }
    return .success(targetType)
  }

  private func safeCacheKey(_ key: String) -> String {
    key.components(separatedBy: CharacterSet(charactersIn: "()/")).joined(separator: "-")
  }

}

@available(iOS 13.0, *)
private extension Cache {

  func crytpoSafeCacheKey(_ key: String) -> String {
    let hash = Insecure.MD5.hash(data: Data(key.utf8))
    return hash.compactMap { String.init(format: "%02x", $0) }.joined()
  }

}
