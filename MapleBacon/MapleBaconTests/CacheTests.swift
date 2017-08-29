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
    let key = "test"
    
    cache.store(image, forKey: key) {
      cache.retrieveImage(forKey: key) { image in
        XCTAssertNotNil(image)
        expectation.fulfill()
      }
    }
    
    wait(for: [expectation], timeout: 1)
  }
  
  private func testImage() -> UIImage {
    return UIImage(named: "MapleBacon", in: Bundle(for: CacheTests.self), compatibleWith: nil)!
  }
  
}
