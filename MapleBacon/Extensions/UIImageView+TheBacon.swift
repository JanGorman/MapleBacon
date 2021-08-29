//
//  Copyright © 2021 Schnaub. All rights reserved.
//

import UIKit

private var theBaconImageUrlKey: UInt8 = 2

extension UIImageView {

  private var baconImageUrl: URL? {
    get {
      objc_getAssociatedObject(self, &theBaconImageUrlKey) as? URL
    }
    set {
      objc_setAssociatedObject(self, &theBaconImageUrlKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
  }

  @MainActor
  public func setImage(from url: URL, scalingOption: TheBacon.ScalingOption = .none) async {
    self.image = try? await TheBacon.shared.image(from: url, scalingOption: scalingOption)
  }

}
