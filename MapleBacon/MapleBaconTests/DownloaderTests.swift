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
    
    let response = StubResponse.Builder()
      .stubResponse(withStatusCode: 200)
      .addBody(UIImagePNGRepresentation(UIImage(named: "MapleBacon", in: Bundle(for: type(of: self).self), compatibleWith: nil)!)!)
      .addHeader(withKey: "Content-Type", value: "image/png")
      .build()
    let request = StubRequest.Builder()
      .stubRequest(withMethod: .GET, url: url)
      .addResponse(response)
      .build()
    Hippolyte.shared.add(stubbedRequest: request)

    downloader.download(url) { image in
      XCTAssertNotNil(image)
      expectation.fulfill()
    }

    wait(for: [expectation], timeout: 1)
  }

}
