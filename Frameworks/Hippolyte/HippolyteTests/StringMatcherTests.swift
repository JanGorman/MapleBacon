//
//  Copyright © 2017 Jan Gorman. All rights reserved.
//

import XCTest
import Hippolyte

class StringMatcherTests: XCTestCase {
  
  func testMatchingStringsMatch() {
    let matcher = StringMatcher(string: "string")

    XCTAssertTrue(matcher.matches(string: "string"))
  }

  func testMisMatchingStringsDoNotMatch() {
    let matcher = StringMatcher(string: "string")

    XCTAssertFalse(matcher.matches(string: "other"))
  }

  func testInstancesWithSameStringMatch() {
    let string = "string"
    let matcher1 = StringMatcher(string: string)
    let matcher2 = StringMatcher(string: string)

    XCTAssertEqual(matcher1, matcher2)
  }

  func testInstancesWithDifferentStringsDoNotMatch() {
    let matcher1 = StringMatcher(string: "string")
    let matcher2 = StringMatcher(string: "other")

    XCTAssertNotEqual(matcher1, matcher2)
  }

}
