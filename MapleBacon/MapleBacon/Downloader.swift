//
//  Copyright © 2017 Jan Gorman. All rights reserved.
//

import Foundation

public typealias DownloadProgress = (_ received: Int64, _ total: Int64) -> Void
public typealias DownloadCompletion = (UIImage?) -> Void


protocol DownloadStateDelegate: class {

  func progress(for url: URL) -> DownloadProgress?
  func completion(for url: URL) -> DownloadCompletion?
  func clearDownload(for url: URL?)
  func download(for url: URL) -> Download?
  func updateDownload(for url: URL, with download: Download)

}

struct Download {

  let task: URLSessionDataTask
  let progress: DownloadProgress?
  let completion: DownloadCompletion
  var data: Data

}

public class Downloader {
  
  public static let `default` = Downloader()

  private static let prefix = "com.schnaub.Downloader."

  private let mutex: DispatchQueue
  private let sessionDelegate: SessionDelegate
  private let session: URLSession

  private var runningDownloads: [URL: Download] = [:]

  public init() {
    mutex = DispatchQueue(label: Downloader.prefix + "mutex", attributes: .concurrent)
    sessionDelegate = SessionDelegate()
    session = URLSession(configuration: .default, delegate: sessionDelegate, delegateQueue: .main)
  }

  public func download(_ url: URL,
                       progress: DownloadProgress? = nil,
                       completion: @escaping DownloadCompletion) {
    sessionDelegate.delegate = self

    mutex.sync(flags: .barrier) {
      let task: URLSessionDataTask
      if let download = runningDownloads[url] {
        task = download.task
      } else {
        let t = session.dataTask(with: url)
        let download = Download(task: t, progress: progress, completion: completion, data: Data())
        runningDownloads[url] = download
        task = t
      }

      task.resume()
    }
  }

}

extension Downloader: DownloadStateDelegate {

  func progress(for url: URL) -> DownloadProgress? {
    return runningDownloads[url]?.progress
  }

  func completion(for url: URL) -> DownloadCompletion? {
    return runningDownloads[url]?.completion
  }

  func clearDownload(for url: URL?) {
    guard let url = url else { return }
    mutex.sync(flags: .barrier) {
      runningDownloads[url] = nil
    }
  }

  func download(for url: URL) -> Download? {
    var download: Download? = nil
    mutex.sync(flags: .barrier) {
      download = runningDownloads[url]
    }
    return download
  }

  func updateDownload(for url: URL, with download: Download) {
    mutex.sync(flags: .barrier) {
      runningDownloads[url] = download
    }
  }

}

private class SessionDelegate: NSObject, URLSessionDataDelegate {

  weak var delegate: DownloadStateDelegate?

  func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
    guard let url = dataTask.originalRequest?.url,
          var download = delegate?.download(for: url),
          let total = dataTask.response?.expectedContentLength else { return }
    download.data.append(data)
    // Question, should this rather be a value type if this forces replacing the whole data?
    delegate?.updateDownload(for: url, with: download)
    delegate?.progress(for: url)?(numericCast(download.data.count), total)
  }

  func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
    var url: URL? = nil
    defer {
      delegate?.clearDownload(for: url)
//      session.finishTasksAndInvalidate()
    }
    guard let requestUrl = task.originalRequest?.url,
          let download = delegate?.download(for: requestUrl),
          let image = UIImage(data: download.data), error == nil else { return }
    url = requestUrl
    delegate?.completion(for: requestUrl)?(image)
  }

}
