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
                       completion: ImageDownloadCompletion? = nil) {
    baconImageUrl = url
    image = placeholder
    guard let url = url else {
      completion?(nil)
      return
    }

    MapleBacon.shared.image(with: url, transformer: transformer, progress: progress) { [weak self] image in
      guard let self = self, self.baconImageUrl == url else {
        return
      }
      let size = self.frame.size
      DispatchQueue.global(qos: .userInitiated).async {
        let scaledImage = self.resizedImage(from: image, for: size)
        DispatchQueue.main.async {
          UIView.transition(with: self,
                            duration: 0.3,
                            options: [.curveEaseOut, .transitionCrossDissolve],
                            animations: {
                              self.image = scaledImage
                            }, completion: { _ in
                              completion?(image)
                            })
        }
      }
    }
  }

  private func resizedImage(from image: UIImage?, for size: CGSize) -> UIImage? {
    guard let image = image else {
      return nil
    }
    let renderer = UIGraphicsImageRenderer(size: size)
    return renderer.image { _ in
      image.draw(in: CGRect(origin: .zero, size: size))
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
