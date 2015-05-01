//
//  Copyright (c) 2015 Zalando SE. All rights reserved.
//

import XCTest
import UIKit
import MapleBacon

class ImageExtensionTests: XCTestCase {

    func test_whenImageViewRequestImageWithValidURL_thenImageViewHasImage() {
        let expectation = expectationWithDescription("Testing Valid imageView extension")

        let imageView = UIImageView()
        imageView.setImageWithURL(NSURL(string: imageURL)!, completion: {
            (imageInstance, _) in
            if (imageView.image != nil) {
                expectation.fulfill()
            }
        })

        waitForExpectationsWithTimeout(timeout) {
            error in
            if (error != nil) {
                XCTFail("Expectation failed")
            }
        }
    }

}
