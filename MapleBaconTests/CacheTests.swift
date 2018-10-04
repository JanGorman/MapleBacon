//
//  Copyright © 2017 Jan Gorman. All rights reserved.
//

import XCTest
import UIKit
import MapleBacon

class CacheTests: XCTestCase {
  
  private let helper = TestHelper()
  
  private var cache: Cache!
  private var namedCache: Cache?

  override func tearDown() {
    super.tearDown()

    Cache.default.clearMemory()
    Cache.default.clearDisk()
  }
  
  func testItStoresImageInMemory() {
    let expectation = self.expectation(description: "Retrieve image from cache")
    cache = Cache.default
    let image = helper.image
    let key = "http://\(#function)"
    
    cache.store(image, forKey: key) { [cache] in
      cache!.retrieveImage(forKey: key) { image, _ in
        XCTAssertNotNil(image)
        expectation.fulfill()
      }
    }
    
    wait(for: [expectation], timeout: 10)
  }

  func testNamedCachesAreDistinct() {
    let expectation = self.expectation(description: "Retrieve image from cache")
    cache = Cache.default
    namedCache = Cache(name: "named")
    let image = helper.image
    let key = #function

    cache.store(image, forKey: key) { [namedCache] in
      namedCache?.retrieveImage(forKey: key, completion: { image, _ in
        XCTAssertNil(image)
        expectation.fulfill()
      })
    }

    wait(for: [expectation], timeout: 10)
  }
  
  func testUnknownCacheKeyReturnsNoImage() {
    let expectation = self.expectation(description: "Retrieve no image from cache")
    cache = Cache.default
    let image = helper.image
    
    cache.store(image, forKey: "key1") { [cache] in
      cache!.retrieveImage(forKey: "key2") { image, type in
        XCTAssertNil(image)
        XCTAssertEqual(type, .none)
        expectation.fulfill()
      }
    }
    
    wait(for: [expectation], timeout: 10)
  }
  
  func testItStoresImagesToDisk() {
    let expectation = self.expectation(description: "Retrieve image from cache")
    cache = Cache.default
    let image = helper.image
    let key = #function
    
    cache.store(image, forKey: key) { [cache] in
      cache!.clearMemory()
      cache!.retrieveImage(forKey: key) { image, type in
        XCTAssertNotNil(image)
        XCTAssertEqual(type, .disk)
        expectation.fulfill()
      }
    }
    
    wait(for: [expectation], timeout: 10)
  }

  func testImagesOnDiskAreMovedToMemory() {
    let expectation = self.expectation(description: "Retrieve image from cache")
    cache = Cache.default
    let image = helper.image
    let key = #function

    cache.store(image, forKey: key) { [cache] in
      cache!.clearMemory()
      cache!.retrieveImage(forKey: key) { _, _ in
        cache!.retrieveImage(forKey: key) { image, type in
          XCTAssertNotNil(image)
          XCTAssertEqual(type, .memory)
          expectation.fulfill()
        }
      }
    }

    wait(for: [expectation], timeout: 10)
  }

  func testItClearsDiskCache() {
    let expectation = self.expectation(description: "Clear disk cache")
    cache = Cache.default
    let image = helper.image
    let key = #function

    cache.store(image, forKey: key) { [cache] in
      cache!.clearMemory()
      cache!.clearDisk {
        cache!.retrieveImage(forKey: key) { image, _ in
          XCTAssertNil(image)
          expectation.fulfill()
        }
      }
    }

    wait(for: [expectation], timeout: 10)
  }

  func testItReturnsExpiredFileUrlsForDeletion() {
    let expectation = self.expectation(description: "Expired Urls")
    cache = Cache(name: #function)
    cache.maxCacheAgeSeconds = 0
    let image = helper.image
    let key = #function

    cache.store(image, forKey: key) { [cache] in
      let urls = cache!.expiredFileUrls()
      XCTAssertFalse(urls.isEmpty)
      expectation.fulfill()
    }

    wait(for: [expectation], timeout: 10)
  }

  func testCacheWithIdentifierIsCachedAsSeparateImage() {
    let expectation = self.expectation(description: "Retrieve image from cache")
    cache = Cache.default
    let image = helper.image
    let alternateImage = UIImage(data: image.jpegData(compressionQuality: 0.2)!)!
    let key = #function
    let transformerId = "transformer"

    cache.store(image, forKey: key) { [cache] in
      cache!.store(alternateImage, forKey: key, transformerId: transformerId) {
        cache!.retrieveImage(forKey: key) { image, _ in
          cache!.retrieveImage(forKey: key, transformerId: transformerId) { transformerImage, _ in
            XCTAssertNotNil(image)
            XCTAssertNotNil(transformerImage)
            XCTAssertNotEqual(image, transformerImage)
            expectation.fulfill()
          }
        }
      }
    }

    wait(for: [expectation], timeout: 10)
  }

}
