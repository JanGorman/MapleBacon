//
//  Copyright © 2017 Jan Gorman. All rights reserved.
//

import XCTest
import Nimble
import MapleBacon

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
  
  override func setUp() {
    super.setUp()
    MockURLProtocol.requestHandler = { request in
      return (HTTPURLResponse(), self.helper.imageResponseData())
    }
  }

  override func tearDown() {
    super.tearDown()
    MapleBaconCache.default.clearMemory()
    MapleBaconCache.default.clearDisk()
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
