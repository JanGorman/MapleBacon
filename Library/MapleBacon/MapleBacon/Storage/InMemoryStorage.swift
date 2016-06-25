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
    private let cache = Cache<NSString, UIImage>()

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

    public func store(image: UIImage, forKey key: String) {
        self.cache.setObject(image, forKey: key, cost: self.cacheCost(forImage: image))
    }
    
    public func store(data: Data, forKey key: String) {
        guard let image: UIImage = UIImage.image(withCachedData: data) else {
            return
        }
        self.store(image: image, forKey: key)
    }
    
    private func cacheCost(forImage image: UIImage) -> Int {
        let imagesCount = image.images?.count ?? 0
        return imagesCount * Int(image.size.width * image.size.height * image.scale * image.scale)
    }

    public func image(forKey key: String) -> UIImage? {
        return cache.object(forKey: key)
    }

    public func remove(imageForKey key: String) {
        cache.removeObject(forKey: key)
    }

    public func clear() {
        cache.removeAllObjects()
    }
}
