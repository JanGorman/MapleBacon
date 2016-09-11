//
//  Copyright (c) 2015 Zalando SE. All rights reserved.
//

import XCTest
import Foundation
import UIKit
import MapleBacon

public let timeout: TimeInterval = 10

class ImageManagerTests: XCTestCase {

    let imageManager = ImageManager.sharedManager

    func test_whenImageManagerAsksForImageAlreadyDownloaded_thenImageIsReturnedFromCache() {
        _ = imageManager.downloadImage(atUrl: URL(string: imageURL)!, cacheScaled: false, imageView: nil) {
            [unowned self] imageInstance, _ in
            if let _ = imageInstance {
                let cachedExpectation = self.expectation(description: "Testing Cached Image")

                _ = self.imageManager.downloadImage(atUrl: URL(string: imageURL)!, cacheScaled: false, imageView: nil) {
                    [unowned self] imageInstance, _ in
                    if let imageInstance = imageInstance {
                        if imageInstance.state == .cached {
                            cachedExpectation.fulfill()
                            XCTAssertFalse(self.imageManager.hasDownloadsInProgress(),
                                    "Image returned from cache but manager still has downloads in progress")
                        }
                    }
                }

                self.waitForExpectations(timeout: timeout) { error in
                    if error != nil {
                        XCTFail("Expectation failed")
                    }
                }
            }
        }
    }

    func test_whenImageManagerAsksForImageNotYetDownloaded_thenImageIsReturnedAsNew() {
        MapleBaconStorage.sharedStorage.removeImage(forKey: imageURL)
        let newImageExpectation = expectation(description: "Testing New Image")

        _ = imageManager.downloadImage(atUrl: URL(string: imageURL)!, cacheScaled: false, imageView: nil) {
            [unowned self] imageInstance, error -> Void in
            if let imageInstance = imageInstance {
                if imageInstance.state == .new {
                    newImageExpectation.fulfill()
                    XCTAssertFalse(self.imageManager.hasDownloadsInProgress(),
                            "Image downloaded but manager still has downloads in progress")
                }
            }
        }

        waitForExpectations(timeout: timeout) { error in
            if error != nil {
                XCTFail("Expectation failed")
            }
        }
    }

    func test_whenUsingImageManagerWithCustomStorage_imageIsStored() {
        let storage = InMemoryStorage(name: "customPath")
        storage.removeImage(forKey: imageURL)

        let newImageExpectation = expectation(description: "Testing New Image")

        _ = imageManager.downloadImage(atUrl: URL(string: imageURL)!, cacheScaled: false, imageView: nil,
                                       storage: storage) { imageInstance, _ in
                                        if let _ = imageInstance {
                                            newImageExpectation.fulfill()
                                            XCTAssertNotNil(storage.image(forKey: imageURL))
                                        }
        }

        waitForExpectations(timeout: timeout) { error in
            if error != nil {
                XCTFail("Expectation failed")
            }
        }
    }

}
