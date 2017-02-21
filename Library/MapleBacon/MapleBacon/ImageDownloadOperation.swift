//
// Copyright (c) 2015 Zalando SE. All rights reserved.
//

import UIKit

public typealias ImageDownloaderCompletion = (ImageInstance?, NSError?) -> Void

public protocol ImageDownloadDelegate {
    func imageDownloaderDelegate(_ downloader: ImageDownloadOperation, didReportProgress progress: Progress);
}

public final class ImageDownloadOperation: Operation {

    fileprivate var imageURL: URL
    fileprivate var delegate: ImageDownloadDelegate?
    fileprivate var session: Foundation.URLSession?
    fileprivate var task: URLSessionDownloadTask?
    fileprivate var resumeData: Data?
    fileprivate let progress: Progress = Progress()

    public var completionHandler: ImageDownloaderCompletion?
    
    public var httpAdditionalHeaders: [AnyHashable: Any]?

    public convenience init(imageURL: URL) {
        self.init(imageURL: imageURL, delegate: nil)
    }

    public init(imageURL: URL, delegate: ImageDownloadDelegate?) {
        self.imageURL = imageURL
        self.delegate = delegate
        super.init()
    }

    public override func start() {
        let sessionConfiguration = URLSessionConfiguration.default
        sessionConfiguration.httpAdditionalHeaders = httpAdditionalHeaders
        session = Foundation.URLSession(configuration: sessionConfiguration, delegate: self,
                                        delegateQueue: OperationQueue.main)
        
        resumeDownload()
    }

    public override func cancel() {
        task?.cancel { [weak self] data in
            self?.resumeData = data
            self?.isFinished = true
        }
    }

    fileprivate func resumeDownload() {
        let newTask: URLSessionDownloadTask?
        if let resumeData = resumeData {
            newTask = session?.downloadTask(withResumeData: resumeData)
        } else {
            newTask = session?.downloadTask(with: imageURL)
        }
        newTask?.resume()
        task = newTask
    }

    fileprivate var _finished = false
    override public var isFinished: Bool {
        get {
            return _finished
        }
        set {
            willChangeValue(forKey: "isFinished")
            _finished = newValue
            didChangeValue(forKey: "isFinished")
        }
    }

}

extension ImageDownloadOperation: URLSessionDownloadDelegate {

    public func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask,
                           didWriteData bytesWritten: Int64, totalBytesWritten: Int64,
                           totalBytesExpectedToWrite: Int64) {
        progress.totalUnitCount = totalBytesWritten
        progress.completedUnitCount = bytesWritten
        delegate?.imageDownloaderDelegate(self, didReportProgress: progress)
    }

    public func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask,
                           didFinishDownloadingTo location: URL) {
        defer {
            // An instance of `URLSession` keeps strong reference to it's delegate.
            // See the related API reference: https://developer.apple.com/reference/foundation/urlsession/1411597-init
            // This prevents deallocation of both: The session *and* the delegate, which causes a retain cycle.
            // Therefore it's needed to invalidate the session after the download has finished.
            session.finishTasksAndInvalidate()
        }
        do {
            let newData = try Data(contentsOf: location, options: .mappedIfSafe)
            let newImage = UIImage.imageWithCachedData(newData)
            let newImageInstance = ImageInstance(image: newImage, data: newData, state: .new, url: imageURL)
            if isCancelled {
              return
            }
            completionHandler?(newImageInstance, nil)
        } catch let error as NSError {
            if isCancelled {
              return
            }
            completionHandler?(nil, error)
        }
        isFinished = true
    }

    public func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        defer {
            // An instance of `URLSession` keeps strong reference to it's delegate.
            // See the related API reference: https://developer.apple.com/reference/foundation/urlsession/1411597-init
            // This prevents deallocation of both: The session *and* the delegate, which causes a retain cycle.
            // Therefore it's needed to invalidate the session after the download has finished.
            session.finishTasksAndInvalidate()
        }
        if let error = error {
            if isCancelled {
                isFinished = true
                return
            }
            completionHandler?(nil, error as NSError?)
            isFinished = true
        }
    }

    public func urlSession(_ session: URLSession, task: URLSessionTask,
                           willPerformHTTPRedirection response: HTTPURLResponse, newRequest request: URLRequest,
                           completionHandler: @escaping (URLRequest?) -> Void) {
        self.completionHandler?(nil, nil)
        imageURL = request.url!
        resumeDownload()
    }

}

public enum ImageInstanceState {
    case new, cached, downloading
}

public struct ImageInstance {

    public let image: UIImage?
    public let data: Data?
    public let state: ImageInstanceState
    public let url: URL?

    init(image: UIImage?, data: Data? = nil, state: ImageInstanceState, url: URL?) {
        self.image = image
        self.state = state
        self.url = url
        self.data = data
    }

}
