//
//  Copyright © 2020 Schnaub. All rights reserved.
//

import Foundation

extension DispatchQueue {
  func optionalAsync(_ block: @escaping () -> Void) {
    if self === DispatchQueue.main && Thread.isMainThread {
      block()
    } else {
      async {
        block()
      }
    }
  }
}
