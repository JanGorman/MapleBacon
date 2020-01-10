//
//  Copyright © 2017 Jan Gorman. All rights reserved.
//

import UIKit

public enum MapleBaconDownloadError: Error {
  case invalidServerResponse
}

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
  let token: UUID
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
    self.token = UUID()
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

  private static let queueLabel = "com.schnaub.MapleBacon.Download"

  /// The default `Downloader` singleton
  public static let `default` = Downloader()

  private let mutex: DispatchQueue
  private let sessionDelegate: SessionDelegate
  private let session: URLSession

  private var downloads: [URL: Download]

  private lazy var downloadQueue = DispatchQueue(label: Self.queueLabel, qos: .default, attributes: .concurrent)

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
  /// - Returns: A download token `UUID`
  public func download(_ url: URL, progress: DownloadProgress? = nil, completion: @escaping DownloadCompletion) -> UUID {
    sessionDelegate.delegate = self

    var token: UUID!
    mutex.sync(flags: .barrier) {
      let task: URLSessionDataTask
      if let download = downloads[url] {
        task = download.task
        download.completions.append(completion)
        token = download.token
      } else {
        let newTask = session.dataTask(with: url)
        let download = Download(task: newTask, progress: progress, completion: completion, data: Data())
        download.start()
        downloads[url] = download
        task = newTask
        token = download.token
      }

      task.resume()
    }
    return token
  }

  /// Cancel a running download
  ///
  /// - Parameter token: The token identifier of the the download
  public func cancel(withToken token: UUID) {
    guard let (url, download) = downloads.first(where: { $1.token == token }) else {
      return
    }
    download.task.cancel()
    download.completions.forEach { $0(nil) }
    download.finish()
    clearDownload(for: url)
  }

}

extension Downloader: DownloadStateDelegate {

  fileprivate func progress(for url: URL) -> DownloadProgress? {
    downloads[url]?.progress
  }

  fileprivate func completions(for url: URL) -> [DownloadCompletion]? {
    downloads[url]?.completions
  }

  fileprivate func clearDownload(for url: URL?) {
    guard let url = url else {
      return
    }
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

#if canImport(Combine)
import Combine

extension Downloader {

  @available(iOS 13.0, *)
  public func download(_ url: URL) -> AnyPublisher<Data, MapleBaconDownloadError> {
    session
      .dataTaskPublisher(for: url)
      .receive(on: downloadQueue)
      .map(\.data)
      .mapError { _ in MapleBaconDownloadError.invalidServerResponse }
      .eraseToAnyPublisher()
  }

}

#endif

private final class SessionDelegate: NSObject, URLSessionDataDelegate {

  weak var delegate: DownloadStateDelegate?

  func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
    guard let url = dataTask.originalRequest?.url,
          let download = delegate?.download(for: url),
          let total = dataTask.response?.expectedContentLength else {
            return
    }
    download.data.append(data)
    delegate?.progress(for: url)?(numericCast(download.data.count), total)
  }

  func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
    guard let url = task.originalRequest?.url, let download = delegate?.download(for: url) else {
      return
    }

    let data = error == nil ? download.data : nil
    delegate?.completions(for: url)?.forEach { completion in
      completion(data)
    }
    delegate?.clearDownload(for: url)
    download.finish()
  }

  func urlSession(_ session: URLSession, dataTask: URLSessionDataTask,
                  willCacheResponse proposedResponse: CachedURLResponse,
                  completionHandler: @escaping (CachedURLResponse?) -> Void) {
    completionHandler(nil)
  }

}
