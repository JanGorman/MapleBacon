//
//  Copyright © 2017 Jan Gorman. All rights reserved.
//

import UIKit

public enum MapleBaconError: Error {
  case imageDecodingError
}

public typealias ImageDownloadCompletion = (UIImage?) -> Void
public typealias DataDownloadCompletion = (Data?) -> Void

public final class MapleBacon {

  /// The shared instance of MapleBacon
  public static let shared = MapleBacon()
  
  public let cache: MapleBaconCache
  public let downloader: Downloader
  
  /// Initialize a new instance of MapleBacon.
  ///
  /// - Parameter cache: The cache to use. Uses the `default` instance if nothing is passed
  /// - Parameter downloader: The downloader to use. Users the `default` instance if nothing is passed
  public init(cache: MapleBaconCache = .default, downloader: Downloader = .default) {
    self.cache = cache
    self.downloader = downloader
  }

  /// Download or retrieve an image from cache
  ///
  /// - Parameters:
  ///     - url: The URL to load an image from
  ///     - transformer: An optional transformer or transformer chain to apply to the image
  ///     - progress: An optional closure to track the download progress
  ///     - completion: The closure to call once the download is done. The completion is called on a background thread
  public func image(with url: URL,
                    transformer: ImageTransformer? = nil,
                    progress: DownloadProgress? = nil,
                    completion: @escaping ImageDownloadCompletion) {
    fetchImage(with: url, transformer: transformer, progress: progress, completion: completion)
  }

  /// Download or retrieve an data from cache
  ///
  /// - Parameters:
  ///     - url: The URL to load (image) data from
  ///     - progress: An optional closure to track the download progress
  ///     - completion: The closure to call once the download is done. The completion is called on a background thread
  public func data(with url: URL,
                   progress: DownloadProgress? = nil,
                   completion: @escaping DataDownloadCompletion) {
    fetchData(with: url, transformer: nil, progress: progress) { data, _ in
      completion(data)
    }
  }

  private func fetchImage(with url: URL,
                          transformer: ImageTransformer?,
                          progress: DownloadProgress?,
                          completion: ImageDownloadCompletion?) {
    fetchData(with: url, transformer: transformer, progress: progress) { [weak self] data, cacheType in
      guard let self = self, let data = data, let image = UIImage(data: data) else {
        completion?(nil)
        return
      }

      if cacheType == .none, let transformer = transformer {
        DispatchQueue.global(qos: .userInitiated).async {
          let transformedImage = transformer.transform(image: image)
          let cacheData = transformedImage?.pngData()
          self.cache.store(data: cacheData, forKey: url.absoluteString, transformerId: transformer.identifier)
          completion?(transformedImage)
        }
      } else {
        completion?(image)
      }
    }
  }

  private func fetchData(with url: URL,
                         transformer: ImageTransformer?,
                         progress: DownloadProgress?,
                         completion: ((Data?, CacheType) -> Void)?) {
    let key = url.absoluteString
    cache.retrieveData(forKey: key, transformerId: transformer?.identifier) { [weak self] data, cacheType in
      guard let data = data else {
        self?.downloader.download(url, progress: progress, completion: { data in
          guard let self = self, let data = data else {
            completion?(nil, cacheType)
            return
          }
          // Only store in cache when there is no transformation step that will follow or we'd be caching twice
          if transformer?.identifier == nil {
            self.cache.store(data: data, forKey: url.absoluteString)
          }
          completion?(data, cacheType)
        })
        return
      }
      completion?(data, cacheType)
    }
  }

  /// Pre-warms the image cache. Downloads the image if needed or loads it into memory.
  ///
  /// - Parameter url: The URL to load an image from
  public func preWarmCache(for url: URL) {
    fetchImage(with: url, transformer: nil, progress: nil, completion: nil)
  }
  
}
