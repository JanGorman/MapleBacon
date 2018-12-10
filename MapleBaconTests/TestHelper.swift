//
//  Copyright © 2017 Jan Gorman. All rights reserved.
//

import UIKit

protocol CallCounting {

  var callCount: Int { get }

}

final class TestHelper {

  var image: UIImage {
    return UIImage(named: "MapleBacon", in: Bundle(for: type(of: self).self), compatibleWith: nil)!
  }

  func imageResponseData() -> Data {
    return image.pngData()!
  }
  
}

extension String {
  
  func deletingPrefix(_ prefix: String) -> String {
    guard hasPrefix(prefix) else {
      return self
    }
    return String(dropFirst(prefix.count))
  }
  
}
