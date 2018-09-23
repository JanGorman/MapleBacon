//
//  Copyright © 2017 Jan Gorman. All rights reserved.
//

import UIKit

extension UIButton {
  
  /// Set an image from the provided URL
  ///
  /// - Parameters:
  ///     - url: The URL to load an image from
  ///     - state: The `UIControlState` for which this image should be set
  ///     - placeholder: An optional placeholder image to set while loading
  ///     - transformer: An optional transformer or transformer chain to apply to the image
  ///     - progress: An optional closure to track the download progress
  ///     - completion: An optional closure to call once the download is done
  public func setImage(with url: URL?,
                       for state: UIControl.State,
                       placeholder: UIImage? = nil,
                       transformer: ImageTransformer? = nil,
                       progress: DownloadProgress? = nil,
                       completion: ImageDownloadCompletion? = nil) {
    setImage(placeholder, for: state)
    guard let url = url else {
      completion?(nil)
      return
    }
    
    MapleBacon.shared.image(with: url, transformer: transformer, progress: progress) { [weak self] image in
      guard self?.baconImageUrl != url else { return }
      self?.setImage(image, for: state)
      completion?(image)
    }
  }

  private var baconImageUrl: URL? {
    get {
      return objc_getAssociatedObject(self, &baconImageUrlKey) as? URL
    }
    set {
      objc_setAssociatedObject(self, &baconImageUrlKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
  }
  
}

private var baconImageUrlKey: UInt8 = 0
