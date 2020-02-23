//
//  Copyright © 2020 Schnaub. All rights reserved.
//

import Foundation

struct Cache {

  private let memoryCache: MemoryCache<String, Data>
  private let diskCache: DiskCache

  init(name: String) {
    self.memoryCache = MemoryCache(name: name)
    self.diskCache = DiskCache(name: name)
  }

  func store(value: Data, forKey key: String, completion: ((Error?) -> Void)? = nil) {
    let safeKey = safeCacheKey(key)
    memoryCache[safeKey] = value
    diskCache.insert(value, forKey: safeKey, completion: completion)
  }

  private func safeCacheKey(_ key: String) -> String {
    key.components(separatedBy: CharacterSet(charactersIn: "()/")).joined(separator: "-")
  }

}
