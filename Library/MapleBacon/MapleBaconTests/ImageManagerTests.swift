//
//  Copyright (c) 2015 Zalando SE. All rights reserved.
//

import XCTest
import Foundation
import UIKit
import MapleBacon

public let timeout: TimeInterval = 30

class ImageManagerTests: XCTestCase {

    let imageManager = ImageManager.sharedManager

    func test_whenImageManagerAsksForImageBeingDownloaded_thenImageInstanceReturnsDownloadingState() {
        MapleBaconStorage.sharedStorage.remove(imageForKey: imageURL)

        let downloadingImageExpectation = expectation(withDescription: "Testing Downloading Image")
        let downloadedImageExpectation = expectation(withDescription: "Testing Downloaded Image")

        _ = imageManager.downloadImage(atUrl: URL(string: imageURL)!, cacheScaled: false, imageView: nil, completion: {
            [unowned self] (imageInstance, _) in
            if let imageInstance = imageInstance {
                if imageInstance.state == .new {
                    downloadedImageExpectation.fulfill()
                    XCTAssertFalse(self.imageManager.hasDownloadsInProgress(),
                            "Image downloaded but manager still has downloads in progress")
                }
            }
        })
        
        _ = imageManager.downloadImage(atUrl: URL(string: imageURL)!, cacheScaled: false, imageView: nil, completion: {
            [unowned self] (imageInstance, _) in
            if let imageInstance = imageInstance {
                if imageInstance.state == .downloading {
                    downloadingImageExpectation.fulfill()
                    XCTAssertTrue(self.imageManager.hasDownloadsInProgress(),
                            "Image downloading but manager has no downloads in progress")
                }
            }
        })

        waitForExpectations(withTimeout: timeout) {
            error in
            if nil != error {
                XCTFail("Expectation failed")
            }
        }
    }

    func test_whenImageManagerAsksForImageAlreadyDownloaded_thenImageIsReturnedFromCache() {
        
        _ = imageManager.downloadImage(atUrl: URL(string: imageURL)!, cacheScaled: false, imageView: nil, completion: {
            [unowned self] (imageInstance, _) in
            if let _ = imageInstance {
                let cachedExpectation = self.expectation(withDescription: "Testing Cached Image")

                self.imageManager.downloadImage(atUrl: URL(string: imageURL)!, cacheScaled: false, imageView: nil, completion: {
                    [unowned self] (imageInstance, _) in
                    if let imageInstance = imageInstance {
                        if imageInstance.state == .cached {
                            cachedExpectation.fulfill()
                            XCTAssertFalse(self.imageManager.hasDownloadsInProgress(),
                                    "Image returned from cache but manager still has downloads in progress")
                        }
                    }
                })

                self.waitForExpectations(withTimeout: timeout) {
                    error in
                    if nil != error {
                        XCTFail("Expectation failed")
                    }
                }
            }
        })
    }

    func test_whenImageManagerAsksForImageNotYetDownloaded_thenImageIsReturnedAsNew() {
        MapleBaconStorage.sharedStorage.remove(imageForKey: imageURL)
        let newImageExpectation = expectation(withDescription: "Testing New Image")

        _ = imageManager.downloadImage(atUrl: URL(string: imageURL)!, cacheScaled: false, imageView: nil, completion: {
            [unowned self] imageInstance, error -> Void in
            if let imageInstance = imageInstance {
                if imageInstance.state == .new {
                    newImageExpectation.fulfill()
                    XCTAssertFalse(self.imageManager.hasDownloadsInProgress(),
                            "Image downloaded but manager still has downloads in progress")
                }
            }
        })

        waitForExpectations(withTimeout: timeout) {
            error in
            if nil != error {
                XCTFail("Expectation failed")
            }
        }
    }

    func test_whenUsingImageManagerWithCustomStorage_imageIsStored() {
        let storage = InMemoryStorage(name: "customPath")
        storage.remove(imageForKey: imageURL)

        let newImageExpectation = expectation(withDescription: "Testing New Image")

        _ = imageManager.downloadImage(atUrl: URL(string: imageURL)!, cacheScaled: false, imageView: nil, storage: storage) {
            imageInstance, _ in
            if let _ = imageInstance {
                newImageExpectation.fulfill()
                XCTAssertNotNil(storage.image(forKey: imageURL))
            }
        }

        waitForExpectations(withTimeout: timeout) {
            error in
            if nil != error {
                XCTFail("Expectation failed")
            }
        }
    }

}
