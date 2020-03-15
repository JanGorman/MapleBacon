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

  /// Set remote image
  /// - Parameters:
  ///   - url: The URL of the image
  ///   - placeholder: An optional placeholder image to set while fetching the remote image
  ///   - displayOptions: `DisplayOptions`
  ///   - imageTransformer: An optional image transformer
  ///   - completion: An optional completion to call when the image is set
  /// - Returns: An optional `DownloadTask<UIImage>` if needs to fetch the image over the network. The task can be used to cancel an inflight request
  @discardableResult
  public func setImage(with url: URL?,
                       placeholder: UIImage? = nil,
                       displayOptions: [DisplayOptions] = [],
                       imageTransformer: ImageTransforming? = nil,
                       completion: ((UIImage?) -> Void)? = nil) -> DownloadTask<UIImage>? {
    cancelDownload()
    baconImageUrl = url
    image = placeholder
    guard let url = url else {
      return nil
    }

    let transformer = makeTransformer(displayOptions: displayOptions, imageTransformer: imageTransformer)

    let task = MapleBacon.shared.image(with: url, imageTransformer: transformer) { [weak self] result in
      var resultImage: UIImage?
      defer {
        self?.baconImageUrl = nil
        self?.downloadTask = nil
        completion?(resultImage)
      }
      guard case let Result.success(image) = result, let self = self, url == self.baconImageUrl else {
        return
      }
      resultImage = image
      self.image = image
    }
    downloadTask = task
    return task
  }

  /// Cancel a running download
  public func cancelDownload() {
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
