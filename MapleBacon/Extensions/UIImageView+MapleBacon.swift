//
//  Copyright © 2020 Schnaub. All rights reserved.
//

import UIKit

private var baconImageUrlKey: UInt8 = 0
private var downloadKey: UInt8 = 1

extension UIImageView {

  private var baconImageUrl: URL? {
    get {
      objc_getAssociatedObject(self, &baconImageUrlKey) as? URL
    }
    set {
      objc_setAssociatedObject(self, &baconImageUrlKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
  }

  private var downloadTask: DownloadTask<UIImage>? {
    get {
      objc_getAssociatedObject(self, &downloadKey) as? DownloadTask<UIImage>
    }
    set {
      objc_setAssociatedObject(self, &downloadKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
  }

  public func setImage(with url: URL?,
                       placeholder: UIImage? = nil,
                       displayOptions: [DisplayOptions] = [],
                       imageTransformer: ImageTransforming? = nil,
                       completion: (() -> Void)? = nil) {
    cancelDownload()
    baconImageUrl = url
    image = placeholder
    guard let url = url else {
      return
    }

    let transformer = makeTransformer(displayOptions: displayOptions, imageTransformer: imageTransformer)

    let task = MapleBacon.shared.image(with: url, imageTransformer: transformer) { [weak self] result in
      defer {
        self?.baconImageUrl = nil
        self?.downloadTask = nil
        completion?()
      }
      guard case let Result.success(image) = result, let self = self, url == self.baconImageUrl else {
        return
      }
      self.image = image
    }
    downloadTask = task
  }

  private func cancelDownload() {
    downloadTask?.cancel()
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
