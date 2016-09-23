//
// Copyright (c) 2015 Zalando SE. All rights reserved.
//

import UIKit

public final class InMemoryStorage {

    public static let sharedStorage = InMemoryStorage()

    private static let defaultStorageName = "default"
    
    fileprivate let cache = NSCache<NSString, UIImage>()

    public convenience init() {
        self.init(name: InMemoryStorage.defaultStorageName)
    }

    public init(name: String) {
        cache.name = baseStoragePath + name
    }

}

extension InMemoryStorage: Storage {

    public func store(image: UIImage, data: Data?, forKey key: String) {
        cache.setObject(image, forKey: key as NSString, cost: cacheCost(forImage: image))
    }
    
    fileprivate func cacheCost(forImage image: UIImage) -> Int {
        let imagesCount = image.images?.count ?? 0
        return imagesCount * Int(image.size.width * image.size.height * image.scale * image.scale)
    }

    public func image(forKey key: String) -> UIImage? {
        return cache.object(forKey: key as NSString)
    }

    public func removeImage(forKey key: String) {
        cache.removeObject(forKey: key as NSString)
    }

    public func clearStorage() {
        cache.removeAllObjects()
    }

}
