//
//  Copyright © 2020 Schnaub. All rights reserved.
//

@testable import MapleBacon
import XCTest

final class DoubleKeyedContainerTests: XCTestCase {

  func testInsert() {
    let container = DoubleKeyedContainer<Int, String, String>()
    container.insert("foo", forKeys: (1, "fooKey"))

    XCTAssertEqual(container[1], "foo")
    XCTAssertEqual(container["fooKey"], "foo")
    XCTAssertNil(container[100])
    XCTAssertNil(container["randomKey"])
  }

  func testRemoveAllKeys() {
    let container = DoubleKeyedContainer<Int, String, String>()
    container.insert("foo", forKeys: (1, "fooKey"))
    container.removeValue(forKeys: (1, "fooKey"))

    XCTAssertNil(container[1])
    XCTAssertNil(container["fooKey"])
  }

  func testRemoveFirstKey() {
    let container = DoubleKeyedContainer<Int, String, String>()
    container.insert("foo", forKeys: (1, "fooKey"))
    container.removeValue(forKey: 1)
    container.removeValue(forKey: 100)

    XCTAssertNil(container[1])
    XCTAssertNil(container["fooKey"])
  }

  func testRemoveSecondKey() {
    let container = DoubleKeyedContainer<Int, String, String>()
    container.insert("foo", forKeys: (1, "fooKey"))
    container.removeValue(forKey: "fooKey")

    XCTAssertNil(container[1])
    XCTAssertNil(container["fooKey"])
  }

  func testUpdate() {
    let container = DoubleKeyedContainer<Int, String, String>()
    container.insert("foo", forKeys: (1, "fooKey"))

    container.update("bar", forKey: 1)
    XCTAssertEqual(container[1], "bar")
    XCTAssertEqual(container["fooKey"], "bar")

    container.update("baz", forKey: "fooKey")
    XCTAssertEqual(container[1], "baz")
    XCTAssertEqual(container["fooKey"], "baz")
  }

  func testAccessPerformance() {
    let container = DoubleKeyedContainer<Int, String, String>()
    container.insert("foo", forKeys: (1, "fooKey"))

    self.measure {
      XCTAssertEqual(container[1], "foo")
      XCTAssertEqual(container["fooKey"], "foo")
    }
  }

}
