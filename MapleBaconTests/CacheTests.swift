//
//  Copyright © 2020 Schnaub. All rights reserved.
//

@testable import MapleBacon
import XCTest

final class CacheTests: XCTestCase {

  private static let cacheName = "CacheTests"

  private let cache = Cache<Data>(name: CacheTests.cacheName)

  func testStorage() {
    let expectation = self.expectation(description: #function)

    let data = dummyData()

    cache.store(value: data, forKey: #function) { error in
      XCTAssertNil(error)
      self.cache.clear(.all) { _ in
        expectation.fulfill()
      }
    }

    waitForExpectations(timeout: 5, handler: nil)
  }

  func testRetrieval() {
    let expectation = self.expectation(description: #function)

    let data = dummyData()

    cache.store(value: data, forKey: #function) { _ in
      self.cache.value(forKey: #function) { result in
        switch result {
        case .success(let cacheResult):
          XCTAssertEqual(cacheResult.value, data)
          XCTAssertEqual(cacheResult.type, .memory)
        case .failure:
          XCTFail()
        }
        self.cache.clear(.all) { _ in
          expectation.fulfill()
        }
      }
    }

    waitForExpectations(timeout: 5, handler: nil)
  }

  func testClearAll() {
    let expectation = self.expectation(description: #function)

    let data = dummyData()

    cache.store(value: data, forKey: "test") { _ in
      self.cache.clear(.all)

      self.cache.value(forKey: "test") { result in
        switch result {
        case .success:
          XCTFail()
        case .failure(let error):
          XCTAssertNotNil(error)
        }
        self.cache.clear(.all) { _ in
          expectation.fulfill()
        }
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
        case .success(let cacheResult):
          XCTAssertEqual(cacheResult.value, data)
          XCTAssertEqual(cacheResult.type, .disk)
        case .failure:
          XCTFail()
        }
        self.cache.clear(.all) { _ in
          expectation.fulfill()
        }
      }
    }

    waitForExpectations(timeout: 5, handler: nil)
  }

  func testMemoryPromotion() {
    let expectation = self.expectation(description: #function)

    let data = dummyData()

    cache.store(value: data, forKey: #function) { _ in
      self.cache.clear(.memory)

      self.cache.value(forKey: #function) { _ in
        self.cache.value(forKey: #function) { result in
          switch result {
          case .success(let cacheResult):
            XCTAssertEqual(cacheResult.value, data)
            // Assert that upon second time access the data has been promoted into memory
            XCTAssertEqual(cacheResult.type, .memory)
          case .failure:
            XCTFail()
          }
        }

        self.cache.clear(.all) { _ in
          expectation.fulfill()
        }
      }
    }

    waitForExpectations(timeout: 5, handler: nil)
  }

  func testIsCached() {
    let expectation = self.expectation(description: #function)

    let data = dummyData()

    cache.store(value: data, forKey: #function) { _ in
      XCTAssertTrue(try! self.cache.isCached(forKey: #function))

      self.cache.clear(.memory) { _ in
        XCTAssertTrue(try! self.cache.isCached(forKey: #function))

        self.cache.clear(.all) { _ in
          expectation.fulfill()
        }
      }
    }

    waitForExpectations(timeout: 5, handler: nil)
  }

}
