//
//  Copyright © 2017 Jan Gorman. All rights reserved.
//

import Foundation

final class URLHook: HTTPClientHook {

  func load() {
    URLProtocol.registerClass(HTTPStubURLProtocol.self)
  }

  func unload() {
    URLProtocol.unregisterClass(HTTPStubURLProtocol.self)
  }

  func isEqual(to other: HTTPClientHook) -> Bool {
    if let o = other as? URLHook {
      return o == self
    }
    return false
  }

}
