//
//  Copyright (c) 2015 Zalando SE. All rights reserved.
//

import XCTest
import UIKit
@testable import MapleBacon

class ImageExtensionTests: XCTestCase {

    func test_whenImageViewRequestImageWithValidURL_thenImageViewHasImage() {
        let expectation = self.expectation(withDescription: "Testing Valid imageView extension")

        let imageView = UIImageView()
        imageView.setImageWithURL(url: URL(string: imageURL)!, completion: {
            (imageInstance, _) in
            if (imageView.image != nil) {
                expectation.fulfill()
            }
        })

        waitForExpectations(withTimeout: timeout) {
            error in
            if (error != nil) {
                XCTFail("Expectation failed")
            }
        }
    }

    func test_whenDataIsEmpty_thenImageWithCachedDataReturnsNilWithoutCrashing() {
        let emptyData = Data()
        XCTAssertNil(UIImage.image(withCachedData: emptyData))
    }
}
