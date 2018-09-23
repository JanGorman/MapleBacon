//
//  Copyright © 2017 Jan Gorman. All rights reserved.
//

import XCTest
import MapleBacon

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

  override func tearDown() {
    super.tearDown()
    Cache.default.clearMemory()
    Cache.default.clearDisk()
  }
  
  func testIntegration() {
    let configuration = MockURLProtocol.mockedURLSessionConfiguration()
    let downloader = Downloader(sessionConfiguration: configuration)
    let mapleBacon = MapleBacon(cache: .default, downloader: downloader)

    let expectation = self.expectation(description: "Download image")
    let url = URL(string: "https://www.apple.com/mapleBacon.png")!
    mapleBacon.image(with: url, progress: nil) { image in
      XCTAssertNotNil(image)
      expectation.fulfill()
    }
    
    wait(for: [expectation], timeout: 5)
  }

  func testTransformerIntegration() {
    let configuration = MockURLProtocol.mockedURLSessionConfiguration()
    let downloader = Downloader(sessionConfiguration: configuration)
    let mapleBacon = MapleBacon(cache: .default, downloader: downloader)

    let expectation = self.expectation(description: "Download image")
    let url = URL(string: "https://www.apple.com/mapleBacon.png")!
    let transformer = DummyTransformer()
    mapleBacon.image(with: url, transformer: transformer, progress: nil) { image in
      XCTAssertNotNil(image)
      XCTAssertEqual(transformer.callCount, 1)
      expectation.fulfill()
    }

    wait(for: [expectation], timeout: 5)
  }

  func testTransformerResultIsCached() {
    let configuration = MockURLProtocol.mockedURLSessionConfiguration()
    let downloader = Downloader(sessionConfiguration: configuration)
    let mapleBacon = MapleBacon(cache: .default, downloader: downloader)

    let expectation = self.expectation(description: "Download image")
    let url = URL(string: "https://www.apple.com/mapleBacon.png")!
    let transformer = DummyTransformer()
    mapleBacon.image(with: url, transformer: transformer, progress: nil) { _ in
      XCTAssertEqual(transformer.callCount, 1)

      MapleBacon.shared.image(with: url, transformer: transformer, progress: nil) { image in
        XCTAssertNotNil(image)
        XCTAssertEqual(transformer.callCount, 1)
        expectation.fulfill()
      }
    }

    wait(for: [expectation], timeout: 5)
  }

}
