//
//  Copyright © 2017 Jan Gorman. All rights reserved.
//

import XCTest
import MapleBacon
#if canImport(Combine)
import Combine
#endif

final class MapleBaconTests: XCTestCase {

  private class DummyTransformer: ImageTransformer, CallCounting {

    let identifier = "com.schnaub.DummyTransformer"

    private(set) var callCount = 0

    func transform(image: UIImage) -> UIImage? {
      callCount += 1
      return image
    }

  }

  private let url: URL = "https://www.apple.com/mapleBacon.png"
  private let helper = TestHelper()

  @available(iOS 13.0, *)
  private lazy var subscriptions: Set<AnyCancellable> = []
  
  override func setUp() {
    super.setUp()
    MockURLProtocol.requestHandler = { request in
      (HTTPURLResponse(), self.helper.imageData)
    }
  }

  override func tearDown() {
    super.tearDown()
    MapleBaconCache.default.clearMemory()
    MapleBaconCache.default.clearDisk()
    if #available(iOS 13.0, *) {
      subscriptions.removeAll()
    }
  }
  
  func testIntegration() {
    let configuration = MockURLProtocol.mockedURLSessionConfiguration()
    let downloader = Downloader(sessionConfiguration: configuration)
    let mapleBacon = MapleBacon(cache: .default, downloader: downloader)

    let expectation = self.expectation(description: #function)

    mapleBacon.image(with: self.url) { image in
      XCTAssertNotNil(image)
      expectation.fulfill()
    }

    waitForExpectations(timeout: 5, handler: nil)
  }

  func testTransformerIntegration() {
    let configuration = MockURLProtocol.mockedURLSessionConfiguration()
    let downloader = Downloader(sessionConfiguration: configuration)
    let mapleBacon = MapleBacon(cache: .default, downloader: downloader)

    let expectation = self.expectation(description: #function)

    let transformer = DummyTransformer()
    mapleBacon.image(with: self.url, transformer: transformer) { image in
      XCTAssertNotNil(image)
      XCTAssertEqual(transformer.callCount, 1)
      expectation.fulfill()
    }

    waitForExpectations(timeout: 5, handler: nil)
  }

  func testTransformerResultIsCached() {
    let configuration = MockURLProtocol.mockedURLSessionConfiguration()
    let downloader = Downloader(sessionConfiguration: configuration)
    let mapleBacon = MapleBacon(cache: .default, downloader: downloader)

    let expectation = self.expectation(description: #function)

    let transformer = DummyTransformer()
    mapleBacon.image(with: self.url, transformer: transformer) { _ in
      XCTAssertEqual(transformer.callCount, 1)

      mapleBacon.image(with: self.url, transformer: transformer) { image in
        XCTAssertNotNil(image)
        XCTAssertEqual(transformer.callCount, 1)
        expectation.fulfill()
      }
    }

    waitForExpectations(timeout: 5, handler: nil)
  }

  func testDataDownloadIntegration() {
    let configuration = MockURLProtocol.mockedURLSessionConfiguration()
    let downloader = Downloader(sessionConfiguration: configuration)
    let mapleBacon = MapleBacon(cache: .default, downloader: downloader)

    let expectation = self.expectation(description: #function)

    mapleBacon.data(with: self.url) { data in
      XCTAssertNotNil(data)
      expectation.fulfill()
    }

    waitForExpectations(timeout: 5, handler: nil)
  }

  func testFailedDownloadIntegration() {
    MockURLProtocol.requestHandler = { request in
      (HTTPURLResponse(), Data())
    }

    let configuration = MockURLProtocol.mockedURLSessionConfiguration()
    let downloader = Downloader(sessionConfiguration: configuration)
    let mapleBacon = MapleBacon(cache: .default, downloader: downloader)

    let expectation = self.expectation(description: #function)

    mapleBacon.image(with: self.url) { image in
      XCTAssertNil(image)

      expectation.fulfill()
    }

    waitForExpectations(timeout: 5, handler: nil)
  }

  func testCancel() {
    let configuration = MockURLProtocol.mockedURLSessionConfiguration()
    let downloader = Downloader(sessionConfiguration: configuration)
    let mapleBacon = MapleBacon(cache: .default, downloader: downloader)

    let expectation = self.expectation(description: #function)

    let token = mapleBacon.data(with: url) { data in
      XCTAssertNil(data)
      expectation.fulfill()
    }
    mapleBacon.cancelDownload(withToken: token!)

    waitForExpectations(timeout: 5, handler: nil)
  }

}

#if canImport(Combine)

@available(iOS 13.0, *)
extension MapleBaconTests {

  func testIntegrationPublisher() {
    let configuration = MockURLProtocol.mockedURLSessionConfiguration()
    let downloader = Downloader(sessionConfiguration: configuration)
    let mapleBacon = MapleBacon(cache: .default, downloader: downloader)

    let expectation = self.expectation(description: #function)

    mapleBacon.image(with: self.url)
      .sink(receiveCompletion: { _ in
        expectation.fulfill()
      }, receiveValue: { image in
        XCTAssertNotNil(image)
      })
      .store(in: &self.subscriptions)

    waitForExpectations(timeout: 5, handler: nil)
  }

}

#endif
