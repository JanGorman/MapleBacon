//
//  Copyright © 2020 Schnaub. All rights reserved.
//

import MapleBacon
import XCTest

final class MapleBaconTests: XCTestCase {

  private static let url = URL(string: "https://example.com/mapleBacon.png")!

  func testIntegration() {
    let expectation = self.expectation(description: #function)
    let configuration = MockURLProtocol.mockedURLSessionConfiguration()
    let mapleBacon = MapleBacon(sessionConfiguration: configuration)

    setupMockResponse(.data(makeImageData()))

    mapleBacon.image(with: Self.url) { result in
      switch result {
      case .success(let image):
        XCTAssertEqual(image.pngData(), makeImageData())
      case .failure:
        XCTFail()
      }
      expectation.fulfill()
    }

    waitForExpectations(timeout: 5, handler: nil)
  }
}
