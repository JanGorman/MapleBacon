//
//  Copyright © 2017 Jan Gorman. All rights reserved.
//

import XCTest
import Nimble
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
      return (HTTPURLResponse(), self.helper.imageData)
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

    waitUntil { done in
      mapleBacon.image(with: self.url) { image in
        expect(image).toNot(beNil())
        done()
      }
    }
  }

  func testTransformerIntegration() {
    let configuration = MockURLProtocol.mockedURLSessionConfiguration()
    let downloader = Downloader(sessionConfiguration: configuration)
    let mapleBacon = MapleBacon(cache: .default, downloader: downloader)

    let transformer = DummyTransformer()
    waitUntil { done in
      mapleBacon.image(with: self.url, transformer: transformer) { image in
        expect(image).toNot(beNil())
        expect(transformer.callCount) == 1
        done()
      }
    }
  }

  func testTransformerResultIsCached() {
    let configuration = MockURLProtocol.mockedURLSessionConfiguration()
    let downloader = Downloader(sessionConfiguration: configuration)
    let mapleBacon = MapleBacon(cache: .default, downloader: downloader)

    let transformer = DummyTransformer()
    waitUntil { done in
      mapleBacon.image(with: self.url, transformer: transformer) { _ in
        expect(transformer.callCount) == 1
        
        mapleBacon.image(with: self.url, transformer: transformer) { image in
          expect(image).toNot(beNil())
          expect(transformer.callCount) == 1
          done()
        }
      }
    }
  }

  func testDataDownloadIntegration() {
    let configuration = MockURLProtocol.mockedURLSessionConfiguration()
    let downloader = Downloader(sessionConfiguration: configuration)
    let mapleBacon = MapleBacon(cache: .default, downloader: downloader)

    waitUntil { done in
      mapleBacon.data(with: self.url) { data in
        expect(data).toNot(beNil())
        done()
      }
    }
  }

  func testFailedDownloadIntegration() {
    MockURLProtocol.requestHandler = { request in
      return (HTTPURLResponse(), Data())
    }

    let configuration = MockURLProtocol.mockedURLSessionConfiguration()
    let downloader = Downloader(sessionConfiguration: configuration)
    let mapleBacon = MapleBacon(cache: .default, downloader: downloader)

    waitUntil { done in
      mapleBacon.image(with: self.url) { image in
        expect(image).to(beNil())
        done()
      }
    }
  }

  func testCancel() {
    let configuration = MockURLProtocol.mockedURLSessionConfiguration()
    let downloader = Downloader(sessionConfiguration: configuration)
    let mapleBacon = MapleBacon(cache: .default, downloader: downloader)

    var imageData: Data?
    let token = mapleBacon.data(with: url) { data in
      imageData = data
    }
    mapleBacon.cancelDownload(withToken: token!)

    waitUntil { done in
      expect(imageData).to(beNil())
      done()
    }
  }

}

#if canImport(Combine)

@available(iOS 13.0, *)
extension MapleBaconTests {

  func testIntegrationPublisher() {
    let configuration = MockURLProtocol.mockedURLSessionConfiguration()
    let downloader = Downloader(sessionConfiguration: configuration)
    let mapleBacon = MapleBacon(cache: .default, downloader: downloader)

    waitUntil { done in
      mapleBacon.image(with: self.url)
        .sink(receiveCompletion: { _ in
          done()
        }, receiveValue: { image in
          expect(image).toNot(beNil())
        })
        .store(in: &self.subscriptions)
    }
  }

}

#endif
