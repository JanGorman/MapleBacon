//
//  Copyright © 2020 Schnaub. All rights reserved.
//

@testable import MapleBacon
import XCTest

final class MapleBaconTests: XCTestCase {

  private static let url = URL(string: "https://example.com/mapleBacon.png")!

  private let cache = Cache<UIImage>(name: "MapleBaconTests")

  override func tearDown() {
    cache.clear(.all)
    // Clearing the disk is an async operation so we should wait
    wait(for: 2.seconds)

    super.tearDown()
  }

  func testIntegration() {
    let expectation = self.expectation(description: #function)
    let configuration = MockURLProtocol.mockedURLSessionConfiguration()
    let mapleBacon = MapleBacon(cache: cache, sessionConfiguration: configuration)

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

  func testError() {
    let expectation = self.expectation(description: #function)
    let configuration = MockURLProtocol.mockedURLSessionConfiguration()
    let mapleBacon = MapleBacon(cache: cache, sessionConfiguration: configuration)

    setupMockResponse(.error)

    mapleBacon.image(with: Self.url) { result in
      switch result {
      case .success:
        XCTFail()
      case .failure(let error):
        XCTAssertNotNil(error)
      }
      expectation.fulfill()
    }

    waitForExpectations(timeout: 5, handler: nil)
  }

  func testTransformer() {
    let expectation = self.expectation(description: #function)
    let configuration = MockURLProtocol.mockedURLSessionConfiguration()
    let mapleBacon = MapleBacon(cache: cache, sessionConfiguration: configuration)
    let transformer = FirstDummyTransformer()

    setupMockResponse(.data(makeImageData()))

    mapleBacon.image(with: Self.url, imageTransformer: transformer) { result in
      switch result {
      case .success(let image):
        XCTAssertEqual(image.pngData(), makeImageData())
        XCTAssertEqual(transformer.callCount, 1)
      case .failure:
        XCTFail()
      }
      expectation.fulfill()
    }

    waitForExpectations(timeout: 5, handler: nil)
  }

}
