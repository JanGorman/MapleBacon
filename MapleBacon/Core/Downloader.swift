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

  private var _downloads: [URL: Download<T>] = [:]
  fileprivate var downloads: [URL: Download<T>] {
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

  init(sessionConfiguration: URLSessionConfiguration = .default) {
    self.sessionDelegate = SessionDelegate()
    self.session = URLSession(configuration: sessionConfiguration, delegate: sessionDelegate, delegateQueue: .main)
    self.sessionDelegate.downloader = self
  }

  func fetch(_ url: URL, completion: @escaping (Result<T.Result, Error>) -> Void) {
    let task: URLSessionDataTask
    if let download = downloads[url] {
      task = download.task
      download.completions.append(completion)
    } else {
      let newTask = session.dataTask(with: url)
      let download = Download<T>(task: newTask, completion: completion)
      download.start()
      downloads[url] = download
      task = newTask
    }

    task.resume()
  }

}

private final class Download<T: DataConvertible> {

  let task: URLSessionDataTask

  var completions: [(Result<T.Result, Error>) -> Void]
  var data = Data()

  private var backgroundTask: UIBackgroundTaskIdentifier = .invalid

  init(task: URLSessionDataTask, completion: @escaping (Result<T.Result, Error>) -> Void) {
    self.task = task
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

  private func invalidateBackgroundTask() {
    UIApplication.shared.endBackgroundTask(backgroundTask)
    backgroundTask = .invalid
  }
}

private final class SessionDelegate<T: DataConvertible>: NSObject, URLSessionDataDelegate {

  weak var downloader: Downloader<T>?

  func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
    guard let url = dataTask.originalRequest?.url, let download = downloader?.downloads[url] else {
      return
    }
    download.data.append(data)
  }

  func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
    guard let url = task.originalRequest?.url, let download = downloader?.downloads[url] else {
      return
    }

    downloader?.downloads[url]?.completions.forEach { completion in
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
    downloader?.downloads[url] = nil
    download.finish()
  }

  func urlSession(_ session: URLSession, dataTask: URLSessionDataTask,
                  willCacheResponse proposedResponse: CachedURLResponse,
                  completionHandler: @escaping (CachedURLResponse?) -> Void) {
    completionHandler(nil)
  }

}
