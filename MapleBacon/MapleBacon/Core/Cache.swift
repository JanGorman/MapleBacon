//
//  Copyright © 2017 Jan Gorman. All rights reserved.
//

import UIKit

public enum CacheType {
  case none, memory, disk
}

public final class Cache {
  
  private static let prefix = "com.schnaub.Cache."
  
  public static let `default` = Cache(name: "default")

  public let cachePath: String
  
  private let memory = NSCache<NSString, AnyObject>()
  private let fileManager = FileManager.default
  private let diskQueue: DispatchQueue

  open var maxCacheAgeSeconds: TimeInterval = 60 * 60 * 60 * 24
  
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
  
  public func store(_ image: UIImage, forKey key: String, completion: (() -> Void)? = nil) {
    memory.setObject(image, forKey: key as NSString)
    diskQueue.async { [unowned self] in
      defer {
        DispatchQueue.main.async {
          completion?()
        }
      }
      self.storeImageToDisk(image, key: key)
    }
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
  
  public func retrieveImage(forKey key: String, completion: (UIImage?, CacheType) -> Void) {
    if let image = memory.object(forKey: key as NSString) as? UIImage {
      completion(image, .memory)
      return
    }
    if let image = retrieveImageFromDisk(forKey: key) {
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

  public func clearDisk(_ completion: (() -> Void)? = nil) {
    diskQueue.async { [unowned self] in
      defer {
        completion?()
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
