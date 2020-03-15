//
//  Copyright © 2020 Schnaub. All rights reserved.
//

import UIKit

/// A download task – this wraps the internal download instance and can be used to cancel an inflight request
public struct DownloadTask<T: DataConvertible> {

  let download: Download<T>

  public let cancelToken: CancelToken

  public func cancel() {
    download.cancel(cancelToken: cancelToken)
  }

}

final class Download<T: DataConvertible> {

  typealias Completion = (Result<T.Result, Error>) -> Void

  let task: URLSessionDataTask

  var completions: [Completion] {
    defer {
      lock.unlock()
    }
    lock.lock()
    return Array(tokenCompletions.values)
  }

  private let lock = NSLock()

  private(set) var data = Data()
  private var currentToken: CancelToken = 0
  private var backgroundTask: UIBackgroundTaskIdentifier = .invalid
  private var tokenCompletions: [CancelToken: Completion] = [:]

  init(task: URLSessionDataTask) {
    self.task = task
  }

  deinit {
    invalidateBackgroundTask()
  }

  func addCompletion(_ completion: @escaping Completion) -> CancelToken {
    defer {
      currentToken += 1
      lock.unlock()
    }
    lock.lock()
    tokenCompletions[currentToken] = completion
    return currentToken
  }

  func removeCompletion(for token: CancelToken) -> Completion? {
    defer {
      lock.unlock()
    }
    lock.lock()
    guard let completion = tokenCompletions[token] else {
      return nil
    }
    tokenCompletions[token] = nil
    return completion
  }

  func appendData(_ data: Data) {
    self.data.append(data)
  }

  func start() {
    backgroundTask = UIApplication.shared.beginBackgroundTask {
      self.invalidateBackgroundTask()
    }
  }

  func finish() {
    invalidateBackgroundTask()
  }

  func cancel(cancelToken: CancelToken) {
    guard let completion = removeCompletion(for: cancelToken) else {
      return
    }
    if tokenCompletions.isEmpty {
      task.cancel()
    }
    completion(.failure(DownloaderError.canceled))
  }

}

private extension Download {

  func invalidateBackgroundTask() {
    UIApplication.shared.endBackgroundTask(backgroundTask)
    backgroundTask = .invalid
  }

}
