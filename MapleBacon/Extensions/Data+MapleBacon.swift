//
//  Copyright © 2020 Schnaub. All rights reserved.
//

import Foundation

extension Data {

  init(from inputStream: InputStream) {
    self.init()

    defer {
      inputStream.close()
    }
    inputStream.open()

    let bufferSize = 1024
    let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: bufferSize)
    while inputStream.hasBytesAvailable {
      let read = inputStream.read(buffer, maxLength: bufferSize)
      append(buffer, count: read)
    }
    buffer.deallocate()
  }

}
