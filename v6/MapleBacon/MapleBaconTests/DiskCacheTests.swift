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

  private func dummyData() -> Data {
    let string = #function + #file
    return Data(string.utf8)
  }

}
