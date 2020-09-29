//
//  Copyright © 2020 Schnaub. All rights reserved.
//

import Foundation

extension URLSessionConfiguration {
  static var failed: URLSessionConfiguration {
    final class MockURLProtocol: URLProtocol {
      override class func canInit(with request: URLRequest) -> Bool {
        true
      }

      override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        request
      }

      override func startLoading() {
        let error = NSError(domain: NSURLErrorDomain, code: NSURLErrorUnknown, userInfo: nil)
        client?.urlProtocol(self, didFailWithError: error)
      }

      override func stopLoading() {}
    }

    let configuration: URLSessionConfiguration = .ephemeral
    configuration.protocolClasses = [MockURLProtocol.self]
    return configuration
  }

  static var dummyDataProviding: URLSessionConfiguration {
    final class MockURLProtocol: URLProtocol {
      override class func canInit(with request: URLRequest) -> Bool {
        true
      }

      override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        request
      }

      override func startLoading() {
        client?.urlProtocol(self, didReceive: HTTPURLResponse(), cacheStoragePolicy: .notAllowed)
        client?.urlProtocol(self, didLoad: dummyData())
        client?.urlProtocolDidFinishLoading(self)
      }

      override func stopLoading() {}
    }

    let configuration: URLSessionConfiguration = .ephemeral
    configuration.protocolClasses = [MockURLProtocol.self]
    return configuration
  }

  static var imageDataProviding: URLSessionConfiguration {
    final class MockURLProtocol: URLProtocol {
      override class func canInit(with request: URLRequest) -> Bool {
        true
      }

      override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        request
      }

      override func startLoading() {
        client?.urlProtocol(self, didReceive: HTTPURLResponse(), cacheStoragePolicy: .notAllowed)
        client?.urlProtocol(self, didLoad: makeImage().pngData()!)
        client?.urlProtocolDidFinishLoading(self)
      }

      override func stopLoading() {}
    }

    let configuration: URLSessionConfiguration = .ephemeral
    configuration.protocolClasses = [MockURLProtocol.self]
    return configuration
  }
}
