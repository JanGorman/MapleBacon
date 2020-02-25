//
//  Copyright © 2020 Schnaub. All rights reserved.
//

import UIKit

private var baconImageUrlKey: UInt8 = 0

extension UIImageView {

  private var baconImageUrl: URL? {
    get {
      objc_getAssociatedObject(self, &baconImageUrlKey) as? URL
    }
    set {
      objc_setAssociatedObject(self, &baconImageUrlKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
  }

  public func setImage(with url: URL?) {
    baconImageUrl = url
    guard let url = url else {
      return
    }

    MapleBacon.shared.image(with: url) { [weak self] result in
      // TODO propagate the error?
      guard case let Result.success(image) = result, let self = self, url == self.baconImageUrl else {
        return
      }
      self.image = image
    }
  }

}
