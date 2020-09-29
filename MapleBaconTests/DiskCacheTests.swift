//
//  Copyright © 2020 Schnaub. All rights reserved.
//

@testable import MapleBacon
import XCTest

final class DiskCacheTests: XCTestCase {

  private let cache = DiskCache(name: "DiskCacheTests")

  override func tearDownWithError() throws {
    cache.clear()
  }

  func testWrite() {
    let expectation = self.expectation(description: #function)

    cache.insert(dummyData(), forKey: "test") { error in
      XCTAssertNil(error)
      expectation.fulfill()
    }

    waitForExpectations(timeout: 5, handler: nil)
  }

  func testReadWrite() {
    let expectation = self.expectation(description: #function)
    let key = "test"
    let data = dummyData()

    cache.insert(data, forKey: key) { _ in
      self.cache.value(forKey: key) { result in
        switch result {
        case .success(let cacheData):
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

    cache.value(forKey: #function) { result in
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

    cache.clear { error in
      XCTAssertNil(error)
      expectation.fulfill()
    }

    waitForExpectations(timeout: 5, handler: nil)
  }

  func testClearExpired() {
    let expectation = self.expectation(description: #function)
    cache.maxCacheAgeSeconds = 0.seconds

    cache.insert(dummyData(), forKey: "test") { _ in
      // Tests that setting maxCacheAgeSeconds does work
      let expired = try! self.cache.expiredFileURLs()
      XCTAssertFalse(expired.isEmpty)

      self.cache.clearExpired { error in
        XCTAssertNil(error)

        // After clearing expired files, there should be no further expired URLs
        let expired = try! self.cache.expiredFileURLs()
        XCTAssertTrue(expired.isEmpty)

        expectation.fulfill()
      }
    }

    waitForExpectations(timeout: 5, handler: nil)
  }

  func testIsCached() {
    let expectation = self.expectation(description: #function)

    cache.insert(dummyData(), forKey: "test") { _ in
      XCTAssertTrue(try! self.cache.isCached(forKey: "test"))
      expectation.fulfill()
    }

    waitForExpectations(timeout: 5, handler: nil)
  }

}
