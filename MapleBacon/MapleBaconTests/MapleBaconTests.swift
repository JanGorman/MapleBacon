//
//  Copyright © 2017 Jan Gorman. All rights reserved.
//

import XCTest
import MapleBacon
import Hippolyte

class MapleBaconTests: XCTestCase {
  
  private let helper = TestHelper()
    
  override func setUp() {
    super.setUp()
    Hippolyte.shared.start()
  }
  
  override func tearDown() {
    super.tearDown()
    Hippolyte.shared.stop()
  }
  
  func testIntegration() {
    let expectation = self.expectation(description: "Download image")
    let url = URL(string: "https://www.apple.com/mapleBacon.png")!
    Hippolyte.shared.add(stubbedRequest: helper.request(url: url, response: helper.imageResponse()))
    
    MapleBacon.shared.image(with: url, progress: nil) { image in
      XCTAssertNotNil(image)
      expectation.fulfill()
    }
    
    wait(for: [expectation], timeout: 1)
  }
    
}
