//
//  Copyright © 2017 Jan Gorman. All rights reserved.
//

import UIKit

public typealias DownloadProgress = (_ received: Int64, _ total: Int64) -> Void
public typealias DownloadCompletion = (UIImage?) -> Void


protocol DownloadStateDelegate: class {

  func progress(for url: URL) -> DownloadProgress?
  func completion(for url: URL) -> DownloadCompletion?
  func clearDownload(for url: URL?)
  func download(for url: URL) -> Download?

}

class Download {

  let task: URLSessionDataTask
  let progress: DownloadProgress?
  let completion: DownloadCompletion
  var data: Data

  init(task: URLSessionDataTask, progress: DownloadProgress?, completion: @escaping DownloadCompletion,
       data: Data) {
    self.task = task
    self.progress = progress
    self.completion = completion
    self.data = data
  }

}

/// The class responsible for downloading images. Access it through the `default` singleton.
public class Downloader {

  /// The default `Downloader` singleton
  public static let `default` = Downloader()

  private let mutex: DispatchQueue
  private let sessionDelegate: SessionDelegate
  private let session: URLSession

  private var downloads: [URL: Download]

  public init() {
    mutex = DispatchQueue(label: "com.schnaub.Downloader.mutex", attributes: .concurrent)
    sessionDelegate = SessionDelegate()
    session = URLSession(configuration: .default, delegate: sessionDelegate, delegateQueue: .main)
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
      } else {
        let t = session.dataTask(with: url)
        let download = Download(task: t, progress: progress, completion: completion, data: Data())
        downloads[url] = download
        task = t
      }

      task.resume()
    }
  }

}

extension Downloader: DownloadStateDelegate {

  func progress(for url: URL) -> DownloadProgress? {
    return downloads[url]?.progress
  }

  func completion(for url: URL) -> DownloadCompletion? {
    return downloads[url]?.completion
  }

  func clearDownload(for url: URL?) {
    guard let url = url else { return }
    mutex.sync(flags: .barrier) {
      downloads[url] = nil
    }
  }

  func download(for url: URL) -> Download? {
    var download: Download? = nil
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
    var url: URL? = nil
    defer {
      delegate?.clearDownload(for: url)
    }
    guard let requestUrl = task.originalRequest?.url,
          let download = delegate?.download(for: requestUrl),
          let image = UIImage(data: download.data), error == nil else { return }
    url = requestUrl
    delegate?.completion(for: requestUrl)?(image)
  }

}
