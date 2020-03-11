//
//  Copyright © 2020 Schnaub. All rights reserved.
//

import UIKit

public final class Download<T: DataConvertible> {

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

  private func invalidateBackgroundTask() {
    UIApplication.shared.endBackgroundTask(backgroundTask)
    backgroundTask = .invalid
  }

}
