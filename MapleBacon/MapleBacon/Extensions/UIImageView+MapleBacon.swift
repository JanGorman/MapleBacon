//
//  Copyright © 2017 Jan Gorman. All rights reserved.
//

import UIKit

extension UIImageView {
  
  /// Set image on self from a URL
  ///
  /// - Parameters:
  ///     - url: The URL to load an image from
  ///     - placeholder: An optional placeholder image to set while loading
  ///     - transformer: An optional transformer or transformer chain to apply to the image
  ///     - progress: An optional closure to track the download progress
  ///     - completion: An optional closure to call once the download is done
  public func setImage(with url: URL?,
                       placeholder: UIImage? = nil,
                       transformer: ImageTransformer? = nil,
                       progress: DownloadProgress? = nil,
                       completion: DownloadCompletion? = nil) {
    image = placeholder
    guard let url = url else {
      completion?(nil)
      return
    }

    MapleBacon.shared.image(with: url, transformer: transformer, progress: progress) { [weak self] image in
      self?.image = image
      completion?(image)
    }
  }
  
}
