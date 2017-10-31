//
//  Copyright © 2017 Jan Gorman. All rights reserved.
//

import XCTest
import Hippolyte

class DataMatcherTests: XCTestCase {

  func testMatchingDataMatches() {
    let data = "data".data(using: .utf8)!
    let matcher = DataMatcher(data: data)

    XCTAssertTrue(matcher.matches(data: data))
  }

  func testMismatchingDataDoesNotMatch() {
    let data = "data".data(using: .utf8)!
    let matcher = DataMatcher(data: data)

    XCTAssertFalse(matcher.matches(data: "other".data(using: .utf8)!))
  }

  func testInstancesWithSameDataMatch() {
    let data = "data".data(using: .utf8)!
    let matcher1 = DataMatcher(data: data)
    let matcher2 = DataMatcher(data: data)

    XCTAssertEqual(matcher1, matcher2)
  }

  func testInstancesWithDifferentDataDoNotMatch() {
    let matcher1 = DataMatcher(data: "data".data(using: .utf8)!)
    let matcher2 = DataMatcher(data: "other".data(using: .utf8)!)

    XCTAssertNotEqual(matcher1, matcher2)
  }

}
