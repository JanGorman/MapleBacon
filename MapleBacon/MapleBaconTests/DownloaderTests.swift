//
//  Copyright © 2017 Jan Gorman. All rights reserved.
//

import XCTest
@testable import MapleBacon
import Hippolyte

class DownloaderTests: XCTestCase {

  override func setUp() {
    super.setUp()
    Hippolyte.shared.start()
  }

  override func tearDown() {
    super.tearDown()
    Hippolyte.shared.stop()
  }

  func testDownload() {
    let expectation = self.expectation(description: "Download image")
    let downloader = Downloader()
    let url = URL(string: "https://www.apple.com/mapleBacon.png")!
    Hippolyte.shared.add(stubbedRequest: request(url: url, response: imageResponse()))

    downloader.download(url) { image in
      XCTAssertNotNil(image)
      expectation.fulfill()
    }

    wait(for: [expectation], timeout: 1)
  }

  func testMultipleDownloads() {
    let expectation = self.expectation(description: "Download image")
    let downloader = Downloader()
    let url1 = URL(string: "https://www.apple.com/mapleBacon.png")!
    let url2 = URL(string: "https://www.apple.com/moreBacon.png")!
    Hippolyte.shared.add(stubbedRequest: request(url: url1, response: imageResponse()))
    Hippolyte.shared.add(stubbedRequest: request(url: url2, response: imageResponse()))

    downloader.download(url1) { image in
      XCTAssertNotNil(image)
    }
    downloader.download(url2) { image in
      XCTAssertNotNil(image)
      expectation.fulfill()
    }

    wait(for: [expectation], timeout: 1)
  }

  private func request(url: URL, response: StubResponse) -> StubRequest {
    return StubRequest.Builder()
      .stubRequest(withMethod: .GET, url: url)
      .addResponse(response)
      .build()
  }

  private func imageResponse() -> StubResponse {
    return StubResponse.Builder()
      .stubResponse(withStatusCode: 200)
      .addBody(UIImagePNGRepresentation(UIImage(named: "MapleBacon", in: Bundle(for: type(of: self).self), compatibleWith: nil)!)!)
      .addHeader(withKey: "Content-Type", value: "image/png")
      .build()
  }

}
