//
//  Copyright © 2020 Schnaub. All rights reserved.
//

@testable import MapleBacon
import XCTest

final class MemoryCacheTests: XCTestCase {

  func testStorage() {
    let cache = MemoryCache<String, String>()

    cache["foo"] = "bar"
    cache["baz"] = "bat"

    XCTAssertEqual(cache["foo"], "bar")
    XCTAssertEqual(cache["baz"], "bat")
    XCTAssertNil(cache["nothing"])
  }

  func testRemoval() {
    let cache = MemoryCache<String, String>()

    cache["foo"] = "bar"
    cache["foo"] = nil

    XCTAssertNil(cache["foo"])
  }

  func testNamedCaches() {
    let defaultCache = MemoryCache<String, String>()
    defaultCache["foo"] = "bar"

    let bazCache = MemoryCache<String, String>(name: "baz")
    bazCache["foo"] = "baz"

    XCTAssertNotEqual(defaultCache["foo"], bazCache["foo"])
  }

  func testClear() {
    let cache = MemoryCache<String, String>()
    cache["foo"] = "bar"

    cache.clear()

    XCTAssertNil(cache["foo"])
  }

}
