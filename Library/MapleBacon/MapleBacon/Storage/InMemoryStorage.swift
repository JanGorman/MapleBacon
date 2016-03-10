//
// Copyright (c) 2015 Zalando SE. All rights reserved.
//

import UIKit

/**
 * Handles the storing of images into NSCache
 */
public final class InMemoryStorage {

    /// Singleton obj
    public static let sharedStorage = InMemoryStorage()

    /// Default storage name for conveniance init
    private static let DefaultStorageName = MapleBaconConfig.sharedConfig.storage.defaultStorageName
    
    /// the cache
    private let cache = NSCache()

    /**
     Init with default storage name
     */
    public convenience init() {
        self.init(name: InMemoryStorage.DefaultStorageName)
    }

    /**
     Init with storage name
     
     - parameter name: the name
     */
    public init(name: String) {
        self.cache.name = baseStoragePath + name
    }

}

// MARK: - Storage -

/**
 * Add Storage - Protocol
 */
extension InMemoryStorage: Storage {

    public func storeImage(image: UIImage, forKey key: String) {
        self.cache.setObject(image, forKey: key, cost: self.cacheCost(forImage: image))
    }
    
    public func storeImage(data: NSData, forKey key: String) {
        guard let image: UIImage = UIImage.imageWithCachedData(data) else {
            return
        }
        self.storeImage(image, forKey: key)
    }
    
    private func cacheCost(forImage image: UIImage) -> Int {
        let imagesCount = image.images?.count ?? 0
        return imagesCount * Int(image.size.width * image.size.height * image.scale * image.scale)
    }

    public func image(forKey key: String) -> UIImage? {
        return cache.objectForKey(key) as? UIImage
    }

    public func removeImage(forKey key: String) {
        cache.removeObjectForKey(key)
    }

    public func clearStorage() {
        cache.removeAllObjects()
    }
}
