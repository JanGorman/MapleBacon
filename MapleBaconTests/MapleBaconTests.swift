//
//  Copyright © 2017 Jan Gorman. All rights reserved.
//

import XCTest
import MapleBacon
import Hippolyte

class MapleBaconTests: XCTestCase {

  private class DummyTransformer: ImageTransformer, CallCounting {

    let identifier = "com.schnaub.DummyTransformer"

    var callCount = 0

    func transform(image: UIImage) -> UIImage? {
      callCount += 1
      return image
    }

  }
  
  private let helper = TestHelper()
    
  override func setUp() {
    super.setUp()
    Hippolyte.shared.start()
  }
  
  override func tearDown() {
    super.tearDown()
    Hippolyte.shared.stop()
    Cache.default.clearMemory()
    Cache.default.clearDisk()
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

  func testTransformerIntegration() {
    let expectation = self.expectation(description: "Download image")
    let url = URL(string: "https://www.apple.com/mapleBacon.png")!
    Hippolyte.shared.add(stubbedRequest: helper.request(url: url, response: helper.imageResponse()))

    let transformer = DummyTransformer()
    MapleBacon.shared.image(with: url, transformer: transformer, progress: nil) { image in
      XCTAssertNotNil(image)
      XCTAssertEqual(transformer.callCount, 1)
      expectation.fulfill()
    }

    wait(for: [expectation], timeout: 1)
  }

  func testTransformerResultIsCached() {
    let expectation = self.expectation(description: "Download image")
    let url = URL(string: "https://www.apple.com/mapleBacon.png")!
    Hippolyte.shared.add(stubbedRequest: helper.request(url: url, response: helper.imageResponse()))

    let transformer = DummyTransformer()
    MapleBacon.shared.image(with: url, transformer: transformer, progress: nil) { _ in
      XCTAssertEqual(transformer.callCount, 1)

      MapleBacon.shared.image(with: url, transformer: transformer, progress: nil) { image in
        XCTAssertNotNil(image)
        XCTAssertEqual(transformer.callCount, 1)
        expectation.fulfill()
      }
    }

    wait(for: [expectation], timeout: 1)
  }
    
}
