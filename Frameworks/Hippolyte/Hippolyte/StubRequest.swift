//
//  Copyright © 2017 Jan Gorman. All rights reserved.
//

import Foundation

public enum HTTPMethod: String {
  case GET, PUT, POST, DELETE
}

public struct StubRequest: Hashable {

  public final class Builder {

    private var request: StubRequest!

    public init() {
    }

    public func stubRequest(withMethod method: HTTPMethod, url: URL) -> Builder {
      request = StubRequest(method: method, url: url)
      return self
    }

    public func stubRequest(withMethod method: HTTPMethod, urlMatcher: Matcher) -> Builder {
      request = StubRequest(method: method, urlMatcher: urlMatcher)
      return self
    }

    public func addHeader(withKey key: String, value: String) -> Builder {
      assert(request != nil)
      request.setHeader(key: key, value: value)
      return self
    }

    public func addResponse(_ response: StubResponse) -> Builder {
      assert(request != nil)
      request.response = response
      return self
    }

    public func build() -> StubRequest {
      return request
    }

  }

  public let method: HTTPMethod
  public private(set) var headers: [String: String]
  public var response: StubResponse
  public var bodyMatcher: Matcher?

  private let urlMatcher: Matcher

  /// Initialize a request with method and URL
  ///
  /// - Parameter method: The `HTTPMethod` to match
  /// - Parameter  url: The `URL` to match
  public init(method: HTTPMethod, url: URL) {
    self.init(method: method, urlMatcher: url.matcher())
  }

  /// Initialize a request with method and `Matcher`
  ///
  /// - Parameter method: The `HTTPMethod` to match
  /// - Parameter  url: The `Matcher` to use for URLs
  public init(method: HTTPMethod, urlMatcher: Matcher) {
    self.method = method
    self.urlMatcher = urlMatcher
    self.headers = [:]
    self.response = StubResponse()
  }

  public func matchesRequest(_ request: HTTPRequest) -> Bool {
    return request.method == method && matchesUrl(request.url) && matchesHeaders(request.headers)
      && matchesBody(request.body)
  }

  private func matchesUrl(_ url: URL?) -> Bool {
    return urlMatcher.matches(string: url?.absoluteString)
  }

  private func matchesHeaders(_ headers: [String: String]?) -> Bool {
    guard let otherHeaders = headers else { return self.headers.isEmpty }
    for key in self.headers.keys {
      guard let value = otherHeaders[key] else { return false }
      if value != self.headers[key] {
        return false
      }
    }
    return true
  }

  private func matchesBody(_ body: Data?) -> Bool {
    guard let bodyMatcher = bodyMatcher, let body = body else { return true }
    return bodyMatcher.matches(data: body)
  }

  public mutating func setHeader(key: String, value: String) {
    headers[key] = value
  }

  public var hashValue: Int {
    let bodyHash: Int
    if let bodyMatcher = bodyMatcher {
      bodyHash = bodyMatcher.hashValue
    } else {
      bodyHash = 0
    }
    return method.hashValue ^ urlMatcher.hashValue ^ bodyHash ^ headers.count.hashValue
  }

  public static func ==(lhs: StubRequest, rhs: StubRequest) -> Bool {
    return lhs.method == rhs.method && lhs.urlMatcher == rhs.urlMatcher && lhs.headers == rhs.headers
      && lhs.bodyMatcher == rhs.bodyMatcher
  }

}
