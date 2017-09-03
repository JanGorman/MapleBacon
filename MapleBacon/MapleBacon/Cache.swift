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
  
  public init(name: String) {
    let cacheName = Cache.prefix + name
    memory.name = cacheName
    
    diskQueue = DispatchQueue(label: cacheName, qos: .background)
    
    let path = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).first!
    cachePath = (path as NSString).appendingPathComponent(name)
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
  
  public func clearMemory() {
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
    
}
