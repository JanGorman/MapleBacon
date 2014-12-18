//
//  Copyright (c) 2014 Zalando SE. All rights reserved.
//

import XCTest
import Foundation
import UIKit
import MapleBacon

class ImageExtensionTests: XCTestCase {

    func test_whenImageViewRequestImageWithValidURL_thenImageViewHasImage() {
        let expectation = expectationWithDescription("Testing Valid imageView extension")

        let imageView = UIImageView()
        imageView.setImageWithURL(NSURL(string: imageURL)!, completion: {
            (imageInstance: ImageInstance?, error: NSError?) -> Void in
            if (imageView.image != nil) {
                expectation.fulfill()
            }
        })

        waitForExpectationsWithTimeout(timeout, handler: {
            (error: NSError!) -> Void in
            if (error != nil) {
                XCTFail("Expectation failed")
            }
        })
    }

}
