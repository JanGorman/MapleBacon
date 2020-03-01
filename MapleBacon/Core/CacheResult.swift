//
//  Copyright © 2020 Schnaub. All rights reserved.
//

import Foundation

struct CacheResult<Value> {
  let value: Value
  let type: CacheType
}

enum CacheType {
  case memory, disk
}
