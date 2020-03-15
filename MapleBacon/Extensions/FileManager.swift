//
//  Copyright © 2020 Schnaub. All rights reserved.
//

import Foundation

enum MapleBaconInputStreamError: Error {
  case uninitializedInputStream
  case emptyFile
}

extension FileManager {
  func fileContents(at url: URL) throws -> Data {
    guard let inputStream = InputStream(url: url) else {
      throw MapleBaconInputStreamError.uninitializedInputStream
    }
    let data = Data(from: inputStream)
    guard data.count > 0 else {
      throw MapleBaconInputStreamError.emptyFile
    }
    return data
  }
}
