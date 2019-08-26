//
//  Copyright © 2019 Jan Gorman. All rights reserved.
//

import XCTest
import Nimble
@testable import MapleBacon

class MemoryCacheTests: XCTestCase {

  func testItStoresUniqueValues() {
    let cache = MemoryCache<String, String>(name: "")

    cache["foo"] = "bar"
    cache["baz"] = "bat"

    expect(cache["foo"]) == "bar"
    expect(cache["baz"]) == "bat"
  }

}
