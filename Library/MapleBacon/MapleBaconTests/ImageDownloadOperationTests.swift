//
//  Copyright (c) 2015 Zalando SE. All rights reserved.
//

import XCTest
import UIKit
import MapleBacon

let imageURL = "http://i5.ztat.net/detail/LM/12/1C/07/ZK/11/LM121C07Z-K11@12.1.jpg"
let redirectURL = "https://graph.facebook.com/953256478/picture?type=large"
let gifURL = "http://media.giphy.com/media/lI6nHr5hWXlu0/giphy.gif"

class ImageDownloadOperationTests: XCTestCase {

    override func setUp() {
        super.setUp()
    }

    override func tearDown() {
        super.tearDown()
    }

    func test_whenDownloadingValidImage_thenTaskFinishesWithImage() {
        let expectation = self.expectation(withDescription: "Testing async ImageDownlader")

        let operation = ImageDownloadOperation(imageURL: URL(string: imageURL)!)
        operation.completionHandler = {
            (imageInstance, error) in
            expectation.fulfill()
            XCTAssertNotNil(imageInstance?.image, "Task finished but image was nil")
            XCTAssertNil(error, "Task with invalid url finished and error wasn't nil")
        }
        operation.start()

        waitForExpectations(withTimeout: timeout) {
            error in
            if nil != error {
                XCTFail("Expectation failed")
            }
        }
    }

    func test_whenSuspendingAndResumingDownload_thenTaskFinishesWithImage() {
        let downloadExpectation = expectation(withDescription: "Testing async ImageDownlader")

        let operation = ImageDownloadOperation(imageURL: URL(string: imageURL)!)
        operation.completionHandler = {
            (imageInstance, error) in
            if nil == error {
                downloadExpectation.fulfill()
                XCTAssertNotNil(imageInstance?.image, "Task finished but image was nil")
                XCTAssertNil(error)
            }
        }
        operation.start()
        operation.cancel()
        operation.start()

        waitForExpectations(withTimeout: timeout) {
            error in
            
            if nil != error {
                XCTFail("Expectation failed")
            }
        }
    }

    func test_whenCancellingDownload_thenTaskFinishesWithCancellationError() {
        let cancelExpectation = expectation(withDescription: "Testing Cancelling ImageDownlader")

        let operation = ImageDownloadOperation(imageURL: URL(string: imageURL)!)
        operation.completionHandler = {
            (imageInstance, error) in
            
            if nil != error {
                cancelExpectation.fulfill()
                XCTAssertNil(imageInstance?.image, "Task finished but image was nil")
                XCTAssertNotNil(error)
                XCTAssert(error?.code == NSURLErrorCancelled, "Error does not have expected error code")
            }
        }

        operation.start()
        operation.cancel()

        waitForExpectations(withTimeout: timeout) {
            error in
            
            if nil != error {
                XCTFail("Expectation failed")
            }
        }
    }

    func test_whenRequestingImageWithRedirectedURL_thenReturnedURLIsNotTheRequestedURL() {
        let redirectedExpectation = expectation(withDescription: "Testing Redirected URL ImageDownlader")

        let operation = ImageDownloadOperation(imageURL: URL(string: redirectURL)!)
        operation.completionHandler = {
            (imageInstance, _) in
            
            if imageInstance != nil {
                
                let imageURL = imageInstance?.url!.absoluteString
                
                if imageURL != redirectURL {
                    redirectedExpectation.fulfill()
                }
            }
        }
        operation.start()

        waitForExpectations(withTimeout: timeout) {
            error in
            if nil != error {
                XCTFail("Expectation failed")
            }
        }
    }

    func test_whenRequestingImageWithGifURL_thenReturnedImageHasManyFrames() {
        let gifExpectation = expectation(withDescription: "Testing Gif URL ImageDownlader")

        let operation = ImageDownloadOperation(imageURL: URL(string: gifURL)!)
        operation.completionHandler = {
            (imageInstance, _) in
            if nil != imageInstance {
                let image = imageInstance?.image
                gifExpectation.fulfill()
                XCTAssert(image?.images?.count > 0, "Requesting GIF image but image doesn't have multiple images")
            }
        }
        operation.start()

        waitForExpectations(withTimeout: timeout) {
            error in
            if nil != error {
                XCTFail("Expectation failed")
            }
        }
    }

}
