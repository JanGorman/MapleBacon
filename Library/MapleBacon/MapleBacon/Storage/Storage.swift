//
// Copyright (c) 2015 Zalando SE. All rights reserved.
//

import UIKit

internal let baseStoragePath = MapleBaconConfig.sharedConfig.storage.baseStoragePath

internal let defaultImageNs: UUID = NSUUID(
    namespace: UUID(uuidString: MapleBaconConfig.sharedConfig.storage.rootUUIDNamespace)!,
    name: MapleBaconConfig.sharedConfig.storage.baseUUIDName
) as UUID

public protocol Storage {
    /**
     Should store an image
     
     - parameter image: the image
     - parameter key:   the key to save the image for
     */
    func store(image: UIImage, forKey key: String)
    
    /**
     Should store the NSData
     
     - parameter data: the data
     - parameter key:  the key to save for
     */
    func store(data: Data, forKey key: String)
    
    /**
     Returns an image for a given key
     
     - parameter key: the key
     
     - returns: the image
     */
    func image(forKey key: String) -> UIImage?
    
    /**
     Removes an image with the given key
     
     - parameter key: the key
     */
    func remove(imageForKey key: String)
    
    /**
     Clears the entire storage
     */
    func clear()
}

public protocol CombinedStorage {
    func clearMemoryStorage()
}

public class MapleBaconStorage {

    /// Singleton instance
    public static let sharedStorage = MapleBaconStorage()
    
    /// Available storages
    private static let inMemoryStorage = "mem"
    private static let diskStorage     = "disk"
    
    /// Holds all available storage adapters
    private var adapters: [String: Storage]

    /**
     Private init
     Creates all storage adapters and inits the general storage
     */
    private init() {
        self.adapters = [
            MapleBaconStorage.inMemoryStorage: InMemoryStorage.sharedStorage,
            MapleBaconStorage.diskStorage: DiskStorage.sharedStorage
        ]
    }

    /**
     Returns an adapter requested by its name
     
     - parameter name: the adapter name (use constants!)
     
     - returns: the adapter
     */
    private func adapter(name: String) -> Storage {
        guard let adapter: Storage = self.adapters[name] else {
            preconditionFailure("unknown adapter requested")
        }
        return adapter
    }
}

extension MapleBaconStorage: Storage {

    public func store(image: UIImage, forKey key: String) {
        
        self.adapters.forEach { $1.store(image: image, forKey: key) }
    }
    
    public func store(data: Data, forKey key: String) {
        
        self.adapters.forEach {$1.store(data: data, forKey: key) }
    }
    
    public func image(forKey key: String) -> UIImage? {
        
        // try reading from memory first
        if let image: UIImage = self.adapter(name: MapleBaconStorage.inMemoryStorage).image(forKey: key) {
            return image
        }
        
        // read from all other if it fails
        var img: UIImage? = nil
        self.adapters.forEach {
            
            // in order to complete the forEach without break we skip
            // results if another is found previously
            if nil != img {
                return
            }
            
            // We do not ask memory storage again as we did before
            if MapleBaconStorage.inMemoryStorage == $0 {
                return
            }
            
            if let image: UIImage = $1.image(forKey: key) {
                img = image
            }
        }
        return img
    }
    
    public func remove(imageForKey key: String) {
        self.adapters.forEach { $1.remove(imageForKey: key) }
    }
    
    public func clear() {
        self.adapters.forEach { $1.clear() }
    }
}

extension MapleBaconStorage: CombinedStorage {
    public func clearMemoryStorage() {
        self.adapter(name: MapleBaconStorage.inMemoryStorage).clear()
    }
}
