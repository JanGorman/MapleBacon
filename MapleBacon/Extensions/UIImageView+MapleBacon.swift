//
//  Copyright © 2017 Jan Gorman. All rights reserved.
//

import UIKit

public struct DisplayOptions: OptionSet {

  public let rawValue: Int

  public init(rawValue: Int) {
    self.rawValue = rawValue
  }

  /// Scale the raw image to the target size
  public static let scaled = DisplayOptions(rawValue: 1 << 0)
  /// Display the image with a transition instead of just setting the new image
  public static let withTransition = DisplayOptions(rawValue: 1 << 1)
}

extension UIImageView {
  
  /// Set image on self from a URL
  ///
  /// - Parameters:
  ///     - url: The URL to load an image from
  ///     - placeholder: An optional placeholder image to set while loading
  ///     - displayOptions: `DisplayOptions`
  ///     - transformer: An optional transformer or transformer chain to apply to the image
  ///     - progress: An optional closure to track the download progress
  ///     - completion: An optional closure to call once the download is done
  /// - Returns: An optional download token `UUID`
  @discardableResult
  public func setImage(with url: URL?,
                       placeholder: UIImage? = nil,
                       displayOptions: DisplayOptions = [],
                       transformer: ImageTransformer? = nil,
                       progress: DownloadProgress? = nil,
                       completion: ImageDownloadCompletion? = nil) -> UUID? {
    baconImageUrl = url
    image = placeholder
    guard let url = url else {
      completion?(nil)
      return nil
    }

    return MapleBacon.shared.image(with: url, transformer: transformer, progress: progress) { [weak self] image in
      guard let self = self, self.baconImageUrl == url else {
        return
      }
      self.setImage(image, displayOptions: displayOptions, completion: completion)
    }
  }

  private func setImage(_ image: UIImage?, displayOptions: DisplayOptions, completion: ImageDownloadCompletion?) {
    if displayOptions.contains(.scaled) {
      let size = self.frame.size

      DispatchQueue.global(qos: .userInitiated).async {
        let scaledImage = resizedImage(from: image, for: size)
        DispatchQueue.main.async {
          if displayOptions.contains(.withTransition) {
            self.setImageWithTransition(scaledImage, completion: completion)
          } else {
            self.image = scaledImage
            completion?(scaledImage)
          }
        }
      }
    } else {
      if displayOptions.contains(.withTransition) {
        setImageWithTransition(image, completion: completion)
      } else {
        self.image = image
        completion?(image)
      }
    }
  }

  private func setImageWithTransition(_ image: UIImage?, completion: ImageDownloadCompletion?) {
    UIView.transition(with: self,
                      duration: 0.3,
                      options: [.curveEaseOut, .transitionCrossDissolve],
                      animations: {
                        self.image = image
                      }, completion: { _ in
                        completion?(image)
                      })
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
