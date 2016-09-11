//
// Copyright (c) 2015 Zalando SE. All rights reserved.
//

import UIKit

public final class DiskStorage {

    public static let sharedStorage = DiskStorage()

    private static let queueLabel = "de.zalando.MapleBacon.Storage"

    fileprivate let fileManager = FileManager.default
    fileprivate let storageQueue = DispatchQueue(label: queueLabel, attributes: [])
    fileprivate let storagePath: String

    public var maxAge: TimeInterval = 60 * 60 * 24 * 7

    public convenience init() {
        self.init(name: "default")
    }

    public init(name: String) {
        let path = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).first! as NSString
        storagePath = path.appendingPathComponent(baseStoragePath + name)
        try? fileManager.createDirectory(atPath: storagePath, withIntermediateDirectories: true, attributes: nil)
    }

}

extension DiskStorage: Storage {
    
    public func store(image: UIImage, data: Data?, forKey key: String) {
        storageQueue.async { [weak self] in
            guard let data = data ?? UIImagePNGRepresentation(image), let storage = self else { return }
            storage.fileManager.createFile(atPath: storage.defaultStoragePath(forKey: key), contents: data,
                                           attributes: nil)
            storage.pruneStorage()
        }
    }
    
    public func image(forKey key: String) -> UIImage? {
        guard let data = try? Data(contentsOf: URL(fileURLWithPath: defaultStoragePath(forKey: key))) else { return nil }
        return UIImage.imageWithCachedData(data)
    }
    
    public func removeImage(forKey key: String) {
        storageQueue.async { [weak self] in
            guard let path = self?.defaultStoragePath(forKey: key) else { return }
            let _ = try? self?.fileManager.removeItem(atPath: path)
        }
    }
    
    public func clearStorage() {
        storageQueue.async { [weak self] in
            guard let path = self?.storagePath else { return }
            let _ = try? self?.fileManager.removeItem(atPath: path)
            let _ = try? self?.fileManager.createDirectory(atPath: path, withIntermediateDirectories: true,
                                                           attributes: nil)
        }
    }
    
    public func pruneStorage() {
        storageQueue.async { [unowned self] in
            let directoryURL = URL(fileURLWithPath: self.storagePath, isDirectory: true)
            let keys: [URLResourceKey] = [.isDirectoryKey, .contentModificationDateKey]
            guard let enumerator = self.fileManager.enumerator(at: directoryURL, includingPropertiesForKeys: keys,
                                                               options: .skipsHiddenFiles, errorHandler: nil) else { return }
            self.deleteExpiredFiles(self.expiredFiles(usingEnumerator: enumerator))
        }
    }

    fileprivate func defaultStoragePath(forKey key: String) -> String {
        return (storagePath as NSString).appendingPathComponent(key)
    }

    fileprivate func expiredFiles(usingEnumerator enumerator: FileManager.DirectoryEnumerator) -> [URL] {
        let expirationDate = Date(timeIntervalSinceNow: -maxAge)
        var expiredFiles: [URL] = []
        while let fileURL = enumerator.nextObject() as? URL {
            if self.isDirectory(fileURL) {
                enumerator.skipDescendants()
                continue
            }
            if let modificationDate = modificationDate(fileURL), (modificationDate as NSDate).laterDate(expirationDate) == expirationDate {
                expiredFiles.append(fileURL)
            }
        }
        return expiredFiles
    }

    fileprivate func isDirectory(_ fileURL: URL) -> Bool {
      var isDirectoryResource: AnyObject?
      try? (fileURL as NSURL).getResourceValue(&isDirectoryResource, forKey: .isDirectoryKey)
      guard let isDirectory = isDirectoryResource as? NSNumber else { return false }
      return isDirectory.boolValue
    }

    fileprivate func modificationDate(_ fileURL: URL) -> Date? {
        var modificationDateResource: AnyObject?
        try? (fileURL as NSURL).getResourceValue(&modificationDateResource, forKey: .contentModificationDateKey)
        return modificationDateResource as? Date
    }

    fileprivate func deleteExpiredFiles(_ files: [URL]) {
        for file in files {
          try? fileManager.removeItem(at: file)
        }
    }

}
