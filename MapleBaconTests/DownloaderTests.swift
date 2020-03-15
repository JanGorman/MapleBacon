//
//  Copyright © 2020 Schnaub. All rights reserved.
//

@testable import MapleBacon
import XCTest

final class DownloaderTests: XCTestCase {

  private static let url = URL(string: "https://example.com/mapleBacon.png")!

  func testDownload() {
    let expectation = self.expectation(description: #function)
    let configuration = MockURLProtocol.mockedURLSessionConfiguration()
    let downloader = Downloader<Data>(sessionConfiguration: configuration)

    setupMockResponse(.data(dummyData()))

    _ = downloader.fetch(Self.url) { response in
      switch response {
      case .success(let data):
        XCTAssertNotNil(data)
      case .failure:
        XCTFail()
      }
      expectation.fulfill()
    }

    waitForExpectations(timeout: 5, handler: nil)
  }

  func testInvalidData() {
    let expectation = self.expectation(description: #function)
    let configuration = MockURLProtocol.mockedURLSessionConfiguration()
    // The default mock response returns Data that cannot be deserialised into a UIImage
    let downloader = Downloader<UIImage>(sessionConfiguration: configuration)

    setupMockResponse(.data(dummyData()))

    _ = downloader.fetch(Self.url) { response in
      switch response {
      case .success:
        XCTFail()
      case .failure(let error):
        XCTAssertNotNil(error)

      }
      expectation.fulfill()
    }

    waitForExpectations(timeout: 5, handler: nil)
  }

  func testFailure() {
    let expectation = self.expectation(description: #function)
    let configuration = MockURLProtocol.mockedURLSessionConfiguration()
    let downloader = Downloader<Data>(sessionConfiguration: configuration)

    setupMockResponse(.error)

    _ = downloader.fetch(Self.url) { response in
      switch response {
      case .success:
        XCTFail()
      case .failure(let error):
        XCTAssertNotNil(error)
      }
      expectation.fulfill()
    }

    waitForExpectations(timeout: 5, handler: nil)
  }

  func testConcurrentDownloads() {
    let configuration = MockURLProtocol.mockedURLSessionConfiguration()
    let downloader = Downloader<Data>(sessionConfiguration: configuration)

    setupMockResponse(.data(dummyData()))

    let firstExpectation = expectation(description: "first")
    _ = downloader.fetch(Self.url) { response in
      switch response {
      case .success(let data):
        XCTAssertNotNil(data)
      case .failure:
        XCTFail()
      }
      firstExpectation.fulfill()
    }

    let secondExpectation = expectation(description: "second")
    _ = downloader.fetch(Self.url) { response in
      switch response {
      case .success(let data):
        XCTAssertNotNil(data)
      case .failure:
        XCTFail()
      }
      secondExpectation.fulfill()
    }

    waitForExpectations(timeout: 5, handler: nil)
  }

  func testCancel() {
    let expectation = self.expectation(description: #function)
    let configuration = MockURLProtocol.mockedURLSessionConfiguration()
    let downloader = Downloader<Data>(sessionConfiguration: configuration)

    setupMockResponse(.error)

    let downloadTask = downloader.fetch(Self.url) { response in
      switch response {
      case .failure(let error as DownloaderError):
        XCTAssertEqual(error, .canceled)
      case .success, .failure:
        XCTFail()
      }
      expectation.fulfill()
    }

    XCTAssertNotNil(downloadTask)
    downloadTask.cancel()

    waitForExpectations(timeout: 5, handler: nil)
  }

}
