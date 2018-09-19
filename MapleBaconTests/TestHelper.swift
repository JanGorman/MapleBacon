//
//  Copyright © 2017 Jan Gorman. All rights reserved.
//

import UIKit

protocol CallCounting {

  var callCount: Int { get }

}

final class TestHelper {
  
  func testImage() -> UIImage {
    return UIImage(named: "MapleBacon", in: Bundle(for: type(of: self).self), compatibleWith: nil)!
  }
  
  func imageResponseData() -> Data {
    return testImage().pngData()!
  }
  
}
