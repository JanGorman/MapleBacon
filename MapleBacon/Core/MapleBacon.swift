//
//  Copyright © 2017 Jan Gorman. All rights reserved.
//

import UIKit

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
  /// - Returns: An optional download token `UUID` – if the image can be fetched from cache there won't be a token
  @discardableResult
  public func image(with url: URL,
                    transformer: ImageTransformer? = nil,
                    progress: DownloadProgress? = nil,
                    completion: @escaping ImageDownloadCompletion) -> UUID? {
    return fetchImage(with: url, transformer: transformer, progress: progress, completion: completion)
  }

  /// Download or retrieve an data from cache
  ///
  /// - Parameters:
  ///     - url: The URL to load (image) data from
  ///     - progress: An optional closure to track the download progress
  ///     - completion: The closure to call once the download is done. The completion is called on a background thread
  /// - Returns: An optional download token `UUID` – if the data can be fetched from cache there won't be a token
  @discardableResult
  public func data(with url: URL,
                   progress: DownloadProgress? = nil,
                   completion: @escaping DataDownloadCompletion) -> UUID? {
    return fetchData(with: url, transformer: nil, progress: progress) { data, _ in
      completion(data)
    }
  }

  /// Pre-warms the image cache. Downloads the image if needed or loads it into memory.
  ///
  /// - Parameter url: The URL to load an image from
  public func preWarmCache(for url: URL) {
    _ = fetchImage(with: url, transformer: nil, progress: nil, completion: nil)
  }

  /// Cancel a running download
  ///
  /// - Parameter token: The token identifier of the the download
  public func cancelDownload(withToken token: UUID) {
    downloader.cancel(withToken: token)
  }

  private func fetchImage(with url: URL,
                          transformer: ImageTransformer?,
                          progress: DownloadProgress?,
                          completion: ImageDownloadCompletion?) -> UUID? {
    return fetchData(with: url, transformer: transformer, progress: progress) { [weak self] data, cacheType in
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
                         completion: ((Data?, CacheType) -> Void)?) -> UUID? {
    let key = url.absoluteString
    var token: UUID?
    cache.retrieveData(forKey: key, transformerId: transformer?.identifier) { [weak self] data, cacheType in
      guard let data = data else {
        let downloadToken = self?.downloader.download(url, progress: progress, completion: { data in
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
        token = downloadToken
        return
      }
      completion?(data, cacheType)
    }
    return token
  }

}

#if canImport(Combine)
import Combine

@available(iOS 13.0, *)
extension MapleBacon {

  public func image(with url: URL, transformer: ImageTransformer? = nil) -> AnyPublisher<UIImage?, Never> {
    Future { resolve in
      _ = self.fetchImage(with: url, transformer: transformer, progress: nil) { image in
        resolve(.success(image))
      }
    }.eraseToAnyPublisher()
  }


}

#endif
