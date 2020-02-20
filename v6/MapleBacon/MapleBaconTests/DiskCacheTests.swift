//
//  Copyright © 2020 Schnaub. All rights reserved.
//

@testable import MapleBacon
import XCTest

final class DiskCacheTests: XCTestCase {

  func testFoo() {
    let expectation = self.expectation(description: #function)
    let cache = DiskCache(name: #function.replacingOccurrences(of: "()", with: ""))

    cache.insert(dummyData(), forKey: "test") { error in
      XCTAssertNil(error)
      expectation.fulfill()
    }

    waitForExpectations(timeout: 5, handler: nil)
  }

  private func dummyData() -> Data {
    let string = #function + #file
    return Data(string.utf8)
  }

}
