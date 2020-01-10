//
//  Copyright © 2019 Jan Gorman. All rights reserved.
//

import XCTest
@testable import MapleBacon

class MemoryCacheTests: XCTestCase {

  func testItStoresUniqueValues() {
    let cache = MemoryCache<String, String>(name: "")

    cache["foo"] = "bar"
    cache["baz"] = "bat"

    XCTAssertEqual(cache["foo"], "bar")
    XCTAssertEqual(cache["baz"], "bat")
    XCTAssertNil(cache["nothing"])
  }

  func testRemoveValues() {
    let cache = MemoryCache<String, String>(name: "")

    cache["foo"] = "bar"
    cache.removeValue(forKey: "foo")

    XCTAssertNil(cache["foo"])

    cache["foo"] = "bar"
    cache["foo"] = nil

    XCTAssertNil(cache["foo"])
  }

  func testNamespace() {
    let cache0 = MemoryCache<String, String>(name: "cache0")
    cache0["foo"] = "bar"

    let cache1 = MemoryCache<String, String>(name: "cache1")
    cache1["foo"] = "baz"

    XCTAssertEqual(cache0["foo"], "bar")
    XCTAssertEqual(cache1["foo"], "baz")
  }

}
