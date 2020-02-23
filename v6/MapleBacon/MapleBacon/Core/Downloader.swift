//
//  Copyright © 2020 Schnaub. All rights reserved.
//

import Foundation

enum DownloaderError: Error {
  case dataConversion
}

final class Downloader<T: DataConvertible> {

  let session: URLSession

  var task: URLSessionDataTask?

  init(sessionConfiguration: URLSessionConfiguration = .default) {
    self.session = URLSession(configuration: sessionConfiguration)
  }

  func fetch(_ url: URL, completion: @escaping (Result<T.Result, Error>) -> Void) {
    let task = session.dataTask(with: url) { data, _, error in
      if let error = error {
        DispatchQueue.main.async {
          completion(.failure(error))
        }
        return
      }
      guard let data = data, let value = T.convert(from: data) else {
        DispatchQueue.main.async {
          completion(.failure(DownloaderError.dataConversion))
        }
        return
      }
      DispatchQueue.main.async {
        completion(.success(value))
      }
    }
    defer {
      task.resume()
    }
    self.task = task
  }

}
