//
//  Copyright © 2017 Jan Gorman. All rights reserved.
//

import XCTest
import UIKit
import Nimble
import MapleBacon
#if canImport(Combine)
import Combine
#endif

final class MapleBaconCacheTests: XCTestCase {
  
  private let helper = TestHelper()

  @available(iOS 13.0, *)
  private lazy var subscriptions: Set<AnyCancellable> = []

  override func tearDown() {
    super.tearDown()
    if #available(iOS 13.0, *) {
      subscriptions.removeAll()
    }
  }
  
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

#if canImport(Combine)

@available(iOS 13.0, *)
extension MapleBaconCacheTests {

  func testItStoresImagesInMemoryPublisher() {
    let cache = MapleBaconCache(name: "mock", backingStore: MockStore())
    let imageData = helper.imageData
    let key = "http://\(#function)"

    waitUntil(timeout: 5) { done in
      cache.storeAndPublish(data: imageData, forKey: key)
        .sink { _ in
          cache.retrieveImage(forKey: key)
            .sink { image, type in
              expect(image).toNot(beNil())
              expect(type) == .memory
              done()
          }
          .store(in: &self.subscriptions)
        }
        .store(in: &self.subscriptions)
    }
  }

  func testItStoresDataInMemoryPublisher() {
    let cache = MapleBaconCache(name: "mock", backingStore: MockStore())
    let imageData = helper.imageData
    let key = "http://\(#function)"

    waitUntil(timeout: 5) { done in
      cache.storeAndPublish(data: imageData, forKey: key)
        .sink { _ in
          cache.retrieveData(forKey: key)
            .sink { data, type in
              expect(data).toNot(beNil())
              expect(type) == .memory
              done()
          }
          .store(in: &self.subscriptions)
        }
        .store(in: &self.subscriptions)
    }
  }

  func testUnknownCacheKeyReturnsNoImagePublisher() {
    let cache = MapleBaconCache(name: "mock", backingStore: MockStore())
    let imageData = helper.imageData

    waitUntil(timeout: 5) { done in
      cache.store(data: imageData, forKey: "key1") {
        cache.retrieveImage(forKey: "key2")
          .sink { image, type in
            expect(image).to(beNil())
            expect(type == .none) == true
            done()
          }
          .store(in: &self.subscriptions)
      }
    }
  }

}

#endif
