//
//  Copyright © 2017 Jan Gorman. All rights reserved.
//

import XCTest
import UIKit
@testable import MapleBacon

class CacheTests: XCTestCase {
  
  func testItStoresImageInMemory() {
    let expectation = self.expectation(description: "Retrieve image from cache")
    let cache = Cache.default
    let image = testImage()
    let key = #function
    
    cache.store(image, forKey: key) {
      cache.retrieveImage(forKey: key) { image, _ in
        XCTAssertNotNil(image)
        expectation.fulfill()
      }
    }
    
    wait(for: [expectation], timeout: 1)
  }
  
  func testUnknownCacheKeyReturnsNoImage() {
    let expectation = self.expectation(description: "Retrieve no image from cache")
    let cache = Cache.default
    let image = testImage()
    
    cache.store(image, forKey: "key1") {
      cache.retrieveImage(forKey: "key2") { image, type in
        XCTAssertNil(image)
        XCTAssertEqual(type, .none)
        expectation.fulfill()
      }
    }
    
    wait(for: [expectation], timeout: 1)
  }
  
  func testItStoresImagesToDisk() {
    let expectation = self.expectation(description: "Retrieve image from cache")
    let cache = Cache.default
    let image = testImage()
    let key = "test"
    
    cache.store(image, forKey: key) {
      cache.clearMemory()
      cache.retrieveImage(forKey: key) { image, type in
        XCTAssertNotNil(image)
        XCTAssertEqual(type, .disk)
        expectation.fulfill()
      }
    }
    
    wait(for: [expectation], timeout: 1)
  }
  
  private func testImage() -> UIImage {
    return UIImage(named: "MapleBacon", in: Bundle(for: CacheTests.self), compatibleWith: nil)!
  }
  
}
