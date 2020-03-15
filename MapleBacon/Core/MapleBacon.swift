//
//  Copyright © 2020 Schnaub. All rights reserved.
//

import UIKit

public enum MapleBaconError: Error {
  case imageTransformingError
}

public typealias CancelToken = Int

public final class MapleBacon {

  public typealias ImageCompletion = (Result<UIImage, Error>) -> Void

  /// The shared instance of MapleBacon
  public static let shared = MapleBacon()

  private static let queueLabel = "com.schnaub.MapleBacon.transformer"

  public var maxCacheAgeSeconds: TimeInterval {
    get {
      cache.maxCacheAgeSeconds
    }
    set {
      cache.maxCacheAgeSeconds = newValue
    }
  }

  private let cache: Cache<UIImage>
  private let downloader: Downloader<UIImage>
  private let transformerQueue: DispatchQueue

  /// Initialise a custom instance of MapleBacon
  /// - Parameters:
  ///   - name: The name to give this instance. Internally this reflects a distinct cache region.
  ///   - sessionConfiguration: The URLSessionConfiguration to use. Uses `.default` when no parameter is supplied.
  public convenience init(name: String = "", sessionConfiguration: URLSessionConfiguration = .default) {
    self.init(cache: Cache(name: name), sessionConfiguration: sessionConfiguration)
  }

  init(cache: Cache<UIImage>, sessionConfiguration: URLSessionConfiguration) {
    self.cache = cache
    self.downloader = Downloader(sessionConfiguration: sessionConfiguration)
    self.transformerQueue = DispatchQueue(label: Self.queueLabel, attributes: .concurrent)
  }

  /// Return an image for the passed URL. This will check the in-memory and disk cache and fetch the image over the network if nothing is in either cache yet.
  /// After a successful download, the image will be stored in both caches.
  /// - Parameters:
  ///   - url: The URL of the image
  ///   - imageTransformer: An optional image transformer
  ///   - completion: The completion to call with the image result
  /// - Returns: An optional `DownloadTask<UIImage>` if needs to fetch the image over the network. The task can be used to cancel an inflight request
  @discardableResult
  public func image(with url: URL, imageTransformer: ImageTransforming? = nil, completion: @escaping ImageCompletion) -> DownloadTask<UIImage>? {
    if (try? isCached(with: url, imageTransformer: imageTransformer)) == true {
      fetchImageFromCache(with: url, imageTransformer: imageTransformer, completion: completion)
      return nil
    }

    return fetchImageFromNetworkAndCache(with: url, imageTransformer: imageTransformer, completion: completion)
  }

  /// Hydrate the cache
  /// - Parameter url: The URL to fetch
  public func hydrateCache(url: URL) {
    if (try? isCached(with: url, imageTransformer: nil)) == false {
      _ = self.fetchImageFromNetworkAndCache(with: url, imageTransformer: nil, completion: { _ in })
    }
  }

  /// Hydrate the cache
  /// - Parameter urls: An array of URLs to fetch
  public func hydrateCache(urls: [URL]) {
    for url in urls {
      if (try? isCached(with: url, imageTransformer: nil)) == false {
        _ = self.fetchImageFromNetworkAndCache(with: url, imageTransformer: nil, completion: { _ in })
      }
    }
  }

  /// Clear the cache
  /// - Parameters:
  ///   - options: The `CacheClearOptions`. Clear either only memory, disk or both caches.
  ///   - completion: The completion to call after clearing the cache
  public func clearCache(_ options: CacheClearOptions, completion: ((Error?) -> Void)? = nil) {
    cache.clear(options, completion: completion)
  }

}

private extension MapleBacon {

  func isCached(with url: URL, imageTransformer: ImageTransforming?) throws -> Bool {
    let cacheKey = makeCacheKey(for: url, imageTransformer: imageTransformer)
    return try cache.isCached(forKey: cacheKey)
  }

  func fetchImageFromCache(with url: URL, imageTransformer: ImageTransforming?, completion: @escaping ImageCompletion) {
    let cacheKey = makeCacheKey(for: url, imageTransformer: imageTransformer)
    cache.value(forKey: cacheKey) { result in
      switch result {
      case .success(let cacheResult):
        DispatchQueue.main.optionalAsync {
          completion(.success(cacheResult.value))
        }
      case .failure(let error):
        DispatchQueue.main.optionalAsync {
          completion(.failure(error))
        }
      }
    }
  }

  func fetchImageFromNetworkAndCache(with url: URL, imageTransformer: ImageTransforming?, completion: @escaping ImageCompletion) -> DownloadTask<UIImage> {
    fetchImageFromNetwork(with: url) { result in
      switch result {
      case .success(let image):
        if let transformer = imageTransformer {
          let cacheKey = self.makeCacheKey(for: url, imageTransformer: transformer)
          self.transformImageAndCache(image, cacheKey: cacheKey, imageTransformer: transformer, completion: completion)
        } else {
          self.cache.store(value: image, forKey: url.absoluteString)
          DispatchQueue.main.optionalAsync {
            completion(.success(image))
          }
        }
      case .failure(let error):
        DispatchQueue.main.optionalAsync {
          completion(.failure(error))
        }
      }
    }
  }

  func fetchImageFromNetwork(with url: URL, completion: @escaping ImageCompletion) -> DownloadTask<UIImage> {
    downloader.fetch(url, completion: completion)
  }

  func transformImageAndCache(_ image: UIImage, cacheKey: String, imageTransformer: ImageTransforming, completion: @escaping ImageCompletion) {
    transformImage(image, imageTransformer: imageTransformer) { result in
      switch result {
      case .success(let image):
        self.cache.store(value: image, forKey: cacheKey)
        DispatchQueue.main.optionalAsync {
          completion(.success(image))
        }
      case .failure(let error):
        DispatchQueue.main.optionalAsync {
          completion(.failure(error))
        }
      }
    }
  }

  func transformImage(_ image: UIImage, imageTransformer: ImageTransforming, completion: @escaping ImageCompletion) {
    transformerQueue.async {
      guard let image = imageTransformer.transform(image: image) else {
        completion(.failure(MapleBaconError.imageTransformingError))
        return
      }
      completion(.success(image))
    }
  }

  func makeCacheKey(for url: URL, imageTransformer: ImageTransforming?) -> String {
    guard let imageTransformer = imageTransformer else {
      return url.absoluteString
    }
    return url.absoluteString + imageTransformer.identifier
  }
}

#if canImport(Combine)
import Combine

@available(iOS 13.0, *)
extension MapleBacon {

  /// The Combine way to fetch an image for the passed URL. This will check the in-memory and disk cache and fetch the image over the network if nothing is in either cache yet.
  /// After a successful download, the image will be stored in both caches.
  /// - Parameters:
  ///   - url: The URL of the image
  ///   - imageTransformer: An optional image transformer
  /// - Returns: `AnyPublisher<UIImage, Error>`
  public func image(with url: URL, imageTransformer: ImageTransforming? = nil) -> AnyPublisher<UIImage, Error> {
    Future { resolve in
      self.image(with: url, imageTransformer: imageTransformer) { result in
        switch result {
        case .success(let image):
          resolve(.success(image))
        case .failure(let error):
          resolve(.failure(error))
        }
      }
    }.eraseToAnyPublisher()
  }

}

#endif
