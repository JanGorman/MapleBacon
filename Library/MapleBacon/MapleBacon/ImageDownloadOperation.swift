//
// Copyright (c) 2015 Zalando SE. All rights reserved.
//

import UIKit

public typealias ImageDownloaderCompletion = (ImageInstance?, NSError?) -> Void

public protocol ImageDownloaderDelegate {
    func imageDownloaderDelegate(downloader: ImageDownloadOperation, didReportProgress progress: Progress)
}

public class ImageDownloadOperation: Operation {

    private var imageURL: URL
    private var delegate: ImageDownloaderDelegate?
    private var session: Foundation.URLSession?
    private var task: URLSessionDownloadTask?
    private var resumeData: Data?
    private let progress: Progress = Progress()

    public var completionHandler: ImageDownloaderCompletion?

    private var _finished = false {
        didSet {
            didChangeValue(forKey: "isFinished")
        }
        willSet {
           willChangeValue(forKey: "isFinished")
        }
    }
    
    override public var isFinished: Bool {
        get {
            return _finished
        }
    }
    
    public convenience init(imageURL: URL) {
        self.init(imageURL: imageURL, delegate: nil)
    }

    public init(imageURL: URL, delegate: ImageDownloaderDelegate?) {
        self.imageURL = imageURL
        self.delegate = delegate
        super.init()
    }

    public override func start() {
        let sessionConfiguration = URLSessionConfiguration.default()
        session = Foundation.URLSession(configuration: sessionConfiguration, delegate: self,
                delegateQueue: OperationQueue.main())
        resumeDownload()
    }

    public override func cancel() {
        task?.cancel(byProducingResumeData: {
            (data) in
            
            self.resumeData = data
            self._finished = true
        })
    }

    private func resumeDownload() {
        let newTask: URLSessionDownloadTask?
        if let resumeData = resumeData {
            newTask = session?.downloadTask(withResumeData: resumeData)
        } else {
            newTask = session?.downloadTask(with: imageURL)
        }
        newTask?.resume()
        task = newTask
    }
}

extension ImageDownloadOperation: URLSessionDownloadDelegate {

    public func urlSession(_ session: Foundation.URLSession, downloadTask: URLSessionDownloadTask,
                           didWriteData bytesWritten: Int64, totalBytesWritten: Int64,
                           totalBytesExpectedToWrite: Int64) {
        
        progress.totalUnitCount = totalBytesWritten
        progress.completedUnitCount = bytesWritten
        delegate?.imageDownloaderDelegate(downloader: self, didReportProgress: progress)
    }

    public func urlSession(_ session: Foundation.URLSession, downloadTask: URLSessionDownloadTask,
                           didFinishDownloadingTo location: URL) {
        do {
            
            let newData = try Data(contentsOf: location, options: Data.ReadingOptions.dataReadingMappedIfSafe)
            let newImage = UIImage.image(withCachedData: newData)
            let newImageInstance = ImageInstance(image: newImage, data: newData, state: .New, url: imageURL)
            if self.isCancelled == true { return }
            completionHandler?(newImageInstance, nil)
        } catch let error as NSError {
            if self.isCancelled == true { return }
            completionHandler?(nil, error)
        }
        self._finished = true
    }

    public func urlSession(_ session: Foundation.URLSession, task: URLSessionTask, didCompleteWithError error: NSError?) {
        if let error = error {
            if self.isCancelled == true {
                self._finished = true
                return
            }
            completionHandler?(nil, error)
            self._finished = true
        }
    }
    
    public func urlSession(_ session: URLSession, task: URLSessionTask, willPerformHTTPRedirection response: HTTPURLResponse, newRequest request: URLRequest, completionHandler: (URLRequest?) -> Swift.Void) {
        
        self.completionHandler?(nil, nil)
        imageURL = request.url!
        resumeDownload()
    }
}

public enum ImageInstanceState {
    case New, Cached, Downloading
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
