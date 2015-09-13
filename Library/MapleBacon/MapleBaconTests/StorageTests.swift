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
    var defaultMaxAge: NSTimeInterval?

    override func setUp() {
        super.setUp()

        defaultMaxAge = diskStorage.maxAge

        if let path = NSBundle(forClass: StorageTests.self).pathForResource("cupcakes", ofType: "jpg") {
            testImage = UIImage(contentsOfFile: path)
        } else {
            XCTFail("Missing image")
        }
    }

    override func tearDown() {
        super.tearDown()

        if let key = storageKey {
            diskStorage.removeImage(forKey: key)
            inMemoryStorage.removeImage(forKey: key)
            combinedStorage.removeImage(forKey: key)
        }
        diskStorage.maxAge = defaultMaxAge!
    }

    func asyncStoredImage(inStorage storage: Storage) -> UIImage? {
        let timeoutDate = NSDate(timeIntervalSinceNow: 1.0)
        var storedImage = storage.image(forKey: storageKey!)
        while storedImage == nil && timeoutDate.timeIntervalSinceNow > 0 {
            storedImage = storage.image(forKey: storageKey!)
            CFRunLoopRunInMode(kCFRunLoopDefaultMode, 0.01, true)
        }
        return storedImage
    }

    func test_whenStoringOnDisk_itIsPersisted() {
        if let image = testImage {
            storageKey = __FUNCTION__

            diskStorage.storeImage(image, data:nil, forKey: storageKey!)

            XCTAssertNotNil(asyncStoredImage(inStorage: diskStorage))
        }
    }

    func test_whenDeletingImageFromDisk_itDoesNotExist() {
        if let image = testImage {
            storageKey = __FUNCTION__

            diskStorage.storeImage(image, data:nil, forKey: storageKey!)
            diskStorage.removeImage(forKey: storageKey!)

            XCTAssertNil(diskStorage.image(forKey: storageKey!))
        }
    }

    func test_whenStoringInMemory_itIsPersisted() {
        if let image = testImage {
            storageKey = __FUNCTION__

            inMemoryStorage.storeImage(image, data:nil, forKey: storageKey!)

            XCTAssertNotNil(inMemoryStorage.image(forKey: storageKey!))
        }
    }

    func test_whenDeletimgImageFromMemory_itDoesNotExist() {
        if let image = testImage {
            storageKey = __FUNCTION__

            inMemoryStorage.storeImage(image, data:nil, forKey: storageKey!)
            inMemoryStorage.removeImage(forKey: storageKey!)

            XCTAssertNil(inMemoryStorage.image(forKey: storageKey!))
        }
    }

    func test_whenStoringInBaseStorage_itIsPersisted() {
        if let image = testImage {
            storageKey = __FUNCTION__

            combinedStorage.storeImage(image, data:nil, forKey: storageKey!)

            XCTAssertNotNil(combinedStorage.image(forKey: storageKey!))
        }
    }

    func test_whenDeletingImageFromBaseStorage_itDoesNotExist() {
        if let image = testImage {
            storageKey = __FUNCTION__

            combinedStorage.storeImage(image, data:nil, forKey: storageKey!)
            combinedStorage.removeImage(forKey: storageKey!)

            XCTAssertNil(combinedStorage.image(forKey: storageKey!))
        }
    }

    func test_whenImageIsStoredOnDiskOnly_itIsAddedToMemoryCache() {
        if let image = testImage {
            storageKey = __FUNCTION__

            diskStorage.storeImage(image, data:nil, forKey: storageKey!)

            let diskImage = asyncStoredImage(inStorage: combinedStorage)
            let memoryImage = inMemoryStorage.image(forKey: storageKey!)

            XCTAssertNotNil(diskImage)
            XCTAssertNotNil(memoryImage)
            XCTAssertEqual(diskImage!, memoryImage!)
        }
    }

    func test_whenImageExpires_itIsDeleted() {
        if let image = testImage {
            storageKey = __FUNCTION__
            diskStorage.maxAge = 0.01;

            diskStorage.storeImage(image, data:nil, forKey: storageKey!)

            XCTAssertNil(asyncStoredImage(inStorage: diskStorage))
        }
    }

    func test_whenClearingInMemoryStorage_imageIsRemoved() {
        if let image = testImage {
            storageKey = __FUNCTION__
            inMemoryStorage.storeImage(image, data:nil, forKey: storageKey!)

            inMemoryStorage.clearStorage()

            XCTAssertNil(inMemoryStorage.image(forKey: storageKey!))
        }
    }

    func test_whenClearingDiskStorage_imageIsRemoved() {
        if let image = testImage {
            storageKey = __FUNCTION__
            diskStorage.storeImage(image, data:nil, forKey: storageKey!)

            diskStorage.clearStorage()

            XCTAssertNil(diskStorage.image(forKey: storageKey!))
        }
    }

    func test_whenUsingNamedStorage_itIsPersisted() {
        if let image = testImage {
            let storage = DiskStorage(name: "different")
            storageKey = __FUNCTION__

            storage.storeImage(image, data:nil, forKey: storageKey!)

            XCTAssertNotNil(asyncStoredImage(inStorage: storage))

            storage.clearStorage()
        }
    }

    func test_whenClearingOnlyMemory_itIsStillPersistedOnDisk() {
        if let image = testImage {
            storageKey = __FUNCTION__
            combinedStorage.storeImage(image, data:nil, forKey: storageKey!)

            combinedStorage.clearMemoryStorage()

            XCTAssertNotNil(asyncStoredImage(inStorage: combinedStorage))
        }
    }

}
