//
//  Copyright © 2017 Jan Gorman. All rights reserved.
//

import UIKit
#if canImport(CryptoKit)
import CryptoKit
#endif

public enum MapleBaconCacheError: Error {
  case imageNotFound
}

public enum CacheType {
  case none, memory, disk
}

/// The class responsible for caching images. Images will be cached both in memory and on disk.
public final class MapleBaconCache {

  private static let prefix = "com.schnaub.Cache."

  /// The default `Cache` singleton
  public static let `default` = MapleBaconCache(name: "default")

  public lazy var cachePath: String = {
    disk.cachePath
  }()
  
  private let memory: MemoryCache<String, Data>
  private let disk: DiskCache

  /// The max age to cache images on disk in seconds. Defaults to 7 days.
  public var maxCacheAgeSeconds: TimeInterval = 60 * 60 * 24 * 7 {
    didSet {
      disk.maxCacheAgeSeconds = maxCacheAgeSeconds
    }
  }

  /// - Parameters:
  ///   - name: The name of the cache. Used to construct a unique cache path
  ///   - backingStore: The backing store – defaults to `FileManager.default`
  public init(name: String, backingStore: BackingStore = FileManager.default) {
    let cacheName = Self.prefix + name

    memory = MemoryCache<String, Data>(name: cacheName)
    disk = DiskCache(name: name, backingStore: backingStore)
  }

  /// Stores an image in the cache. Images will be added to both memory and disk.
  ///
  /// - Parameters:
  ///     - data: The image data to cache
  ///     - key: The unique identifier of the image
  ///     - transformerId: An optional transformer ID appended to the key to uniquely identify the image
  ///     - completion: An optional closure called once the image has been persisted to disk. Runs on the main queue.
  public func store(data: Data? = nil, forKey key: String, transformerId: String? = nil,
                    completion: (() -> Void)? = nil) {
    let cacheKey = storeToMemory(data: data, forKey: key, transformerId: transformerId)
    disk.insert(data, forKey: cacheKey, completion: completion)
  }

  @discardableResult
  private func storeToMemory(data: Data?, forKey key: String, transformerId: String?) -> String {
    let cacheKey = makeCacheKey(key, identifier: transformerId)
    memory[cacheKey] = data
    return cacheKey
  }

  private func makeCacheKey(_ key: String, identifier: String?) -> String {
    if #available(iOS 13.0, *) {
      return makeMD5CacheKey(key, identifier: identifier)
    }
    let fileSafeKey = key.replacingOccurrences(of: "/", with: "-")
    guard let identifier = identifier, !identifier.isEmpty else {
      return fileSafeKey
    }
    return fileSafeKey + "-" + identifier
  }

  @available(iOS 13.0, *)
  private func makeMD5CacheKey(_ key: String, identifier: String?) -> String {
    let key = key + (identifier ?? "")
    let digest = Insecure.MD5.hash(data: Data(key.utf8))
    return digest.map { String(format: "%02hhx", $0) }.joined()
  }

  /// Retrieve an image from cache. Will look in both memory and on disk. When the image is only available on disk
  /// it will be stored again in memory for faster access.
  ///
  /// - Parameters
  ///     - key: The unique identifier of the image
  ///     - transformerId: An optional transformer ID appended to the key to uniquely identify the image
  ///     - completion: The completion called once the image has been retrieved from the cache
  public func retrieveImage(forKey key: String, transformerId: String? = nil, completion: (UIImage?, CacheType) -> Void) {
    retrieveData(forKey: key, transformerId: transformerId) { data, cacheType in
      guard let data = data else {
        completion(nil, cacheType)
        return
      }
      completion(UIImage(data: data), cacheType)
    }
  }

  /// Retrieve raw `Data` from cache. Will look in both memory and on disk. When the data is only available on disk
  /// it will be stored again in memory for faster access.
  ///
  /// - Parameters
  ///     - key: The unique identifier of the data
  ///     - transformerId: An optional transformer ID appended to the key to uniquely identify the data
  ///     - completion: The completion called once the image has been retrieved from the cache
  public func retrieveData(forKey key: String, transformerId: String? = nil, completion: (Data?, CacheType) -> Void) {
    let cacheKey = makeCacheKey(key, identifier: transformerId)
    if let data = memory[cacheKey] {
      completion(data, .memory)
      return
    }
    if let data = disk.value(forKey: cacheKey), !data.isEmpty {
      storeToMemory(data: data, forKey: key, transformerId: transformerId)
      completion(data, .disk)
      return
    }
    completion(nil, .none)
  }

  public func clearMemory() {
    memory.clear()
  }

  /// Clear the disk cache.
  ///
  /// - Parameter completion: An optional closure called once the cache has been cleared. Runs on the main queue.
  public func clearDisk(_ completion: (() -> Void)? = nil) {
    disk.clearDisk(completion)
  }

}

#if canImport(Combine)
import Combine

@available(iOS 13.0, *)
extension MapleBaconCache {

  public func storeAndPublish(data: Data? = nil, forKey key: String, transformerId: String? = nil) -> AnyPublisher<Void, Never> {
    let cacheKey = storeToMemory(data: data, forKey: key, transformerId: transformerId)
    return Future { resolve in
      self.disk.insert(data, forKey: cacheKey) {
        resolve(.success(()))
      }
    }.eraseToAnyPublisher()
  }

  public func retrieveImage(forKey key: String, transformerId: String? = nil) -> AnyPublisher<(UIImage?, CacheType), Never> {
    Future { resolve in
      self.retrieveData(forKey: key, transformerId: transformerId) { data, cacheType in
        guard let data = data else {
          return resolve(.success((nil, cacheType)))
        }
        return resolve(.success((UIImage(data: data), cacheType)))
      }
    }.eraseToAnyPublisher()
  }

  public func retrieveData(forKey key: String, transformerId: String? = nil) -> AnyPublisher<(Data?, CacheType), Never> {
    Future { resolve in
      self.retrieveData(forKey: key, transformerId: transformerId) { data, cacheType in
        resolve(.success((data, cacheType)))
      }
    }.eraseToAnyPublisher()
  }

}

#endif
