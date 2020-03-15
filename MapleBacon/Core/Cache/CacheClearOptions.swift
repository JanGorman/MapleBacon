//
//  Copyright © 2020 Schnaub. All rights reserved.
//

import Foundation

public struct CacheClearOptions: OptionSet {
  public let rawValue: Int

  public init(rawValue: Int) {
    self.rawValue = rawValue
  }

  public static let memory = CacheClearOptions(rawValue: 1 << 0)
  public static let disk = CacheClearOptions(rawValue: 1 << 1)

  public static let all: CacheClearOptions = [.memory, .disk]
}
