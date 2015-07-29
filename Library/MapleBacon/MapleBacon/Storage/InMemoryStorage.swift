//
// Copyright (c) 2015 Zalando SE. All rights reserved.
//

import UIKit

public class InMemoryStorage: NSCache, Storage {

    // Singleton Support
    public class var sharedStorage: InMemoryStorage {
        struct Singleton {
            static let shared = InMemoryStorage()
        }
        return Singleton.shared
    }

    public convenience init(name: String) {
        self.init()
        self.name = "de.zalando.MapleBacon.\(name)"
    }
    
    // Make it private so that only the top init is used
    private override init() {
        super.init()
    }

    public func storeImage(image: UIImage, data: NSData?, forKey key: String) {
        setObject(image, forKey: key, cost: cacheCost(forImage: image))
    }

    private func cacheCost(forImage image: UIImage) -> Int {
        var imagesCount = 0
        if let images = image.images {
            imagesCount = images.count
        }
        return imagesCount * Int(image.size.width * image.size.height * image.scale * image.scale)
    }

    public func image(forKey key: String) -> UIImage? {
        return objectForKey(key) as? UIImage
    }

    public func removeImage(forKey key: String) {
        removeObjectForKey(key)
    }

    public func clearStorage() {
        removeAllObjects()
    }

}
