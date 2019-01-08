//
//  Copyright © 2017 Jan Gorman. All rights reserved.
//

import UIKit

public typealias DownloadProgress = (_ received: Int64, _ total: Int64) -> Void
public typealias DownloadCompletion = (Data?) -> Void

private protocol DownloadStateDelegate: AnyObject {

  func progress(for url: URL) -> DownloadProgress?
  func completions(for url: URL) -> [DownloadCompletion]?
  func clearDownload(for url: URL?)
  func download(for url: URL) -> Download?

}

private final class Download {

  let task: URLSessionDataTask
  let progress: DownloadProgress?
  var completions: [DownloadCompletion]
  var data: Data
  private var backgroundTask: UIBackgroundTaskIdentifier = .invalid

  init(task: URLSessionDataTask, progress: DownloadProgress?, completion: @escaping DownloadCompletion,
       data: Data) {
    self.task = task
    self.progress = progress
    self.completions = [completion]
    self.data = data
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

/// The class responsible for downloading data. Access it through the `default` singleton.
public final class Downloader {

  /// The default `Downloader` singleton
  public static let `default` = Downloader()

  private let mutex: DispatchQueue
  private let sessionDelegate: SessionDelegate
  private let session: URLSession

  private var downloads: [URL: Download]

  public init(sessionConfiguration: URLSessionConfiguration = .default) {
    mutex = DispatchQueue(label: "com.schnaub.Downloader.mutex", attributes: .concurrent)
    sessionDelegate = SessionDelegate()
    session = URLSession(configuration: sessionConfiguration, delegate: sessionDelegate, delegateQueue: .main)
    downloads = [:]
  }

  /// Download an asset.
  ///
  /// - Parameters
  ///     - url: The URL to download from
  ///     - progress: An optional download progress closure
  ///     - completion: The completion closure called once the download is done
  public func download(_ url: URL, progress: DownloadProgress? = nil, completion: @escaping DownloadCompletion) {
    sessionDelegate.delegate = self

    mutex.sync(flags: .barrier) {
      let task: URLSessionDataTask
      if let download = downloads[url] {
        task = download.task
        download.completions.append(completion)
      } else {
        let newTask = session.dataTask(with: url)
        let download = Download(task: newTask, progress: progress, completion: completion, data: Data())
        download.start()
        downloads[url] = download
        task = newTask
      }

      task.resume()
    }
  }

}

extension Downloader: DownloadStateDelegate {

  fileprivate func progress(for url: URL) -> DownloadProgress? {
    return downloads[url]?.progress
  }

  fileprivate func completions(for url: URL) -> [DownloadCompletion]? {
    return downloads[url]?.completions
  }

  fileprivate func clearDownload(for url: URL?) {
    guard let url = url else { return }
    mutex.sync(flags: .barrier) {
      downloads[url] = nil
    }
  }

  fileprivate func download(for url: URL) -> Download? {
    var download: Download?
    mutex.sync(flags: .barrier) {
      download = downloads[url]
    }
    return download
  }

}

private class SessionDelegate: NSObject, URLSessionDataDelegate {

  weak var delegate: DownloadStateDelegate?

  func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
    guard let url = dataTask.originalRequest?.url,
          let download = delegate?.download(for: url),
          let total = dataTask.response?.expectedContentLength else { return }
    download.data.append(data)
    delegate?.progress(for: url)?(numericCast(download.data.count), total)
  }

  func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
    guard let requestUrl = task.originalRequest?.url,
          let download = delegate?.download(for: requestUrl) else { return }

    let data = error == nil ? download.data : nil
    delegate?.completions(for: requestUrl)?.forEach { completion in
      completion(data)
    }
    delegate?.clearDownload(for: requestUrl)
    download.finish()
  }

}
