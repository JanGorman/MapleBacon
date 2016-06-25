//
// Copyright (c) 2015 Zalando SE. All rights reserved.
//

import UIKit

public final class DiskStorage {

    /// Singleton instance
    public static let sharedStorage = DiskStorage()
    private let useUuid: Bool = MapleBaconConfig.sharedConfig.storage.useUUID
    
    /// label for serial queue
    private static let queueLabel = MapleBaconConfig.sharedConfig.storage.queueLabel
    private let fileManager = FileManager.default()
    private let storageQueue = DispatchQueue(label: queueLabel, attributes: .serial, target: nil)
    private let storagePath: String
    public var maxAge: TimeInterval = 60 * 60 * 24 * 7

    public convenience init() {
        self.init(name: MapleBaconConfig.sharedConfig.storage.defaultStorageName)
    }

    public init(name: String) {
        guard let path: NSString = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).first! as NSString else {
            preconditionFailure("no paths available")
        }
        self.storagePath = path.appendingPathComponent(baseStoragePath + name)
        
        do {
            try fileManager.createDirectory(atPath: storagePath, withIntermediateDirectories: true, attributes: nil)
        } catch _ {
        }
    }

}

extension DiskStorage: Storage {
    
    public func store(image: UIImage, forKey key: String) {
        guard let data: Data = UIImagePNGRepresentation(image) else {
            return
        }
        self.store(data: data, forKey: key)
    }
    
    public func store(data: Data, forKey key: String) {
        
        storageQueue.async { 
            [unowned self] in
            self.fileManager.createFile(atPath: self.defaultPath(forKey: key), contents: data, attributes: nil)
            self.prune()
        }
    }
    
    public func image(forKey key: String) -> UIImage? {
        do {
            let data: Data = try Data(contentsOf: self.defaultUrl(forKey: key))
            return UIImage.image(withCachedData: data)
        } catch _ {
            return nil
        }
    }
    
    public func remove(imageForKey key: String) {

        storageQueue.async { 
            [unowned self] in
            
            do {
                try self.fileManager.removeItem(atPath: self.defaultPath(forKey: key))
            } catch _ {
            }
        }
    }
    
    public func clear() {
        
        storageQueue.async {
            
            do {
                try self.fileManager.removeItem(atPath: self.storagePath)
                try self.fileManager.createDirectory(atPath: self.storagePath, withIntermediateDirectories: true, attributes: nil)
            } catch _ {
            }
        }
    }
    
    public func prune() {
        
        storageQueue.async {
            
            let directoryURL = URL(fileURLWithPath: self.storagePath, isDirectory: true)
            
            guard let enumerator = self.fileManager.enumerator(at: directoryURL,
                includingPropertiesForKeys: [URLResourceKey.isDirectoryKey.rawValue, URLResourceKey.contentModificationDateKey.rawValue],
                options: .skipsHiddenFiles, errorHandler: nil) else {
                return
            }
            
            self.deleteExpiredFiles(files: self.expiredFiles(usingEnumerator: enumerator))
        }
    }

    private func defaultPath(forKey key: String) -> String {
        
        let digestedKey = (self.useUuid)
            ? NSUUID(namespace: defaultImageNs, name: key).uuidString.lowercased()
            : key.sha1()
        
        return (storagePath as NSString).appendingPathComponent(digestedKey)
    }
    
    private func defaultUrl(forKey key: String) -> URL {
        
        return URL(fileURLWithPath: self.defaultPath(forKey: key), isDirectory: true)
    }

    private func expiredFiles(usingEnumerator enumerator: FileManager.DirectoryEnumerator) -> [NSURL] {
        let expirationDate = NSDate(timeIntervalSinceNow: -maxAge)
        var expiredFiles = [NSURL]()
        while let fileURL = enumerator.nextObject() as? NSURL {
            if self.isDirectory(fileURL: fileURL) {
                enumerator.skipDescendants()
                continue
            }
            if let modificationDate = modificationDate(fileURL: fileURL) where modificationDate.laterDate(expirationDate as Date) == expirationDate {
                expiredFiles.append(fileURL)
            }
        }
        return expiredFiles
    }

    private func isDirectory(fileURL: NSURL) -> Bool {
        do {
            var isDirectoryResource: AnyObject?
            try fileURL.getResourceValue(&isDirectoryResource, forKey: URLResourceKey.isDirectoryKey)
            guard let isDirectory = isDirectoryResource as? NSNumber else {
                return false
            }
            return isDirectory.boolValue
        } catch _ {
        }
        return false
    }

    private func modificationDate(fileURL: NSURL) -> NSDate? {
        var modificationDateResource: AnyObject?
        do {
            try fileURL.getResourceValue(&modificationDateResource, forKey: URLResourceKey.contentModificationDateKey)
        } catch _ {
        }
        return modificationDateResource as? NSDate
    }

    private func deleteExpiredFiles(files: [NSURL]) {
        for file in files {
            do {
                try fileManager.removeItem(at: file as URL)
            } catch _ {
            }
        }
    }

}
