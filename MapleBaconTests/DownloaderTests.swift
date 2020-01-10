//
//  Copyright © 2017 Jan Gorman. All rights reserved.
//

import XCTest
import MapleBacon
#if canImport(Combine)
import Combine
#endif

final class DownloaderTests: XCTestCase {
  
  private let url: URL = "https://www.apple.com/mapleBacon.png"
  private let helper = TestHelper()

  @available(iOS 13.0, *)
  private lazy var subscriptions: Set<AnyCancellable> = []

  override func setUp() {
    MockURLProtocol.requestHandler = { request in
      return (HTTPURLResponse(), self.helper.imageData)
    }
    super.setUp()
  }

  override func tearDown() {
    super.tearDown()
    if #available(iOS 13.0, *) {
      subscriptions.removeAll()
    }
  }

  func testDownload() {
    let configuration = MockURLProtocol.mockedURLSessionConfiguration()
    let downloader = Downloader(sessionConfiguration: configuration)

    let expectation = self.expectation(description: #function)

    let token = downloader.download(self.url) { data in
      XCTAssertNotNil(data)
      expectation.fulfill()
    }

    waitForExpectations(timeout: 5, handler: nil)
    XCTAssertNotNil(token)
  }

  func testMultipleDownloads() {
    let configuration = MockURLProtocol.mockedURLSessionConfiguration()
    let downloader = Downloader(sessionConfiguration: configuration)

    let firstExpectation = expectation(description: "first")

    let url1 = url
    _ = downloader.download(url1) { data in
      XCTAssertNotNil(data)
      firstExpectation.fulfill()
    }

    let secondExpectation = expectation(description: "second")
    
    let url2 = url
    _ = downloader.download(url2) { data in
      XCTAssertNotNil(data)
      secondExpectation.fulfill()
    }

    waitForExpectations(timeout: 5, handler: nil)
  }

  func testSynchronousMultipleDownloadsOfSameURL() {
    let configuration = MockURLProtocol.mockedURLSessionConfiguration()
    let downloader = Downloader(sessionConfiguration: configuration)

    let expectation = self.expectation(description: #function)

    _ = downloader.download(self.url) { data in
      XCTAssertNotNil(data)
    }
    _ = downloader.download(self.url) { data in
      XCTAssertNotNil(data)
      expectation.fulfill()
    }

    waitForExpectations(timeout: 5, handler: nil)
  }

  func testFailedDownload() {
    MockURLProtocol.requestHandler = { request in
      let anyError = NSError(domain: NSURLErrorDomain, code: NSURLErrorUnknown, userInfo: nil)
      throw anyError
    }
    let configuration = MockURLProtocol.mockedURLSessionConfiguration()
    let downloader = Downloader(sessionConfiguration: configuration)

    let expectation = self.expectation(description: #function)

    _ = downloader.download(self.url) { data in
      XCTAssertNil(data)
      expectation.fulfill()
    }

    waitForExpectations(timeout: 5, handler: nil)
  }

  func testCancel() {
    let configuration = MockURLProtocol.mockedURLSessionConfiguration()
    let downloader = Downloader(sessionConfiguration: configuration)

    let expectation = self.expectation(description: #function)

    let token = downloader.download(url) { data in
      XCTAssertNil(data)
      expectation.fulfill()
    }
    downloader.cancel(withToken: token)

    waitForExpectations(timeout: 5, handler: nil)
  }

}

#if canImport(Combine)

@available(iOS 13.0, *)
extension DownloaderTests {

  func testDownloadWithPublisher() {
    let configuration = MockURLProtocol.mockedURLSessionConfiguration()
    let downloader = Downloader(sessionConfiguration: configuration)

    let expectation = self.expectation(description: #function)

    downloader.download(self.url)
      .sink(receiveCompletion: { _ in
        expectation.fulfill()
      }, receiveValue: { data in
        XCTAssertNotNil(data)
      })
      .store(in: &self.subscriptions)

    waitForExpectations(timeout: 5, handler: nil)
  }

  func testFailedDownloadWithPublisher() {
    MockURLProtocol.requestHandler = { request in
      let anyError = NSError(domain: NSURLErrorDomain, code: NSURLErrorUnknown, userInfo: nil)
      throw anyError
    }
    let configuration = MockURLProtocol.mockedURLSessionConfiguration()
    let downloader = Downloader(sessionConfiguration: configuration)

    let expectation = self.expectation(description: #function)

    downloader.download(self.url)
      .sink(receiveCompletion: { completion in
        if case .failure(let error) = completion {
          XCTAssertEqual(error, .invalidServerResponse)
          expectation.fulfill()
        }
      }, receiveValue: { data in
        XCTAssertNotNil(data)
      })
      .store(in: &self.subscriptions)

    waitForExpectations(timeout: 5, handler: nil)
  }

}

#endif
