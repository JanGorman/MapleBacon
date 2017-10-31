//
//  Copyright © 2017 Jan Gorman. All rights reserved.
//

import Foundation

public protocol HTTPClientHook {

  func load()
  func unload()
  func isEqual(to other: HTTPClientHook) -> Bool

}

extension HTTPClientHook where Self: Equatable {

  func isEqual(to other: HTTPClientHook) -> Bool {
    if let o = other as? Self {
      return o == self
    }
    return false
  }

}

func ==(lhs: HTTPClientHook, rhs: HTTPClientHook) -> Bool {
  return lhs.isEqual(to: rhs)
}
