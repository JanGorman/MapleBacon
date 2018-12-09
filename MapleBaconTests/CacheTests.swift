//
//  Copyright © 2017 Jan Gorman. All rights reserved.
//

import XCTest
import UIKit
import Nimble
import MapleBacon

class CacheTests: XCTestCase {
  
  private let helper = TestHelper()

  override func tearDown() {
    super.tearDown()

    Cache.default.clearMemory()
    Cache.default.clearDisk()
  }
  
  func testItStoresImageInMemory() {
    let cache = Cache.default
    let image = helper.image
    let key = "http://\(#function)"
    
    waitUntil { done in
      cache.store(image, forKey: key) {
        cache.retrieveImage(forKey: key) { image, _ in
          expect(image).toNot(beNil())
          done()
        }
      }
    }
  }

  func testNamedCachesAreDistinct() {
    let defaultCache = Cache.default
    let namedCache = Cache(name: "named")
    let image = helper.image
    let key = #function

    waitUntil { done in
      defaultCache.store(image, forKey: key) {
        namedCache.retrieveImage(forKey: key, completion: { image, _ in
          expect(image).to(beNil())
          done()
        })
      }
    }
  }
  
  func testUnknownCacheKeyReturnsNoImage() {
    let cache = Cache.default
    let image = helper.image

    waitUntil { done in
      cache.store(image, forKey: "key1") {
        cache.retrieveImage(forKey: "key2") { image, type in
          expect(image).to(beNil())
          expect(type == .none) == true
          done()
        }
      }
    }
  }
  
  func testItStoresImagesToDisk() {
    let cache = Cache.default
    let image = helper.image
    let key = #function

    waitUntil { done in
      cache.store(image, forKey: key) {
        cache.clearMemory()
        cache.retrieveImage(forKey: key) { image, type in
          expect(image).toNot(beNil())
          expect(type) == .disk
          done()
        }
      }
    }
  }

  func testImagesOnDiskAreMovedToMemory() {
    let cache = Cache.default
    let image = helper.image
    let key = #function

    waitUntil { done in
      cache.store(image, forKey: key) {
        cache.clearMemory()
        cache.retrieveImage(forKey: key) { _, _ in
          cache.retrieveImage(forKey: key) { image, type in
            expect(image).toNot(beNil())
            expect(type) == .memory
            done()
          }
        }
      }
    }
  }

  func testItClearsDiskCache() {
    let cache = Cache.default
    let image = helper.image
    let key = #function

    waitUntil { done in
      cache.store(image, forKey: key) {
        cache.clearMemory()
        cache.clearDisk {
          cache.retrieveImage(forKey: key) { image, _ in
            expect(image).to(beNil())
            done()
          }
        }
      }
    }
  }

  func testItReturnsExpiredFileUrlsForDeletion() {
    let cache = Cache(name: #function)
    cache.maxCacheAgeSeconds = 0
    let image = helper.image
    let key = #function

    waitUntil { done in
      cache.store(image, forKey: key) {
        let urls = cache.expiredFileUrls()
        expect(urls).toNot(beEmpty())
        done()
      }
    }
  }

  func testCacheWithIdentifierIsCachedAsSeparateImage() {
    let cache = Cache.default
    let image = helper.image
    let alternateImage = UIImage(data: image.jpegData(compressionQuality: 0.2)!)!
    let key = #function
    let transformerId = "transformer"

    waitUntil { done in
      cache.store(image, forKey: key) {
        cache.store(alternateImage, forKey: key, transformerId: transformerId) {
          cache.retrieveImage(forKey: key) { image, _ in
            expect(image).toNot(beNil())
            
            cache.retrieveImage(forKey: key, transformerId: transformerId) { transformerImage, _ in
              expect(transformerImage).toNot(beNil())
              expect(image) != transformerImage
              done()
            }
          }
        }
      }
    }
  }

}
