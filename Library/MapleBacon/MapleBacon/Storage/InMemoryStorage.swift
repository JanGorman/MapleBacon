//
// Copyright (c) 2015 Zalando SE. All rights reserved.
//

import UIKit

public final class InMemoryStorage: NSCache {

    public static let sharedStorage = InMemoryStorage()

    public convenience init(name: String) {
        self.init()
        self.name = "de.zalando.MapleBacon.\(name)"
    }
    
    private override init() {
        super.init()
    }

}

extension InMemoryStorage: Storage {

    public func storeImage(image: UIImage, data: NSData?, forKey key: String) {
        setObject(image, forKey: key, cost: cacheCost(forImage: image))
    }
    
    private func cacheCost(forImage image: UIImage) -> Int {
        let imagesCount = image.images?.count ?? 0
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
