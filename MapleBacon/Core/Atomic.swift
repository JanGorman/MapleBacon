//
//  Copyright © 2020 Schnaub. All rights reserved.
//

import Foundation

final class Atomic<Value> {

  var value: Value {
    get {
      queue.sync {
        self.wrappedValue
      }
    }
  }

  private let queue = DispatchQueue(label: "com.schnaub.MapleBacon.atomic")

  private var wrappedValue: Value

  init(_ value: Value) {
    self.wrappedValue = value
  }

  func mutate(_ transform: (inout Value) -> Void) {
    queue.sync {
      transform(&self.wrappedValue)
    }
  }

}
