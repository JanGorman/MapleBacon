//
//  Copyright © 2017 Jan Gorman. All rights reserved.
//

import XCTest
import Nimble
import MapleBacon

final class DownloaderTests: XCTestCase {
  
  private let url: URL = "https://www.apple.com/mapleBacon.png"
  private let helper = TestHelper()

  override func setUp() {
    MockURLProtocol.requestHandler = { request in
      return (HTTPURLResponse(), self.helper.imageResponseData())
    }
    super.setUp()
  }

  func testDownload() {
    let configuration = MockURLProtocol.mockedURLSessionConfiguration()
    let downloader = Downloader(sessionConfiguration: configuration)

    waitUntil { done in
      let token = downloader.download(self.url) { data in
        expect(data).toNot(beNil())
        done()
      }
      expect(token).toNot(beNil())
    }
  }

  func testMultipleDownloads() {
    let configuration = MockURLProtocol.mockedURLSessionConfiguration()
    let downloader = Downloader(sessionConfiguration: configuration)

    let url1 = url
    waitUntil { done in
      _ = downloader.download(url1) { data in
        expect(data).toNot(beNil())
        done()
      }
    }
    
    let url2 = url
    waitUntil { done in
      _ = downloader.download(url2) { data in
        expect(data).toNot(beNil())
        done()
      }
    }
  }

  func testSynchronousMultipleDownloadsOfSameURL() {
    let configuration = MockURLProtocol.mockedURLSessionConfiguration()
    let downloader = Downloader(sessionConfiguration: configuration)

    waitUntil { done in
      _ = downloader.download(self.url) { data in
        expect(data).toNot(beNil())
      }
      _ = downloader.download(self.url) { data in
        expect(data).toNot(beNil())
        done()
      }
    }
  }

  func testFailedDownload() {
    MockURLProtocol.requestHandler = { request in
      let anyError = NSError(domain: NSURLErrorDomain, code: NSURLErrorUnknown, userInfo: nil)
      throw anyError
    }
    let configuration = MockURLProtocol.mockedURLSessionConfiguration()
    let downloader = Downloader(sessionConfiguration: configuration)

    waitUntil { done in
      _ = downloader.download(self.url) { data in
        expect(data).to(beNil())
        done()
      }
    }
  }

  func testCancel() {
    let configuration = MockURLProtocol.mockedURLSessionConfiguration()
    let downloader = Downloader(sessionConfiguration: configuration)

    var imageData: Data?
    let token = downloader.download(url) { data in
      imageData = data
    }
    downloader.cancel(withToken: token)

    waitUntil { done in
      expect(imageData).to(beNil())
      done()
    }
  }

}
