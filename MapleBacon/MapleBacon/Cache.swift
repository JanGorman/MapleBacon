//
//  Copyright © 2017 Jan Gorman. All rights reserved.
//

import UIKit

public final class Cache {
  
  private static let prefix = "com.schnaub.Cache."
  
  public static let `default` = Cache(name: "default")
  
  public let cachePath: String
  
  private let memory = NSCache<NSString, AnyObject>()
  private let fileManager = FileManager()
  
  public init(name: String) {
    let cacheName = Cache.prefix + name
    memory.name = cacheName
    
    let path = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).first!
    cachePath = (path as NSString).appendingPathComponent(path)
  }
  
  public func store(_ image: UIImage, forKey key: String, completion: (() -> Void)? = nil) {
    memory.setObject(image, forKey: key as NSString)
    completion?()
  }
  
  public func retrieveImage(forKey key: String, completion: (UIImage?) -> Void) {
    if let image = memory.object(forKey: key as NSString) as? UIImage {
      completion(image)
    }
  }
    
}
