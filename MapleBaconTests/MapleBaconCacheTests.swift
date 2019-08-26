//
//  Copyright © 2017 Jan Gorman. All rights reserved.
//

import XCTest
import UIKit
import Nimble
import MapleBacon

final class MapleBaconCacheTests: XCTestCase {
  
  private let helper = TestHelper()
  
  func testItStoresImageInMemory() {
    let cache = MapleBaconCache(name: "mock", backingStore: MockStore())
    let imageData = helper.imageData
    let key = "http://\(#function)"
    
    waitUntil(timeout: 5) { done in
      cache.store(data: imageData, forKey: key) {
        cache.retrieveImage(forKey: key) { image, type in
          expect(image).toNot(beNil())
          expect(type) == .memory
          done()
        }
      }
    }
  }

  func testNamedCachesAreDistinct() {
    let mockCache = MapleBaconCache(name: "mock", backingStore: MockStore())
    let namedCache = MapleBaconCache(name: "named")
    let imageData = helper.imageData
    let key = #function

    waitUntil(timeout: 5) { done in
      mockCache.store(data: imageData, forKey: key) {
        namedCache.retrieveImage(forKey: key, completion: { image, _ in
          expect(image).to(beNil())
          done()
        })
      }
    }
  }

  func testUnknownCacheKeyReturnsNoImage() {
    let cache = MapleBaconCache(name: "mock", backingStore: MockStore())
    let imageData = helper.imageData

    waitUntil(timeout: 5) { done in
      cache.store(data: imageData, forKey: "key1") {
        cache.retrieveImage(forKey: "key2") { image, type in
          expect(image).to(beNil())
          expect(type == .none) == true
          done()
        }
      }
    }
  }
  
  func testItStoresImagesToDisk() {
    let cache = MapleBaconCache(name: "mock", backingStore: MockStore())
    let imageData = helper.imageData
    let key = #function

    waitUntil(timeout: 5) { done in
      cache.store(data: imageData, forKey: key) {
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
    let cache = MapleBaconCache(name: "mock", backingStore: MockStore())
    let imageData = helper.imageData
    let key = #function

    waitUntil(timeout: 5) { done in
      cache.store(data: imageData, forKey: key) {
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
    let cache = MapleBaconCache(name: "mock", backingStore: MockStore())
    let imageData = helper.imageData
    let key = #function

    waitUntil(timeout: 5) { done in
      cache.store(data: imageData, forKey: key) {
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

  func testCacheWithIdentifierIsCachedAsSeparateImage() {
    let cache = MapleBaconCache(name: "mock", backingStore: MockStore())
    let imageData = helper.imageData
    let alternateImageData = helper.image.jpegData(compressionQuality: 0.2)!
    let key = #function
    let transformerId = "transformer"

    waitUntil(timeout: 5) { done in
      cache.store(data: imageData, forKey: key) {
        cache.store(data: alternateImageData, forKey: key, transformerId: transformerId) {
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
