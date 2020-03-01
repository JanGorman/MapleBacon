//
//  Copyright © 2020 Schnaub. All rights reserved.
//

import Foundation

public struct DisplayOptions: OptionSet {

  public let rawValue: Int

  public init(rawValue: Int) {
    self.rawValue = rawValue
  }

  /// Scale the raw image to the target size
  public static let downsampled = DisplayOptions(rawValue: 1 << 0)

}
