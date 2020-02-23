//
//  Copyright © 2020 Schnaub. All rights reserved.
//

@testable import MapleBacon
import XCTest

final class CacheTests: XCTestCase {

  private static let cacheName = "CacheTests"

  func testStorage() throws {
    let expectation = self.expectation(description: #function)

    let cache = Cache<Data>(name: Self.cacheName)
    let data = dummyData()

    cache.store(value: data, forKey: #function) { error in
      XCTAssertNil(error)
      expectation.fulfill()
    }

    waitForExpectations(timeout: 5, handler: nil)
  }

  func testRetrieval() throws {
    let expectation = self.expectation(description: #function)

    let cache = Cache<Data>(name: Self.cacheName)
    let data = dummyData()

    cache.store(value: data, forKey: #function) { _ in
      cache.value(forKey: #function) { result in
        switch result {
        case .success(let cacheData):
          XCTAssertNotNil(cacheData)
          XCTAssertEqual(data, cacheData)
        case .failure(_):
          XCTFail()
        }
        expectation.fulfill()
      }
    }

    waitForExpectations(timeout: 5, handler: nil)
  }

}
