//
//  Copyright © 2020 Schnaub. All rights reserved.
//

#if canImport(Combine)
import Combine
#endif
@testable import MapleBacon
import XCTest

final class MapleBaconTests: XCTestCase {

  private static let url = URL(string: "https://example.com/mapleBacon.png")!

  private let cache = Cache<UIImage>(name: "MapleBaconTests")

  
  private lazy var _subscriptions: Any? = nil
  @available(iOS 13.0, *)
  private var subscriptions: Set<AnyCancellable> {
    get {
      if _subscriptions == nil {
        _subscriptions = Set<AnyCancellable>()
      }
      return _subscriptions as! Set<AnyCancellable>
    }
    set {
      _subscriptions = newValue
    }
  }

  func testIntegration() {
    let expectation = self.expectation(description: #function)
    let mapleBacon = MapleBacon(cache: cache, sessionConfiguration: .imageDataProviding)

    let token = mapleBacon.image(with: Self.url) { result in
      switch result {
      case .success(let image):
        XCTAssertEqual(image.pngData(), makeImageData())
      case .failure:
        XCTFail()
      }
      mapleBacon.clearCache(.all) { _ in
        expectation.fulfill()
      }
    }

    XCTAssertNotNil(token)
    waitForExpectations(timeout: 5, handler: nil)
  }

  func testError() {
    let expectation = self.expectation(description: #function)
    let mapleBacon = MapleBacon(cache: cache, sessionConfiguration: .failed)

    mapleBacon.image(with: Self.url) { result in
      switch result {
      case .success:
        XCTFail()
      case .failure(let error):
        XCTAssertNotNil(error)
      }
      mapleBacon.clearCache(.all) { _ in
        expectation.fulfill()
      }
    }

    waitForExpectations(timeout: 5, handler: nil)
  }

  func testTransformer() {
    let expectation = self.expectation(description: #function)
    let transformer = FirstDummyTransformer()
    let mapleBacon = MapleBacon(cache: cache, sessionConfiguration: .imageDataProviding)

    mapleBacon.image(with: Self.url, imageTransformer: transformer) { result in
      switch result {
      case .success(let image):
        XCTAssertEqual(image.pngData(), makeImageData())
        XCTAssertEqual(transformer.callCount, 1)
      case .failure:
        XCTFail()
      }
      mapleBacon.clearCache(.all) { _ in
        expectation.fulfill()
      }
    }

    waitForExpectations(timeout: 5, handler: nil)
  }

  func testCancel() {
    let expectation = self.expectation(description: #function)
    let mapleBacon = MapleBacon(cache: cache, sessionConfiguration: .failed)

    let downloadTask = mapleBacon.image(with: Self.url) { result in
      switch result {
      case .failure(let error as DownloaderError):
        XCTAssertEqual(error, .canceled)
      case .success, .failure:
        XCTFail()
      }
      mapleBacon.clearCache(.all) { _ in
        expectation.fulfill()
      }
    }

    XCTAssertNotNil(downloadTask)
    downloadTask?.cancel()

    waitForExpectations(timeout: 5, handler: nil)
  }

}

#if canImport(Combine)

@available(iOS 13.0, *)
extension MapleBaconTests {

  func testIntegrationPublisher() {
    let expectation = self.expectation(description: #function)
    let mapleBacon = MapleBacon(cache: cache, sessionConfiguration: .imageDataProviding)

    mapleBacon.image(with: Self.url)
      .sink(receiveCompletion: { _ in
        mapleBacon.clearCache(.all) { _ in
          expectation.fulfill()
        }
      }, receiveValue: { image in
        XCTAssertEqual(image.pngData(), makeImageData())
      })
      .store(in: &self.subscriptions)

    waitForExpectations(timeout: 5, handler: nil)
  }

}

#endif
