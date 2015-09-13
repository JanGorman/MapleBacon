//
// Copyright (c) 2015 Zalando SE. All rights reserved.
//

import UIKit

public final class DiskStorage {

    public static let sharedStorage = DiskStorage()

    private static let QueueLabel = "de.zalando.MapleBacon.Storage"

    private let fileManager = NSFileManager.defaultManager()
    private let storageQueue = dispatch_queue_create(QueueLabel, DISPATCH_QUEUE_SERIAL)
    private let storagePath: String
    public var maxAge: NSTimeInterval = 60 * 60 * 24 * 7


    public convenience init() {
        self.init(name: "default")
    }

    public init(name: String) {
        let path = NSSearchPathForDirectoriesInDomains(.CachesDirectory, .UserDomainMask, true).first! as NSString
        storagePath = path.stringByAppendingPathComponent(baseStoragePath + name)
        do {
            try fileManager.createDirectoryAtPath(storagePath, withIntermediateDirectories: true, attributes: nil)
        } catch _ {
        }
    }

}

extension DiskStorage: Storage {
    
    public func storeImage(image: UIImage, var data: NSData?, forKey key: String) {
        dispatch_async(storageQueue) { [unowned self] in
            if (data == nil) {
                data = UIImagePNGRepresentation(image)
            }
            self.fileManager.createFileAtPath(self.defaultStoragePath(forKey: key), contents: data!, attributes: nil)
            self.pruneStorage()
        }
    }
    
    public func image(forKey key: String) -> UIImage? {
        guard let data = NSData(contentsOfFile: defaultStoragePath(forKey: key)) else {
            return nil
        }
        return UIImage.imageWithCachedData(data)
    }
    
    public func removeImage(forKey key: String) {
        dispatch_async(storageQueue) { [unowned self] in
            do {
                try self.fileManager.removeItemAtPath(self.defaultStoragePath(forKey: key))
            } catch _ {
            }
        }
    }
    
    public func clearStorage() {
        dispatch_async(storageQueue) { [unowned self] in
            do {
                try self.fileManager.removeItemAtPath(self.storagePath)
                try self.fileManager.createDirectoryAtPath(self.storagePath, withIntermediateDirectories: true, attributes: nil)
            } catch _ {
            }
        }
    }
    
    public func pruneStorage() {
        dispatch_async(storageQueue) { [unowned self] in
            let directoryURL = NSURL(fileURLWithPath: self.storagePath, isDirectory: true)
            guard let enumerator = self.fileManager.enumeratorAtURL(directoryURL,
                includingPropertiesForKeys: [NSURLIsDirectoryKey, NSURLContentModificationDateKey],
                options: .SkipsHiddenFiles, errorHandler: nil) else {
                return
            }
            self.deleteExpiredFiles(self.expiredFiles(usingEnumerator: enumerator))
        }
    }

    private func defaultStoragePath(forKey key: String) -> String {
        return (storagePath as NSString).stringByAppendingPathComponent(key.MD5())
    }

    private func expiredFiles(usingEnumerator enumerator: NSDirectoryEnumerator) -> [NSURL] {
        let expirationDate = NSDate(timeIntervalSinceNow: -maxAge)
        var expiredFiles = [NSURL]()
        while let fileURL = enumerator.nextObject() as? NSURL {
            if self.isDirectory(fileURL) {
                enumerator.skipDescendants()
                continue
            }
            if let modificationDate = modificationDate(fileURL) where modificationDate.laterDate(expirationDate) == expirationDate {
                expiredFiles.append(fileURL)
            }
        }
        return expiredFiles
    }

    private func isDirectory(fileURL: NSURL) -> Bool {
        do {
            var isDirectoryResource: AnyObject?
            try fileURL.getResourceValue(&isDirectoryResource, forKey: NSURLIsDirectoryKey)
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
            try fileURL.getResourceValue(&modificationDateResource, forKey: NSURLContentModificationDateKey)
        } catch _ {
        }
        return modificationDateResource as? NSDate
    }

    private func deleteExpiredFiles(files: [NSURL]) {
        for file in files {
            do {
                try fileManager.removeItemAtURL(file)
            } catch _ {
            }
        }
    }

}
