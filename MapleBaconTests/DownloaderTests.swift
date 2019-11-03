//
//  Copyright © 2017 Jan Gorman. All rights reserved.
//

import XCTest
import Nimble
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
      return (HTTPURLResponse(), self.helper.imageResponseData())
    }
    super.setUp()
  }

  override func tearDown() {
    if #available(iOS 13.0, *) {
      subscriptions.removeAll()
    }
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

#if canImport(Combine)

@available(iOS 13.0, *)
extension DownloaderTests {

  func testDownloadWithPublisher() {
    let configuration = MockURLProtocol.mockedURLSessionConfiguration()
    let downloader = Downloader(sessionConfiguration: configuration)

    waitUntil { done in
      downloader.download(self.url)
        .sink(receiveCompletion: { _ in
          done()
        }, receiveValue: { data in
          expect(data).toNot(beNil())
        })
        .store(in: &self.subscriptions)
    }
  }

  func testFailedDownloadWithPublisher() {
    MockURLProtocol.requestHandler = { request in
      let anyError = NSError(domain: NSURLErrorDomain, code: NSURLErrorUnknown, userInfo: nil)
      throw anyError
    }
    let configuration = MockURLProtocol.mockedURLSessionConfiguration()
    let downloader = Downloader(sessionConfiguration: configuration)

    waitUntil { done in
      downloader.download(self.url)
        .sink(receiveCompletion: { completion in
          if case .failure(let error) = completion {
            expect(error) == .invalidServerResponse
            done()
          }
        }, receiveValue: { data in
          expect(data).to(beNil())
        })
        .store(in: &self.subscriptions)
    }
  }

}

#endif
