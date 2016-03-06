//
// Copyright (c) 2015 Zalando SE. All rights reserved.
//

import UIKit

internal let baseStoragePath = "de.zalando.MapleBacon."

/// create default NS from ns:URL from http://www.ietf.org/rfc/rfc4122.txt
internal let defaultImageNs = NSUUID(
    namespace: NSUUID(UUIDString: "6ba7b811-9dad-11d1-80b4-00c04fd430c8")!,
    name: "de.zalando.MapleBacon.imagestore"
)

public protocol Storage {
    
    /**
     Should store an image
     
     - parameter image: the image
     - parameter key:   the key to save the image for
     */
    func storeImage(image: UIImage, forKey key: String)
    
    /**
     Should store the NSData
     
     - parameter data: the data
     - parameter key:  the key to save for
     */
    func storeImage(data: NSData, forKey key: String)
    
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
    func removeImage(forKey key: String)
    
    /**
     Clears the entire storage
     */
    func clearStorage()

}

public protocol CombinedStorage {

    func clearMemoryStorage()

}

public class MapleBaconStorage {

    /// Singleton instance
    public static let sharedInstance = MapleBaconStorage()
    
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

    public func storeImage(image: UIImage, forKey key: String) {
        
        self.adapters.forEach({$1.storeImage(image, forKey: key)})
    }
    
    public func storeImage(data: NSData, forKey key: String) {
        
        self.adapters.forEach({$1.storeImage(data, forKey: key)})
    }
    
    public func image(forKey key: String) -> UIImage? {
        
        if let image: UIImage = self.adapter(MapleBaconStorage.inMemoryStorage).image(forKey: key) {
            
            return image
        }
        
        var img: UIImage? = nil
        self.adapters.forEach({
        
            if nil != img {
                return
            }
            
            if MapleBaconStorage.inMemoryStorage == $0 {
                return
            }
            
            if let image: UIImage = $1.image(forKey: key) {
                img = image
            }
        })
        
        return img
    }
    
    public func removeImage(forKey key: String) {

        self.adapters.forEach({$1.removeImage(forKey: key)})
    }
    
    public func clearStorage() {
        
        self.adapters.forEach({$1.clearStorage()})
    }
    
}

extension MapleBaconStorage: CombinedStorage {

    public func clearMemoryStorage() {
        self.adapter(MapleBaconStorage.inMemoryStorage).clearStorage()
    }

}