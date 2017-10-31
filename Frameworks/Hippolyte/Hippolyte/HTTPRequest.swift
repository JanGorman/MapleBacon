//
//  Copyright © 2017 Jan Gorman. All rights reserved.
//

import Foundation

public protocol HTTPRequest {

  var url: URL? { get }
  var method: HTTPMethod? { get }
  var headers: [String: String]?  { get }
  var body: Data? { get }

}

extension URLRequest: HTTPRequest {

  public var method: HTTPMethod? {
    guard let method = httpMethod else { return nil }
    return HTTPMethod(rawValue: method)
  }

  public var headers: [String : String]? {
    return allHTTPHeaderFields
  }

  public var body: Data? {
    guard let stream = httpBodyStream else { return httpBody }

    var data = Data()
    stream.open()
    let bufferSize = 4096
    let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: bufferSize)
    while stream.hasBytesAvailable {
      let read = stream.read(buffer, maxLength: bufferSize)
      data.append(buffer, count: read)
    }
    buffer.deallocate(capacity: bufferSize)
    stream.close()
    return data
  }

}
