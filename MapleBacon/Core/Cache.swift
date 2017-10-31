//
//  Copyright © 2017 Jan Gorman. All rights reserved.
//

import UIKit

public enum CacheType {
  case none, memory, disk
}

/// The class responsible for caching images. Images will be cached both in memory and on disk.
public final class Cache {
  
  private static let prefix = "com.schnaub.Cache."

  /// The default `Cache` singleton
  public static let `default` = Cache(name: "default")

  public let cachePath: String
  
  private let memory = NSCache<NSString, AnyObject>()
  private let fileManager = FileManager.default
  private let diskQueue: DispatchQueue

  /// The max age to cache images on disk in seconds. Defaults to 7 days.
  public var maxCacheAgeSeconds: TimeInterval = 60 * 60 * 24 * 7

  /// Construct a new instance of the cache
  ///
  /// - Parameter name: The name of the cache. Used to construct a unique path on disk to store images in
  public init(name: String) {
    let cacheName = Cache.prefix + name
    memory.name = cacheName
    
    diskQueue = DispatchQueue(label: cacheName, qos: .background)
    
    let path = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).first!
    cachePath = (path as NSString).appendingPathComponent(name)

    NotificationCenter.default.addObserver(self, selector: #selector(clearMemory),
                                           name: .UIApplicationDidReceiveMemoryWarning, object: nil)
    NotificationCenter.default.addObserver(self, selector: #selector(cleanDisk), name: .UIApplicationWillTerminate,
                                           object: nil)
  }

  /// Stores an image in the cache. Images will be added to both memory and disk.
  ///
  /// - Parameters
  ///     - image: The image to cache
  ///     - key: The unique identifier of the image
  ///     - transformerId: An optional transformer ID appended to the key to uniquely identify the image
  ///     - completion: An optional closure called once the image has been persisted to disk. Runs on the main queue.
  public func store(_ image: UIImage, forKey key: String, transformerId: String? = nil, completion: (() -> Void)? = nil) {
    let cacheKey = makeCacheKey(key, identifier: transformerId)
    memory.setObject(image, forKey: cacheKey as NSString)
    diskQueue.async { [unowned self] in
      defer {
        DispatchQueue.main.async {
          completion?()
        }
      }
      self.storeImageToDisk(image, key: cacheKey)
    }
  }

  private func makeCacheKey(_ key: String, identifier: String?) -> String {
    guard let identifier = identifier, !identifier.isEmpty else { return key }
    return key + "-" + identifier
  }
  
  private func storeImageToDisk(_ image: UIImage, key: String) {
    guard let data = UIImagePNGRepresentation(image) else { return }
    createCacheDirectoryIfNeeded()
    let path = (cachePath as NSString).appendingPathComponent(key)
    fileManager.createFile(atPath: path, contents: data, attributes: nil)
  }
  
  private func createCacheDirectoryIfNeeded() {
    guard !fileManager.fileExists(atPath: self.cachePath) else { return }
    _ = try? fileManager.createDirectory(atPath: self.cachePath, withIntermediateDirectories: true, attributes: nil)
  }

  /// Retrieve an image from cache. Will look in both memory and on disk. When the image is only available on disk
  /// it will be stored again in memory for faster access.
  ///
  /// - Parameters
  ///     - key: The unique identifier of the image
  ///     - transformerId: An optional transformer ID appended to the key to uniquely identify the image
  ///     - completion: The completion called once the image has been retrieved from the cache
  public func retrieveImage(forKey key: String, transformerId: String? = nil, completion: (UIImage?, CacheType) -> Void) {
    let cacheKey = makeCacheKey(key, identifier: transformerId)
    if let image = memory.object(forKey: cacheKey as NSString) as? UIImage {
      completion(image, .memory)
      return
    }
    if let image = retrieveImageFromDisk(forKey: cacheKey) {
      store(image, forKey: cacheKey)
      completion(image, .disk)
      return
    }
    completion(nil, .none)
  }
  
  private func retrieveImageFromDisk(forKey key: String) -> UIImage? {
    let url = URL(fileURLWithPath: (cachePath as NSString).appendingPathComponent(key))
    guard let data = try? Data(contentsOf: url), let image = UIImage(data: data) else { return nil }
    return image
  }
  
  @objc public func clearMemory() {
    memory.removeAllObjects()
  }

  /// Clear the disk cache.
  ///
  /// - Parameter completion: An optional closure called once the cache has been cleared. Runs on the main queue.
  public func clearDisk(_ completion: (() -> Void)? = nil) {
    diskQueue.async { [unowned self] in
      defer {
        DispatchQueue.main.async {
          completion?()
        }
      }

      _ = try? self.fileManager.removeItem(atPath: self.cachePath)
      self.createCacheDirectoryIfNeeded()
    }
  }

  @objc private func cleanDisk() {
    diskQueue.async {
      for url in self.expiredFileUrls() {
        _ = try? self.fileManager.removeItem(at: url)
      }
    }
  }

  public func expiredFileUrls() -> [URL] {
    let cacheDirectory = URL(fileURLWithPath: cachePath)
    let keys: Set<URLResourceKey> = [.isDirectoryKey, .contentAccessDateKey, .totalFileAllocatedSizeKey]
    let contents = try? fileManager.contentsOfDirectory(at: cacheDirectory, includingPropertiesForKeys: Array(keys),
                                                        options: .skipsHiddenFiles)
    guard let files = contents else { return [] }

    let expirationDate = Date(timeIntervalSinceNow: -maxCacheAgeSeconds)
    let expiredFileUrls = files.filter { url in
      let resource = try? url.resourceValues(forKeys: keys)
      let isDirectory = resource?.isDirectory
      let lastAccessDate = resource?.contentAccessDate
      return isDirectory == false && (lastAccessDate as NSDate?)?.laterDate(expirationDate) == expirationDate
    }
    return expiredFileUrls
  }

}
