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
        let paths = NSSearchPathForDirectoriesInDomains(.CachesDirectory, .UserDomainMask, true) as! [String]
        storagePath = paths.first!.stringByAppendingPathComponent(baseStoragePath + name)
        
        do {
            try fileManager.createDirectoryAtPath(storagePath, withIntermediateDirectories: true, attributes: nil)
        } catch _ {
        }
    }

}

extension DiskStorage: Storage {
    
    public func storeImage(image: UIImage, var data: NSData?, forKey key: String) {
        dispatch_async(storageQueue) {
            if (data == nil) {
                data = UIImagePNGRepresentation(image)
            }
            self.fileManager.createFileAtPath(self.defaultStoragePath(forKey: key), contents: data!, attributes: nil)
            self.pruneStorage()
        }
    }
    
    public func image(forKey key: String) -> UIImage? {
        if let data = NSData(contentsOfFile: defaultStoragePath(forKey: key)) {
            return UIImage.imageWithCachedData(data)
        }
        return nil
    }
    
    public func removeImage(forKey key: String) {
        dispatch_async(storageQueue) {
            self.fileManager.removeItemAtPath(self.defaultStoragePath(forKey: key), error: nil)
        }
    }
    
    public func clearStorage() {
        dispatch_async(storageQueue) {
            self.fileManager.removeItemAtPath(self.storagePath, error: nil)
            self.fileManager.createDirectoryAtPath(self.storagePath, withIntermediateDirectories: true, attributes: nil,
                error: nil)
        }
    }
    
    public func pruneStorage() {
        dispatch_async(storageQueue) { [unowned self] in
            let directoryURL = NSURL(fileURLWithPath: self.storagePath, isDirectory: true)
            if let enumerator = self.fileManager.enumeratorAtURL(directoryURL,
                    includingPropertiesForKeys: [NSURLIsDirectoryKey, NSURLContentModificationDateKey],
                    options: .SkipsHiddenFiles,
                    errorHandler: nil) {
                        self.deleteExpiredFiles(self.expiredFiles(usingEnumerator: enumerator))
            }
        }
    }

    private func defaultStoragePath(forKey key: String) -> String {
        return storagePath.stringByAppendingPathComponent(key.MD5())
    }

    private func expiredFiles(usingEnumerator enumerator: NSDirectoryEnumerator) -> [NSURL] {
        let expirationDate = NSDate(timeIntervalSinceNow: -maxAge)
        var expiredFiles = [NSURL]()
        while let fileURL = enumerator.nextObject() as? NSURL {
            if self.isDirectory(fileURL) {
                enumerator.skipDescendants()
                continue
            }
            if let modificationDate = self.modificationDate(fileURL) {
                if modificationDate.laterDate(expirationDate) == expirationDate {
                    expiredFiles.append(fileURL)
                }
            }
        }
        return expiredFiles
    }

    private func isDirectory(fileURL: NSURL) -> Bool {
        var isDirectoryResource: AnyObject?
        do {
            try fileURL.getResourceValue(&isDirectoryResource, forKey: NSURLIsDirectoryKey)
        } catch _ {
        }
        if let isDirectory = isDirectoryResource as? NSNumber {
            return isDirectory.boolValue
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
        }
    }

}
