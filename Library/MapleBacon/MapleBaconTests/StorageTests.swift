//
//  Copyright (c) 2015 Zalando SE. All rights reserved.
//

import UIKit
import XCTest
import MapleBacon

class StorageTests: XCTestCase {

    let diskStorage = DiskStorage.sharedStorage
    let inMemoryStorage = InMemoryStorage.sharedStorage
    let combinedStorage = MapleBaconStorage.sharedStorage

    var testImage: UIImage?
    var storageKey: String?
    var defaultMaxAge: TimeInterval?

    override func setUp() {
        super.setUp()

        defaultMaxAge = diskStorage.maxAge

        if let path = Bundle(for: StorageTests.self).pathForResource("cupcakes", ofType: "jpg") {
            testImage = UIImage(contentsOfFile: path)
        } else {
            XCTFail("Missing image")
        }
    }

    override func tearDown() {
        super.tearDown()

        if let key = storageKey {
            diskStorage.remove(imageForKey: key)
            inMemoryStorage.remove(imageForKey: key)
            combinedStorage.remove(imageForKey: key)
        }
        diskStorage.maxAge = defaultMaxAge!
    }

    func asyncStoredImage(inStorage storage: Storage) -> UIImage? {
        
        let timeoutDate = NSDate(timeIntervalSinceNow: 1.0)
        var storedImage = storage.image(forKey: storageKey!)
        
        while storedImage == nil && timeoutDate.timeIntervalSinceNow > 0 {
            storedImage = storage.image(forKey: storageKey!)
            CFRunLoopRunInMode(CFRunLoopMode.defaultMode, 0.01, true)
        }
        
        return storedImage
    }

    func test_whenStoringOnDisk_itIsPersisted() {
        if let image = testImage {
            storageKey = #function

            diskStorage.store(image: image, forKey: storageKey!)
            XCTAssertNotNil(asyncStoredImage(inStorage: diskStorage))
        }
    }

    func test_whenDeletingImageFromDisk_itDoesNotExist() {
        if let image = testImage {
            storageKey = #function

            diskStorage.store(image: image, forKey: storageKey!)
            diskStorage.remove(imageForKey: storageKey!)

            XCTAssertNil(diskStorage.image(forKey: storageKey!))
        }
    }

    func test_whenStoringInMemory_itIsPersisted() {
        if let image = testImage {
            storageKey = #function
            
            inMemoryStorage.store(image: image, forKey: storageKey!)

            XCTAssertNotNil(inMemoryStorage.image(forKey: storageKey!))
        }
    }

    func test_whenDeletimgImageFromMemory_itDoesNotExist() {
        if let image = testImage {
            storageKey = #function

            inMemoryStorage.store(image: image, forKey: storageKey!)
            inMemoryStorage.remove(imageForKey: storageKey!)

            XCTAssertNil(inMemoryStorage.image(forKey: storageKey!))
        }
    }

    func test_whenStoringInBaseStorage_itIsPersisted() {
        if let image = testImage {
            storageKey = #function

            combinedStorage.store(image: image, forKey: storageKey!)

            XCTAssertNotNil(combinedStorage.image(forKey: storageKey!))
        }
    }

    func test_whenDeletingImageFromBaseStorage_itDoesNotExist() {
        if let image = testImage {
            storageKey = #function

            combinedStorage.store(image: image, forKey: storageKey!)
            combinedStorage.remove(imageForKey: storageKey!)

            XCTAssertNil(combinedStorage.image(forKey: storageKey!))
        }
    }

//    func test_whenImageIsStoredOnDiskOnly_itIsAddedToMemoryCache() {
//        if let image = testImage {
//            storageKey = __FUNCTION__
//
//            diskStorage.storeImage(image, forKey: storageKey!)
//
//            let diskImage = asyncStoredImage(inStorage: combinedStorage)
//            let memoryImage = inMemoryStorage.image(forKey: storageKey!)
//
//            XCTAssertNotNil(diskImage)
//            XCTAssertNotNil(memoryImage)
//            XCTAssertEqual(diskImage!, memoryImage!)
//        }
//    }

    func test_whenImageExpires_itIsDeleted() {
        if let image = testImage {
            storageKey = #function
            diskStorage.maxAge = 0.01;

            diskStorage.store(image: image, forKey: storageKey!)

            XCTAssertNil(asyncStoredImage(inStorage: diskStorage))
        }
    }

    func test_whenClearingInMemoryStorage_imageIsRemoved() {
        if let image = testImage {
            storageKey = #function
            
            inMemoryStorage.store(image: image, forKey: storageKey!)
            inMemoryStorage.clear()

            XCTAssertNil(inMemoryStorage.image(forKey: storageKey!))
        }
    }

    func test_whenClearingDiskStorage_imageIsRemoved() {
        if let image = testImage {
            storageKey = #function
            diskStorage.store(image: image, forKey: storageKey!)

            diskStorage.clear()

            XCTAssertNil(diskStorage.image(forKey: storageKey!))
        }
    }

    func test_whenUsingNamedStorage_itIsPersisted() {
        if let image = testImage {
            let storage = DiskStorage(name: "different")
            storageKey = #function

            storage.store(image: image, forKey: storageKey!)

            XCTAssertNotNil(asyncStoredImage(inStorage: storage))

            storage.clear()
        }
    }

    func test_whenClearingOnlyMemory_itIsStillPersistedOnDisk() {
        if let image = testImage {
            storageKey = #function
            
            combinedStorage.store(image: image, forKey: storageKey!)
            combinedStorage.clearMemoryStorage()

            XCTAssertNotNil(asyncStoredImage(inStorage: combinedStorage))
        }
    }

}
