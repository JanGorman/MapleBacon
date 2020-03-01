//
//  Copyright © 2020 Schnaub. All rights reserved.
//

import UIKit

public final class DownsamplingImageTransformer: ImageTransforming {

  public var identifier: String {
    "com.schnaub.DownsamplingImageTransformer@\(targetSize)"
  }

  private let targetSize: CGSize

  init(size: CGSize) {
    targetSize = size * UIScreen.main.scale
  }

  public func transform(image: UIImage) -> UIImage? {
    let imageSourceOptions = [kCGImageSourceShouldCache: false] as CFDictionary
    guard let data = image.pngData(), let imageSource = CGImageSourceCreateWithData(data as CFData, imageSourceOptions) else {
      return image
    }

    let maxDimensionInPixels = max(targetSize.width, targetSize.height)
    let downsampleOptions = [kCGImageSourceCreateThumbnailFromImageAlways: true,
                             kCGImageSourceShouldCacheImmediately: true,
                             kCGImageSourceCreateThumbnailWithTransform: true,
                             kCGImageSourceThumbnailMaxPixelSize: maxDimensionInPixels] as CFDictionary

    guard let downsampledImage = CGImageSourceCreateThumbnailAtIndex(imageSource, 0, downsampleOptions) else {
      return image
    }
    return UIImage(cgImage: downsampledImage)
  }

}
