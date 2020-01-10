//
//  Copyright © 2019 Jan Gorman. All rights reserved.
//

import XCTest
@testable import MapleBacon

class DiskCacheTests: XCTestCase {

  private let helper = TestHelper()

  func testItReturnsExpiredFileUrlsForDeletion() {
    let cache = DiskCache(name: "name", backingStore: MockStore())
    cache.maxCacheAgeSeconds = 0
    let imageData = helper.imageData
    let key = #function

    let expectation = self.expectation(description: #function)

    cache.insert(imageData, forKey: key) {
      let urls = cache.expiredFileUrls()
      XCTAssertFalse(urls.isEmpty)
      expectation.fulfill()
    }

    waitForExpectations(timeout: 5, handler: nil)
  }

  func testItCleansExpiredFiles() {
    let cache = DiskCache(name: "name", backingStore: MockStore())
    cache.maxCacheAgeSeconds = 0
    let imageData = helper.imageData
    let key = #function

    let expectation = self.expectation(description: #function)

    cache.insert(imageData, forKey: key) {
      cache.cleanDisk {
        let urls = cache.expiredFileUrls()
        XCTAssertTrue(urls.isEmpty)
        expectation.fulfill()
      }
    }

    waitForExpectations(timeout: 5, handler: nil)
  }

}
