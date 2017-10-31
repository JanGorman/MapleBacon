//
//  Copyright © 2017 Jan Gorman. All rights reserved.
//

import XCTest
import Hippolyte

class HippolyteTests: XCTestCase {

  override func tearDown() {
    super.tearDown()
    Hippolyte.shared.stop()
  }

  func testUnmatchedRequestThrows() {
    let request = TestRequest(method: .GET, url: URL(string: "http://www.apple.com")!)

    XCTAssertThrowsError(try Hippolyte.shared.response(for: request))
  }

  func testMatchedRequest() {
    let url = URL(string: "http://www.apple.com")!
    var stub = StubRequest(method: .GET, url: url)
    let response = StubResponse(statusCode: 404)
    stub.response = response
    Hippolyte.shared.add(stubbedRequest: stub)

    let request = TestRequest(method: .GET, url: url)
    let result = try? Hippolyte.shared.response(for: request)

    XCTAssertEqual(result, response)

    Hippolyte.shared.clearStubs()
  }

  func testStubIsReplaceable() {
    let url = URL(string: "http://www.apple.com")!
    var stub1 = StubRequest(method: .GET, url: url)
    let response1 = StubResponse(statusCode: 404)
    stub1.response = response1
    Hippolyte.shared.add(stubbedRequest: stub1)

    var stub2 = StubRequest(method: .GET, url: url)
    let response2 = StubResponse(statusCode: 200)
    stub2.response = response2
    Hippolyte.shared.add(stubbedRequest: stub2)

    let request = TestRequest(method: .GET, url: url)
    let result = try? Hippolyte.shared.response(for: request)

    XCTAssertEqual(result, response2)

    Hippolyte.shared.clearStubs()
  }

  func testItStubsRegularNetworkCall() {
    let url = URL(string: "http://www.apple.com")!
    var stub = StubRequest(method: .GET, url: url)
    var response = StubResponse()
    let body = "Hippolyte".data(using: .utf8)!
    response.body = body
    stub.response = response
    Hippolyte.shared.add(stubbedRequest: stub)

    Hippolyte.shared.start()

    let expectation = self.expectation(description: "Stubs network call")
    let task = URLSession.shared.dataTask(with: url) { data, _, _ in
      XCTAssertEqual(data, body)
      expectation.fulfill()
    }
    task.resume()

    wait(for: [expectation], timeout: 1)
  }

}
