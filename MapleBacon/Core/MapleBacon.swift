//
//  Copyright © 2017 Jan Gorman. All rights reserved.
//

import Combine
import UIKit

public enum MapleBaconError: Error {
  case imageDecodingError
}

public typealias ImageDownloadCompletion = (UIImage?) -> Void

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
                    progress: DownloadProgress? = nil,
                    completion: @escaping ImageDownloadCompletion) {
    return fetchImage(with: url, transformer: transformer, progress: progress, completion: completion)
  }

  /// Download or retrieve an image from cache
  /// - Parameter url: The URL to load an image from
  /// - Parameter transformer: An optional transformer or transformer chain to apply to the image
  /// - Parameter progress: An optional closure to track the download progress
  /// - Returns: A Publisher of type `AnyPublisher<UIImage?, Never>`
  @available(iOS 13.0, *)
  public func image(with url: URL,
                    transformer: ImageTransformer? = nil,
                    progress: DownloadProgress? = nil) -> AnyPublisher<UIImage?, Never> {
    return fetchImage(with: url, transfomer: transformer, progress: progress)
  }

  private func fetchImage(with url: URL,
                          transformer: ImageTransformer?,
                          progress: DownloadProgress?,
                          completion: ImageDownloadCompletion?) {
    let key = url.absoluteString
    cache.retrieveImage(forKey: key, transformerId: transformer?.identifier) { [weak self] image, _ in
      guard let image = image else {
        self?.downloader.download(url, progress: progress, completion: { data in
          guard let self = self, let data = data, let image = UIImage(data: data) else {
            completion?(nil)
            return
          }

          let transformedImage = transformer?.transform(image: image)
          let finalImage = transformedImage ?? image
          let finalData = transformedImage == nil ? data : nil

          self.cache.store(finalImage, data: finalData, forKey: url.absoluteString, transformerId: transformer?.identifier)
          completion?(finalImage)
        })
        return
      }
      completion?(image)
    }
  }

  @available(iOS 13.0, *)
  private func fetchImage(with url: URL, transfomer: ImageTransformer?, progress: DownloadProgress?) -> AnyPublisher<UIImage?, Never> {
    return Future { resolver in
      self.fetchImage(with: url, transformer: transfomer, progress: progress) { image in
        resolver(.success(image))
      }
    }
    .eraseToAnyPublisher()
  }

  /// Pre-warms the image cache. Downloads the image if needed or loads it into memory.
  ///
  /// - Parameter url: The URL to load an image from
  public func preWarmCache(for url: URL) {
    fetchImage(with: url, transformer: nil, progress: nil, completion: nil)
  }
  
}
