//
//  Copyright © 2017 Jan Gorman. All rights reserved.
//

import Foundation

extension URL: Matcheable {

  public func matcher() -> Matcher {
    return StringMatcher(string: absoluteString)
  }

}
