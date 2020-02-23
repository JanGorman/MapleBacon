//
//  Copyright © 2020 Schnaub. All rights reserved.
//

@testable import MapleBacon
import XCTest

final class DiskCacheTests: XCTestCase {

  private static let cacheName = "DiskCacheTests"

  override class func tearDown() {
    super.tearDown()

    let cache = DiskCache(name: Self.cacheName)
    cache.clear()

    super.tearDown()
  }

  func testWrite() {
    let expectation = self.expectation(description: #function)
    let cache = DiskCache(name: Self.cacheName)

    cache.insert(dummyData(), forKey: "test") { error in
      XCTAssertNil(error)
      expectation.fulfill()
    }

    waitForExpectations(timeout: 5, handler: nil)
  }

  func testClear() {
    let expectation = self.expectation(description: #function)
    let cache = DiskCache(name: Self.cacheName)

    cache.clear { error in
      XCTAssertNil(error)
      expectation.fulfill()
    }

    waitForExpectations(timeout: 5, handler: nil)
  }

  func testClearExpired() {
    let expectation = self.expectation(description: #function)
    var cache = DiskCache(name: Self.cacheName)
    cache.maxCacheAgeSeconds = 0

    cache.insert(dummyData(), forKey: "test") { _ in
      // Tests that setting maxCacheAgeSeconds does work
      let expired = try! cache.expiredFileURLs()
      XCTAssertFalse(expired.isEmpty)

      cache.clearExpired { error in
        XCTAssertNil(error)

        // After clearing expired files, there should be no further expired URLs
        let expired = try! cache.expiredFileURLs()
        XCTAssertTrue(expired.isEmpty)

        expectation.fulfill()
      }
    }

    waitForExpectations(timeout: 5, handler: nil)
  }

  private func dummyData() -> Data {
    let string = #function + #file
    return Data(string.utf8)
  }

}
