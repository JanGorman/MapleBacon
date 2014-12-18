//
//  Copyright (c) 2014 Zalando SE. All rights reserved.
//

import UIKit

public protocol Storage {

    func storeImage(image: UIImage, data: NSData?, forKey key: String)

    func image(forKey key: String) -> UIImage?

    func removeImage(forKey key: String)

    func clearStorage()

}

public protocol CombinedStorage {

    func clearMemoryStorage()

}

public class MapleBaconStorage: Storage, CombinedStorage {

    let inMemoryStorage: Storage
    let diskStorage: Storage

    public class var sharedStorage: MapleBaconStorage {

        struct Singleton {
            static let instance = MapleBaconStorage()
        }

        return Singleton.instance
    }

    init() {
        inMemoryStorage = InMemoryStorage.sharedStorage
        diskStorage = DiskStorage.sharedStorage
    }

    public func storeImage(image: UIImage, data: NSData?, forKey key: String) {
        inMemoryStorage.storeImage(image, data: data, forKey: key)
        diskStorage.storeImage(image, data: data, forKey: key)
    }

    public func image(forKey key: String) -> UIImage? {
        if let image = inMemoryStorage.image(forKey: key) {
            return image
        }
        if let image = diskStorage.image(forKey: key) {
            inMemoryStorage.storeImage(image, data: nil,  forKey: key)
            return image
        }
        return nil
    }

    public func removeImage(forKey key: String) {
        inMemoryStorage.removeImage(forKey: key)
        diskStorage.removeImage(forKey: key)
    }

    public func clearStorage() {
        inMemoryStorage.clearStorage()
        diskStorage.clearStorage()
    }

    public func clearMemoryStorage() {
        inMemoryStorage.clearStorage()
    }

}
