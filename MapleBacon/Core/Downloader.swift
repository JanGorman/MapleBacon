//
//  Copyright © 2020 Schnaub. All rights reserved.
//

import UIKit

enum DownloaderError: Error {
  case dataConversion
}

final class Downloader<T: DataConvertible> {

  let session: URLSession

  private let sessionDelegate: SessionDelegate<T>

  private let lock = NSLock()

  private var _downloads: Set<Download<T>> = []
  private var downloads: Set<Download<T>> {
    get {
      defer {
        lock.unlock()
      }
      lock.lock()
      return _downloads
    }
    set {
      defer {
        lock.unlock()
      }
      lock.lock()
      _downloads = newValue
    }
  }

  fileprivate subscript(url: URL) -> Download<T>? {
    get {
      downloads.first(where: { $0.url == url })
    }
    set {
      if let download = downloads.first(where: { $0.url == url }) {
        downloads.remove(download)
      }
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

  func fetch(_ url: URL, token: CancelToken, completion: @escaping (Result<T.Result, Error>) -> Void) {
    let task: URLSessionDataTask
    if let download = self[url] {
      task = download.task
      download.completions.append(completion)
    } else {
      let newTask = session.dataTask(with: url)
      let download = Download<T>(task: newTask, url: url, token: token, completion: completion)
      download.start()
      downloads.insert(download)
      task = newTask
    }

    task.resume()
  }

  func cancel(token: CancelToken) {
    guard let download = downloads.first(where: {$0.token == token }) else {
      return
    }
    if download.completions.isEmpty {
      download.task.cancel()
      downloads.remove(download)
    }
  }

}

private final class Download<T: DataConvertible>: Hashable {

  let task: URLSessionDataTask
  let url: URL
  let token: CancelToken

  var completions: [(Result<T.Result, Error>) -> Void]
  var data = Data()

  private var backgroundTask: UIBackgroundTaskIdentifier = .invalid

  init(task: URLSessionDataTask, url: URL, token: CancelToken, completion: @escaping (Result<T.Result, Error>) -> Void) {
    self.task = task
    self.url = url
    self.token = token
    self.completions = [completion]
  }

  deinit {
    invalidateBackgroundTask()
  }

  func start() {
    backgroundTask = UIApplication.shared.beginBackgroundTask {
      self.invalidateBackgroundTask()
    }
  }

  func finish() {
    invalidateBackgroundTask()
  }

  func hash(into hasher: inout Hasher) {
    hasher.combine(url)
    hasher.combine(token)
  }

  private func invalidateBackgroundTask() {
    UIApplication.shared.endBackgroundTask(backgroundTask)
    backgroundTask = .invalid
  }

  static func == (lhs: Download<T>, rhs: Download<T>) -> Bool {
    lhs.url == rhs.url && lhs.token == rhs.token
  }

}

private final class SessionDelegate<T: DataConvertible>: NSObject, URLSessionDataDelegate {

  weak var downloader: Downloader<T>?

  func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
    guard let url = dataTask.originalRequest?.url, let download = downloader?[url] else {
      return
    }
    download.data.append(data)
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
