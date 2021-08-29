//
//  Copyright © 2021 Schnaub. All rights reserved.
//

import Foundation
import UIKit

public enum ImageDownloaderError: Error {
  case invalidImageData
}

actor ImageDownloader {

  private enum CacheEntry {
    case inProgress(Task<UIImage, Error>)
    case ready(UIImage)
  }

  private var cache: [URL: CacheEntry] = [:]
  private var urlSession: URLSession

  init(sessionConfiguration: URLSessionConfiguration) {
    urlSession = URLSession(configuration: sessionConfiguration)
  }

  func image(from url: URL) async throws -> UIImage {
    if let cached = cache[url] {
      switch cached {
      case let .ready(image):
        return image
      case let .inProgress(task):
        return try await task.value
      }
    }

    let task = Task {
      try await downloadImage(from: url)
    }
    cache[url] = .inProgress(task)

    do {
      let image = try await task.value
      cache[url] = .ready(image)
      return image
    } catch {
      cache[url] = nil
      throw error
    }
  }

  private func downloadImage(from url: URL) async throws -> UIImage {
    let (data, _) = try await urlSession.data(from: url)

    guard let image = UIImage(data: data) else {
      throw ImageDownloaderError.invalidImageData
    }
    return image
  }

}
