//
//  Copyright © 2020 Schnaub. All rights reserved.
//

@testable import MapleBacon
import XCTest

final class CacheTests: XCTestCase {

  private static let cacheName = "CacheTests"

  private let cache = Cache<Data>(name: CacheTests.cacheName)

  override func tearDown() {
    cache.clear(.all)

    super.tearDown()
  }

  func testStorage() {
    let expectation = self.expectation(description: #function)

    let data = dummyData()

    cache.store(value: data, forKey: #function) { error in
      XCTAssertNil(error)
      expectation.fulfill()
    }

    waitForExpectations(timeout: 5, handler: nil)
  }

  func testRetrieval() {
    let expectation = self.expectation(description: #function)

    let data = dummyData()

    cache.store(value: data, forKey: #function) { _ in
      self.cache.value(forKey: #function) { result in
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

  func testClearAll() {
    let expectation = self.expectation(description: #function)

    let data = dummyData()

    cache.store(value: data, forKey: #function) { _ in
      self.cache.clear(.all)

      self.cache.value(forKey: #function) { result in
        switch result {
        case .success:
          XCTFail()
        case .failure(let error):
          XCTAssertNotNil(error)
        }
        expectation.fulfill()
      }
    }

    waitForExpectations(timeout: 5, handler: nil)
  }

  func testClearMemory() {
    let expectation = self.expectation(description: #function)

    let data = dummyData()

    cache.store(value: data, forKey: #function) { _ in
      self.cache.clear(.memory)

      self.cache.value(forKey: #function) { result in
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

}
