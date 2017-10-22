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
  
  public func image(with url: URL, progress: DownloadProgress?, completion: @escaping DownloadCompletion) {
    let key = url.absoluteString
    cache.retrieveImage(forKey: key) { image, _ in
      guard let image = image else {
        self.downloader.download(url, progress: progress, completion: { [weak self] image in
          defer {
            completion(image)
          }
          guard let image = image else { return }
          self?.cache.store(image, forKey: url.absoluteString)
        })
        return
      }
      completion(image)
    }
  }

  
}