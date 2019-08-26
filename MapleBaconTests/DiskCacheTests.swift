//
//  Copyright © 2019 Jan Gorman. All rights reserved.
//

import XCTest
import Nimble
@testable import MapleBacon

class DiskCacheTests: XCTestCase {

  private let helper = TestHelper()

  func testItReturnsExpiredFileUrlsForDeletion() {
    let cache = DiskCache(name: "name", backingStore: MockStore())
    cache.maxCacheAgeSeconds = 0
    let imageData = helper.imageData
    let key = #function

    waitUntil(timeout: 5) { done in
      cache.insert(imageData, forKey: key) {
        let urls = cache.expiredFileUrls()
        expect(urls).toNot(beEmpty())
        done()
      }
    }
  }

  func testItCleansExpiredFiles() {
    let cache = DiskCache(name: "name", backingStore: MockStore())
    cache.maxCacheAgeSeconds = 0
    let imageData = helper.imageData
    let key = #function

    waitUntil(timeout: 5) { done in
      cache.insert(imageData, forKey: key) {
        cache.cleanDisk() {
          let urls = cache.expiredFileUrls()
          expect(urls).to(beEmpty())
          done()
        }
      }
    }
  }

}
