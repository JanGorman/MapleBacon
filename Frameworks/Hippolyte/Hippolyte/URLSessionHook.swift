//
//  Copyright © 2017 Jan Gorman. All rights reserved.
//

import Foundation

final class URLSessionHook: HTTPClientHook {

  func isEqual(to other: HTTPClientHook) -> Bool {
    if let o = other as? URLSessionHook {
      return o == self
    }
    return false
  }

  func load() {
    guard let method = class_getInstanceMethod(originalClass(), originalSelector()),
          let stub = class_getInstanceMethod(URLSessionHook.self, #selector(protocolClasses)) else {
      fatalError("Couldn't load URLSessionHook")
    }
    method_exchangeImplementations(method, stub)
  }

  private func originalClass() -> AnyClass? {
    return NSClassFromString("__NSCFURLSessionConfiguration") ?? NSClassFromString("NSURLSessionConfiguration")
  }

  private func originalSelector() -> Selector {
    return #selector(getter: URLSessionConfiguration.protocolClasses)
  }

  @objc private func protocolClasses() -> [AnyClass] {
    return [HTTPStubURLProtocol.self]
  }

  func unload() {
    load()
  }

}
