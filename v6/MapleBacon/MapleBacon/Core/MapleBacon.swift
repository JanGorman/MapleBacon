//
//  Copyright © 2020 Schnaub. All rights reserved.
//

import UIKit

public struct MapleBacon {

  public typealias ImageCompletion = (Result<UIImage, Error>) -> Void

  public static let shared = MapleBacon()

  private let cache: Cache<UIImage>
  private let downloader: Downloader<UIImage>

  public init(name: String = "", sessionConfiguration: URLSessionConfiguration = .default) {
    self.cache = Cache(name: name)
    self.downloader = Downloader(sessionConfiguration: sessionConfiguration)
  }

  public func image(with url: URL, completion: @escaping ImageCompletion) {
    fetchImageFromCache(with: url) { result in
      switch result {
      case .success(let image):
        completion(.success(image))
      case .failure:
        self.fetchImageFromNetworkAndCache(with: url, completion: completion)
      }
    }
  }

  private func fetchImageFromCache(with url: URL, completion: @escaping ImageCompletion) {
    cache.value(forKey: url.absoluteString) { result in
      switch result {
      case .success(let cacheResult):
        completion(.success(cacheResult.value))
      case .failure(let error):
        completion(.failure(error))
      }
    }
  }

  private func fetchImageFromNetworkAndCache(with url: URL, completion: @escaping ImageCompletion) {
    fetchImageFromNetwork(with: url) { result in
      switch result {
      case .success(let image):
        self.cache.store(value: image, forKey: url.absoluteString)
        completion(.success(image))
      case .failure(let error):
        completion(.failure(error))
      }
    }
  }

  private func fetchImageFromNetwork(with url: URL, completion: @escaping ImageCompletion) {
    downloader.fetch(url) { result in
      switch result {
      case .success(let image):
        completion(.success(image))
      case .failure(let error):
        completion(.failure(error))
      }
    }
  }

}
