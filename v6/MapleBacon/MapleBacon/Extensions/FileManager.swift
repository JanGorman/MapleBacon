//
//  Copyright © 2020 Schnaub. All rights reserved.
//

import Foundation

extension FileManager {
  func fileContents(at url: URL) throws -> Data {
    try Data(contentsOf: url, options: .mappedIfSafe)
  }
}
