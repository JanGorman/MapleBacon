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

  public func setImage(with url: URL?,
                       placeholder: UIImage? = nil,
                       displayOptions: [DisplayOptions] = [],
                       imageTransformer: ImageTransforming? = nil) {
    baconImageUrl = url
    guard let url = url else {
      return
    }

    if let placeholder = placeholder {
      image = placeholder
    }

    let transformer = makeTransformer(displayOptions: displayOptions, imageTransformer: imageTransformer)

    MapleBacon.shared.image(with: url, imageTransformer: transformer) { [weak self] result in
      guard case let Result.success(image) = result, let self = self, url == self.baconImageUrl else {
        return
      }
      self.image = image
    }
  }

  private func makeTransformer(displayOptions: [DisplayOptions] = [], imageTransformer: ImageTransforming?) -> ImageTransforming? {
    guard displayOptions.contains(.downsampled) else {
      return imageTransformer
    }

    let downsampler = DownsamplingImageTransformer(size: bounds.size)
    if let imageTransformer = imageTransformer {
      return downsampler >>> imageTransformer
    }
    return downsampler
  }

}
