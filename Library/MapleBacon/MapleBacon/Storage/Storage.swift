//
// Copyright (c) 2015 Zalando SE. All rights reserved.
//

import UIKit

internal let baseStoragePath = "de.zalando.MapleBacon."

public protocol Storage {

    func store(image: UIImage, data: Data?, forKey key: String)
    func image(forKey key: String) -> UIImage?
    func removeImage(forKey key: String)
    func clearStorage()

}

public protocol CombinedStorage {

    func clearMemoryStorage()

}

public final class MapleBaconStorage {

    fileprivate let inMemoryStorage: Storage
    fileprivate let diskStorage: Storage

    public static let sharedStorage = MapleBaconStorage()

    private init() {
        inMemoryStorage = InMemoryStorage.sharedStorage
        diskStorage = DiskStorage.sharedStorage
    }

}

extension MapleBaconStorage: Storage {

    public func store(image: UIImage, data: Data?, forKey key: String) {
        inMemoryStorage.store(image: image, data: data, forKey: key)
        diskStorage.store(image: image, data: data, forKey: key)
    }
    
    public func image(forKey key: String) -> UIImage? {
        if let image = inMemoryStorage.image(forKey: key) {
            return image
        } else if let image = diskStorage.image(forKey: key) {
            inMemoryStorage.store(image: image, data: nil, forKey: key)
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
    
}

extension MapleBaconStorage: CombinedStorage {

    public func clearMemoryStorage() {
        inMemoryStorage.clearStorage()
    }

}
