//
//  Copyright © 2017 Jan Gorman. All rights reserved.
//

import XCTest
import Nimble
import MapleBacon

class DownloaderTests: XCTestCase {
  
  private let url = URL(string: "https://www.apple.com/mapleBacon.png")!
  private let helper = TestHelper()

  func testDownload() {
    MockURLProtocol.requestHandler = { request in
      return (HTTPURLResponse(), self.helper.imageResponseData())
    }
    let configuration = MockURLProtocol.mockedURLSessionConfiguration()
    let downloader = Downloader(sessionConfiguration: configuration)

    waitUntil { done in
      downloader.download(self.url) { data in
        expect(data).toNot(beNil())
        done()
      }
    }
  }

  func testMultipleDownloads() {
    MockURLProtocol.requestHandler = { request in
      return (HTTPURLResponse(), self.helper.imageResponseData())
    }
    let configuration = MockURLProtocol.mockedURLSessionConfiguration()
    let downloader = Downloader(sessionConfiguration: configuration)

    let url1 = url
    waitUntil { done in
      downloader.download(url1) { data in
        expect(data).toNot(beNil())
        done()
      }
    }
    
    let url2 = url
    waitUntil { done in
      downloader.download(url2) { data in
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
      downloader.download(self.url) { data in
        expect(data).to(beNil())
        done()
      }
    }
  }

}
