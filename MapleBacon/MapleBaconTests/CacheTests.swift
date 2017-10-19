//
//  Copyright © 2017 Jan Gorman. All rights reserved.
//

import XCTest
import UIKit
@testable import MapleBacon

class CacheTests: XCTestCase {
  
  private let helper = TestHelper()

  override func tearDown() {
    super.tearDown()

    Cache.default.clearMemory()
    Cache.default.clearDisk()
  }
  
  func testItStoresImageInMemory() {
    let expectation = self.expectation(description: "Retrieve image from cache")
    let cache = Cache.default
    let image = helper.testImage()
    let key = #function
    
    cache.store(image, forKey: key) {
      cache.retrieveImage(forKey: key) { image, _ in
        XCTAssertNotNil(image)
        expectation.fulfill()
      }
    }
    
    wait(for: [expectation], timeout: 10)
  }

  func testNamedCachesAreDistinct() {
    let expectation = self.expectation(description: "Retrieve image from cache")
    let defaultCache = Cache.default
    let namedCache = Cache(name: "named")
    let image = helper.testImage()
    let key = #function

    defaultCache.store(image, forKey: key) {
      namedCache.retrieveImage(forKey: key, completion: { image, _ in
        XCTAssertNil(image)
        expectation.fulfill()
      })
    }

    wait(for: [expectation], timeout: 10)
  }
  
  func testUnknownCacheKeyReturnsNoImage() {
    let expectation = self.expectation(description: "Retrieve no image from cache")
    let cache = Cache.default
    let image = helper.testImage()
    
    cache.store(image, forKey: "key1") {
      cache.retrieveImage(forKey: "key2") { image, type in
        XCTAssertNil(image)
        XCTAssertEqual(type, .none)
        expectation.fulfill()
      }
    }
    
    wait(for: [expectation], timeout: 10)
  }
  
  func testItStoresImagesToDisk() {
    let expectation = self.expectation(description: "Retrieve image from cache")
    let cache = Cache.default
    let image = helper.testImage()
    let key = #function
    
    cache.store(image, forKey: key) {
      cache.clearMemory()
      cache.retrieveImage(forKey: key) { image, type in
        XCTAssertNotNil(image)
        XCTAssertEqual(type, .disk)
        expectation.fulfill()
      }
    }
    
    wait(for: [expectation], timeout: 10)
  }

  func testItClearsDiskCache() {
    let expectation = self.expectation(description: "Clear disk cache")
    let cache = Cache.default
    let image = helper.testImage()
    let key = #function

    cache.store(image, forKey: key) {
      cache.clearMemory()
      cache.clearDisk {
        cache.retrieveImage(forKey: key) { image, _ in
          XCTAssertNil(image)
          expectation.fulfill()
        }
      }
    }

    wait(for: [expectation], timeout: 10)
  }

}
