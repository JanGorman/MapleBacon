//
//  Copyright © 2017 Jan Gorman. All rights reserved.
//

import XCTest
import MapleBacon

class DownloaderTests: XCTestCase {
  
  private let helper = TestHelper()

  func testDownload() {
    MockURLProtocol.requestHandler = { request in
      return (HTTPURLResponse(), self.helper.imageResponseData())
    }
    let configuration = MockURLProtocol.mockedURLSessionConfiguration()
    let downloader = Downloader(sessionConfiguration: configuration)

    let expectation = self.expectation(description: "Download image")
    let url = URL(string: "https://www.apple.com/mapleBacon.png")!
    downloader.download(url) { data in
      XCTAssertNotNil(data)
      expectation.fulfill()
    }

    wait(for: [expectation], timeout: 1)
  }

  func testMultipleDownloads() {
    MockURLProtocol.requestHandler = { request in
      return (HTTPURLResponse(), self.helper.imageResponseData())
    }
    let configuration = MockURLProtocol.mockedURLSessionConfiguration()
    let downloader = Downloader(sessionConfiguration: configuration)

    let expectation = self.expectation(description: "Download image")

    let url1 = URL(string: "https://www.apple.com/mapleBacon.png")!
    downloader.download(url1) { data in
      XCTAssertNotNil(data)
    }
    let url2 = URL(string: "https://www.apple.com/moreBacon.png")!
    downloader.download(url2) { data in
      XCTAssertNotNil(data)
      expectation.fulfill()
    }

    wait(for: [expectation], timeout: 1)
  }

  func testFailedDownload() {
    MockURLProtocol.requestHandler = { request in
      let anyError = NSError(domain: NSURLErrorDomain, code: NSURLErrorUnknown, userInfo: nil)
      throw anyError
    }
    let configuration = MockURLProtocol.mockedURLSessionConfiguration()
    let downloader = Downloader(sessionConfiguration: configuration)

    let expectation = self.expectation(description: "Download image")
    let url = URL(string: "https://www.apple.com/badBacon.png")!
    downloader.download(url) { data in
      XCTAssertNil(data)
      expectation.fulfill()
    }

    wait(for: [expectation], timeout: 1)
  }
}
