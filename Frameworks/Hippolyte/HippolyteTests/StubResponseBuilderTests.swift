//
//  Copyright © 2017 Jan Gorman. All rights reserved.
//

import XCTest
import Hippolyte

class StubResponseBuilderTests: XCTestCase {
    
  func testBuilderProducesStubs() {
    let builder = StubResponse.Builder()

    let stub1 = builder.stubResponse(withStatusCode: 400).addHeader(withKey: "X-Foo", value: "Bar").build()

    XCTAssertNotNil(stub1)
    XCTAssertEqual(stub1.statusCode, 400)

    let stub2 = builder.stubResponse(withError: NSError(domain: "Error", code: -1, userInfo: nil))
      .addBody("".data(using: .utf8)!)
      .build()

    XCTAssertNotNil(stub2)
    XCTAssertNotNil(stub2.error)
    XCTAssertNotNil(stub2.body)
  }
    
}
