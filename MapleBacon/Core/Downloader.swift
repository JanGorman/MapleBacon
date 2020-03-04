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
  private var downloads: [URL: Download<T>] = [:]

  init(sessionConfiguration: URLSessionConfiguration = .default) {
    self.sessionDelegate = SessionDelegate()
    self.session = URLSession(configuration: sessionConfiguration, delegate: sessionDelegate, delegateQueue: .main)
    self.sessionDelegate.downloader = self
  }

  func fetch(_ url: URL, completion: @escaping (Result<T.Result, Error>) -> Void) {
    let task: URLSessionDataTask
    if let download = download(for: url) {
      task = download.task
      download.completions.append(completion)
    } else {
      let newTask = session.dataTask(with: url)
      let download = Download<T>(task: newTask, completion: completion)
      download.start()
      addDownload(download, for: url)
      task = newTask
    }

    task.resume()
  }

  private func addDownload(_ download: Download<T>, for url: URL) {
    defer {
      lock.unlock()
    }
    lock.lock()
    downloads[url] = download
  }

  fileprivate func download(for url: URL) -> Download<T>? {
    defer {
      lock.unlock()
    }
    lock.lock()
    return downloads[url]
  }

  fileprivate func clearDownload(for url: URL) {
    defer {
      lock.unlock()
    }
    lock.lock()
    self.downloads[url] = nil
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
    guard let url = dataTask.originalRequest?.url, let download = downloader?.download(for: url) else {
      return
    }
    download.data.append(data)
  }

  func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
    guard let url = task.originalRequest?.url, let download = downloader?.download(for: url) else {
      return
    }

    downloader?.download(for: url)?.completions.forEach { completion in
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
    downloader?.clearDownload(for: url)
    download.finish()
  }

  func urlSession(_ session: URLSession, dataTask: URLSessionDataTask,
                  willCacheResponse proposedResponse: CachedURLResponse,
                  completionHandler: @escaping (CachedURLResponse?) -> Void) {
    completionHandler(nil)
  }

}
