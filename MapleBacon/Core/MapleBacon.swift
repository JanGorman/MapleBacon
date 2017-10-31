//
//  Copyright © 2017 Jan Gorman. All rights reserved.
//

import UIKit

public final class MapleBacon {
  
  /// The shared instance of MapleBacon
  public static let shared = MapleBacon()
  
  public let cache: Cache
  public let downloader: Downloader
  
  /// Initialize a new instance of MapleBacon.
  ///
  /// - Parameter cache: The cache to use. Uses the `default` instance if nothing is passed
  /// - Parameter downloader: The downloader to use. Users the `default` instance if nothing is passed
  public init(cache: Cache = .default, downloader: Downloader = .default) {
    self.cache = cache
    self.downloader = downloader
  }

  /// Download or retrieve an image from cache
  ///
  /// - Parameters:
  ///     - url: The URL to load an image from
  ///     - transformer: An optional transformer or transformer chain to apply to the image
  ///     - progress: An optional closure to track the download progress
  ///     - completion: The closure to call once the download is done
  public func image(with url: URL,
                    transformer: ImageTransformer? = nil,
                    progress: DownloadProgress?,
                    completion: @escaping DownloadCompletion) {
    let key = url.absoluteString
    cache.retrieveImage(forKey: key, transformerId: transformer?.identifier) { image, _ in
      guard let image = image else {
        self.downloader.download(url, progress: progress, completion: { [weak self] image in
          var finalImage = image
          defer {
            completion(finalImage)
          }
          guard let image = image else { return }

          if let transformer = transformer {
            finalImage = transformer.transform(image: image)
          }
          self?.cache.store(finalImage ?? image, forKey: url.absoluteString, transformerId: transformer?.identifier)
        })
        return
      }
      completion(image)
    }
  }

  
}
