//
//  Copyright © 2017 Jan Gorman. All rights reserved.
//

import Foundation
import Hippolyte

struct TestRequest: HTTPRequest {

  var url: URL?
  var method: HTTPMethod?
  var headers: [String : String]?
  var body: Data?

  init(method: HTTPMethod, url: URL) {
    self.method = method
    self.url = url
    self.headers = [:]
  }

  mutating func setHeader(key: String, value: String) {
    headers?[key] = value
  }

}
