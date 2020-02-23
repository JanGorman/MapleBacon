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

  func testReadWrite() {
    let expectation = self.expectation(description: #function)
    let cache = DiskCache(name: Self.cacheName)
    let key = "test"
    let data = dummyData()

    cache.insert(data, forKey: key) { _ in
      cache.value(forKey: key) { result in
        switch result {
        case .success(let cacheData):
          XCTAssertNotNil(cacheData)
          XCTAssertEqual(cacheData, data)
        case .failure:
          XCTFail()
        }
        expectation.fulfill()
      }
    }

    waitForExpectations(timeout: 5, handler: nil)
  }

  func testReadInvalid() {
    let expectation = self.expectation(description: #function)
    let cache = DiskCache(name: Self.cacheName)

    cache.value(forKey: "test") { result in
      switch result {
      case .success:
        XCTFail()
      case .failure(let error):
        XCTAssertNotNil(error)
      }
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
    cache.maxCacheAgeSeconds = 0.seconds

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

}
