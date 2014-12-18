//
//  Copyright (c) 2014 Zalando SE. All rights reserved.
//

import XCTest
import UIKit
import MapleBacon

let imageURL = "http://i5.ztat.net/detail/LM/12/1C/07/ZK/11/LM121C07Z-K11@12.1.jpg"
let redirectURL = "https://graph.facebook.com/953256478/picture?type=large"
let gifURL = "http://media.giphy.com/media/lI6nHr5hWXlu0/giphy.gif"

class ImageDownloaderTests: XCTestCase {

    var downloader: ImageDownloader!

    override func setUp() {
        super.setUp()
        downloader = ImageDownloader()
    }

    override func tearDown() {
        super.tearDown()
    }

    func test_whenDownloadingValidImage_thenTaskFinishesWithImage() {
        let expectation = expectationWithDescription("Testing async ImageDownlader")

        downloader.downloadImageAtURL(imageURL, completion: {
            (imageInstance: ImageInstance?, error: NSError?) -> Void in
            expectation.fulfill()
            XCTAssertNotNil(imageInstance?.image, "Task finished but image was nil")
            XCTAssertNil(error, "Task with invalid url finished and error wasn't nil")
        })

        waitForExpectationsWithTimeout(timeout, handler: {
            (error: NSError!) -> Void in
            if (error != nil) {
                XCTFail("Expectation failed")
            }
        })
    }

    func test_whenDownloadingInvalidImage_thenTaskFinishesWithError() {
        let expectation = expectationWithDescription("Testing async ImageDownlader")

        downloader.downloadImageAtURL("asd", completion: {
            (imageInstance: ImageInstance?, error: NSError?) -> Void in
            expectation.fulfill()
            XCTAssertNil(imageInstance?.image, "Task finished and image wasn't nil")
            XCTAssertNotNil(error, "Task with invalid url finished and error was nil")
        })

        waitForExpectationsWithTimeout(timeout, handler: {
            (error: NSError!) -> Void in
            if (error != nil) {
                XCTFail("Expectation failed")
            }
        })
    }

    func test_whenDownloadingNilURL_thenTaskFinishesWithError() {
        let expectation = expectationWithDescription("Testing async ImageDownlader")

        downloader.downloadImageAtURL(nil, completion: {
            (imageInstance: ImageInstance?, error: NSError?) -> Void in
            expectation.fulfill()
            XCTAssertNil(imageInstance?.image, "Task finished and image wasn't nil")
            XCTAssertNotNil(error != nil, "Task with invalid url finished and error was nil")
        })

        waitForExpectationsWithTimeout(timeout, handler: {
            (error: NSError!) -> Void in
            if (error != nil) {
                XCTFail("Expectation failed")
            }
        })
    }

    func test_whenSuspendingAndResumingDownload_thenTaskFinishesWithImage() {
        let downloadExpectation = expectationWithDescription("Testing async ImageDownlader")

        downloader.downloadImageAtURL(imageURL, completion: {
            (imageInstance: ImageInstance?, error: NSError?) -> Void in
            if (error == nil) {
                downloadExpectation.fulfill()
                XCTAssertNotNil(imageInstance?.image, "Task finished but image was nil")
                XCTAssertNil(error, "Task with invalid url finished and error wasn't nil")
            }
        })

        downloader.suspendDownload()
        downloader.resumeDownload()

        waitForExpectationsWithTimeout(timeout, handler: {
            (error: NSError!) -> Void in
            if (error != nil) {
                XCTFail("Expectation failed")
            }
        })
    }

    func test_whenCancellingDownload_thenTaskFinishesWithCancellationError() {
        let cancelExpectation = expectationWithDescription("Testing Cancelling ImageDownlader")

        downloader.downloadImageAtURL(imageURL, completion: {
            (imageInstance: ImageInstance?, error: NSError?) -> Void in
            if (error != nil) {
                cancelExpectation.fulfill()
                XCTAssertNil(imageInstance?.image, "Task finished but image was nil")
                XCTAssertNotNil(error)
                XCTAssert(error?.code == NSURLErrorCancelled, "Task with invalid url finished and error wasn't cancel")
            }
        })

        downloader.cancelDownload()

        waitForExpectationsWithTimeout(timeout, handler: {
            (error: NSError!) -> Void in
            if (error != nil) {
                XCTFail("Expectation failed")
            }
        })
    }

    func test_whenRequestingImageWithRedirectedURL_thenReturnedURLIsNotTheRequestedURL() {
        let redirectedExpectation = expectationWithDescription("Testing Redirected URL ImageDownlader")

        downloader.downloadImageAtURL(redirectURL, completion: {
            (imageInstance: ImageInstance?, error: NSError?) -> Void in
            if (imageInstance != nil) {
                let imageURL = imageInstance?.url!.absoluteString
                if (imageURL != redirectURL) {
                    redirectedExpectation.fulfill()
                }
            }
        })

        waitForExpectationsWithTimeout(timeout, handler: {
            (error: NSError!) -> Void in
            if (error != nil) {
                XCTFail("Expectation failed")
            }
        })
    }

    func test_whenRequestingImageWithGifURL_thenReturnedImageHasManyFrames() {
        let gifExpectation = expectationWithDescription("Testing Gif URL ImageDownlader")

        downloader.downloadImageAtURL(gifURL, completion: {
            (imageInstance: ImageInstance?, error: NSError?) -> Void in
            if (imageInstance != nil) {
                let image = imageInstance?.image
                gifExpectation.fulfill()
                XCTAssert(image?.images?.count > 0, "Requesting GIF image but image returned doesn't have multiple images")
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
