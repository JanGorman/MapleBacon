//
// Copyright (c) 2015 Zalando SE. All rights reserved.
//

import UIKit

public class InMemoryStorage: Storage {

    let cache: NSCache = {
        return NSCache()
    }()

    public class var sharedStorage: InMemoryStorage {

        struct Singleton {
            static let instance = InMemoryStorage()
        }

        return Singleton.instance
    }

    public convenience init() {
        self.init(name: defaultStorageName)
    }

    public init(name: String) {
        cache.name = baseStoragePath + name
    }

    public func storeImage(image: UIImage, data: NSData?, forKey key: String) {
        cache.setObject(image, forKey: key, cost: cacheCost(forImage: image))
    }

    private func cacheCost(forImage image: UIImage) -> Int {
        var imagesCount = 0
        if let images = image.images {
            imagesCount = images.count
        }
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
