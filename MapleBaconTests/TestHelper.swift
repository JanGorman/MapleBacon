//
//  Copyright © 2017 Jan Gorman. All rights reserved.
//

import UIKit

protocol CallCounting {

  var callCount: Int { get }

}

struct TestHelper {

  var image: UIImage {
    let renderer = UIGraphicsImageRenderer(size: .init(width: 10, height: 10))
    return renderer.image { context in
      UIColor.black.setFill()
      context.fill(renderer.format.bounds)
    }
  }

  var imageData: Data {
    image.pngData()!
  }
  
}

extension String {
  
  func deletingPrefix(_ prefix: String) -> String {
    String(dropFirst(prefix.count))
  }
  
}

extension URL: ExpressibleByStringLiteral {

  public init(extendedGraphemeClusterLiteral value: String) {
    self = URL(string: value)!
  }

  public init(stringLiteral value: String) {
    self = URL(string: value)!
  }

}
