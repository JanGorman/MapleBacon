//
//  Copyright © 2020 Schnaub. All rights reserved.
//

import UIKit

enum DownloaderError: Error {
  case dataConversion
  case canceled
}

final class Downloader<T: DataConvertible> {

  let session: URLSession

  private let sessionDelegate: SessionDelegate<T>
  private let lock = NSLock()

  private var downloads: [URL: Download<T>] = [:]

  fileprivate subscript(_ url: URL) -> Download<T>? {
    get {
      defer {
        lock.unlock()
      }
      lock.lock()
      return downloads[url]
    }
    set {
      defer {
        lock.unlock()
      }
      lock.lock()
      downloads[url] = newValue
    }
  }

  init(sessionConfiguration: URLSessionConfiguration = .default) {
    self.sessionDelegate = SessionDelegate()
    self.session = URLSession(configuration: sessionConfiguration, delegate: sessionDelegate, delegateQueue: .main)
    self.sessionDelegate.downloader = self
  }

  deinit {
    session.invalidateAndCancel()
  }

  func fetch(_ url: URL, completion: @escaping (Result<T.Result, Error>) -> Void) -> DownloadTask<T> {
    if let download = self[url] {
      let token = download.addCompletion(completion)
      return DownloadTask(download: download, cancelToken: token)
    }

    let task = session.dataTask(with: url)
    let download = Download<T>(task: task)
    let token = download.addCompletion(completion)
    download.start()
    self[url] = download
    task.resume()

    return DownloadTask(download: download, cancelToken: token)
  }

}

private final class SessionDelegate<T: DataConvertible>: NSObject, URLSessionDataDelegate {

  weak var downloader: Downloader<T>?

  func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
    guard let url = dataTask.originalRequest?.url, let download = downloader?[url] else {
      return
    }
    download.appendData(data)
  }

  func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
    guard let url = task.originalRequest?.url, let download = downloader?[url] else {
      return
    }

    downloader?[url]?.completions.forEach { completion in
      if let error = error {
        completion(.failure(error))
        return
      }
      guard let value = T.convert(from: download.data) else {
        completion(.failure(DownloaderError.dataConversion))
        return
      }
      completion(.success(value))
    }
    downloader?[url] = nil
    download.finish()
  }

  func urlSession(_ session: URLSession, dataTask: URLSessionDataTask,
                  willCacheResponse proposedResponse: CachedURLResponse,
                  completionHandler: @escaping (CachedURLResponse?) -> Void) {
    completionHandler(nil)
  }

}

