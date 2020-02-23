//
//  Copyright © 2020 Schnaub. All rights reserved.
//

@testable import MapleBacon
import XCTest

final class CacheTests: XCTestCase {

  private static let cacheName = "CacheTests"

  func testExample() throws {
    let cache = Cache(name: Self.cacheName)
    let data = dummyData()

    cache.store(value: data, forKey: #function)
  }

}
