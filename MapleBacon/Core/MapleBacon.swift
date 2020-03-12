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

  public convenience init(name: String = "", sessionConfiguration: URLSessionConfiguration = .default) {
    self.init(cache: Cache(name: name), sessionConfiguration: sessionConfiguration)
  }

  init(cache: Cache<UIImage>, sessionConfiguration: URLSessionConfiguration) {
    self.cache = cache
    self.downloader = Downloader(sessionConfiguration: sessionConfiguration)
    self.transformerQueue = DispatchQueue(label: Self.queueLabel, attributes: .concurrent)
  }

  @discardableResult
  public func image(with url: URL, imageTransformer: ImageTransforming? = nil, completion: @escaping ImageCompletion) -> DownloadTask<UIImage>? {
    if (try? isCached(with: url, imageTransformer: imageTransformer)) == true {
      fetchImageFromCache(with: url, imageTransformer: imageTransformer, completion: completion)
      return nil
    }

    return fetchImageFromNetworkAndCache(with: url, imageTransformer: imageTransformer, completion: completion)
  }

  public func hydrateCache(url: URL) {
    if (try? isCached(with: url, imageTransformer: nil)) == false {
      _ = self.fetchImageFromNetworkAndCache(with: url, imageTransformer: nil, completion: { _ in })
    }
  }

  public func hydrateCache(urls: [URL]) {
    for url in urls {
      if (try? isCached(with: url, imageTransformer: nil)) == false {
        _ = self.fetchImageFromNetworkAndCache(with: url, imageTransformer: nil, completion: { _ in })
      }
    }
  }

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
