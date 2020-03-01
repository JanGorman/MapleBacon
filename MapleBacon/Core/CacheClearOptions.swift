//
//  Copyright © 2020 Schnaub. All rights reserved.
//

import Foundation

struct CacheClearOptions: OptionSet {
  let rawValue: Int

  static let memory = CacheClearOptions(rawValue: 1 << 0)
  static let disk = CacheClearOptions(rawValue: 1 << 1)

  static let all: CacheClearOptions = [.memory, .disk]
}
