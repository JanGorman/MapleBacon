//
//  Copyright © 2017 Jan Gorman. All rights reserved.
//

import XCTest
import UIKit
import Nimble
import MapleBacon

final class MapleBaconCacheTests: XCTestCase {
  
  private let helper = TestHelper()
  
  class MockStore: BackingStore {
    
    private var backingStore: [String: Data] = [:]
    
    func fileContents(at url: URL) throws -> Data {
      let path = url.absoluteString.deletingPrefix("file://")
      guard let data = backingStore[path] else {
        return Data()
      }
      return data
    }

    func fileExists(atPath path: String) -> Bool {
      return false
    }
    
    func createFile(atPath path: String, contents data: Data?, attributes attr: [FileAttributeKey : Any]?) -> Bool {
      guard let data = data else {
        return false
      }
      backingStore[path] = data
      return true
    }
    
    func createDirectory(atPath path: String, withIntermediateDirectories createIntermediates: Bool,
                         attributes: [FileAttributeKey : Any]?) throws {
    }
    
    func removeItem(atPath path: String) throws {
      backingStore.removeAll()
    }
    
    func removeItem(at URL: URL) throws {
    }

    func contentsOfDirectory(at url: URL, includingPropertiesForKeys keys: [URLResourceKey]?,
                             options mask: FileManager.DirectoryEnumerationOptions) throws -> [URL] {
      let urls = backingStore.keys.map { URL(fileURLWithPath: $0) }
      return urls
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

  func testItReturnsExpiredFileUrlsForDeletion() {
    let cache = MapleBaconCache(name: "mock", backingStore: MockStore())
    cache.maxCacheAgeSeconds = 0
    let imageData = helper.imageData
    let key = #function

    waitUntil(timeout: 5) { done in
      cache.store(data: imageData, forKey: key) {
        let urls = cache.expiredFileUrls()
        expect(urls).toNot(beEmpty())
        done()
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
