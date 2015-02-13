//
// Copyright (c) 2015 Zalando SE. All rights reserved.
//

import Foundation
import UIKit

let ImageDownloaderErrorDomain = "ImageDownloader"

public typealias ImageDownloaderCompletion = (ImageInstance?, NSError?) -> Void

public protocol ImageDownloaderDelegate {
    func imageDownloaderDelegate(downloader: ImageDownloadOperation, didReportProgress progress: NSProgress);
}

public class ImageDownloadOperation: NSOperation {

    private var imageURL: NSURL
    private var delegate: ImageDownloaderDelegate?
    private var session: NSURLSession!
    private var task: NSURLSessionDownloadTask!
    private var resumeData: NSData?
    private var progress: NSProgress {
        return NSProgress()
    }
    public var completionHandler: ImageDownloaderCompletion?

    public convenience init(imageURL: NSURL) {
        self.init(imageURL: imageURL, delegate: nil)
    }

    public init(imageURL: NSURL, delegate: ImageDownloaderDelegate?) {
        self.imageURL = imageURL
        self.delegate = delegate
        super.init()
    }

    public override func start() {
        let sessionConfiguration = NSURLSessionConfiguration.defaultSessionConfiguration()
        session = NSURLSession(configuration: sessionConfiguration, delegate: self,
                delegateQueue: NSOperationQueue.mainQueue())
        resumeDownload()
    }

    public override func cancel() {
        task.cancelByProducingResumeData {
            [unowned self] (data: NSData!) -> Void in
            self.resumeData = data
        }
    }

    private func resumeDownload() {
        task = session.downloadTaskWithURL(imageURL)
        task.resume()
    }

}

extension ImageDownloadOperation: NSURLSessionDownloadDelegate {

    public func URLSession(session: NSURLSession, downloadTask: NSURLSessionDownloadTask,
                           didWriteData bytesWritten: Int64, totalBytesWritten: Int64,
                           totalBytesExpectedToWrite: Int64) {
        progress.totalUnitCount = totalBytesWritten
        progress.completedUnitCount = bytesWritten
        delegate?.imageDownloaderDelegate(self, didReportProgress: progress)
    }

    public func URLSession(session: NSURLSession, downloadTask: NSURLSessionDownloadTask,
                           didFinishDownloadingToURL location: NSURL) {
        let newData = NSData(contentsOfURL: location)!
        let newImage = UIImage.imageWithData(newData)
        let newImageInstance = ImageInstance(image: newImage, data: newData, state: .New, url: imageURL)
        completionHandler?(newImageInstance, nil)
    }

    public func URLSession(session: NSURLSession, task: NSURLSessionTask, didCompleteWithError error: NSError?) {
        if let error = error {
            println("Remote error: \(error), \(error.userInfo)")
            completionHandler?(nil, error)
        }
    }

    public func URLSession(session: NSURLSession, task: NSURLSessionTask,
                           willPerformHTTPRedirection response: NSHTTPURLResponse,
                           newRequest request: NSURLRequest, completionHandler: (NSURLRequest!) -> Void) {
        self.completionHandler?(nil, nil)
        self.imageURL = request.URL!
        resumeDownload()
    }

}

public enum ImageInstanceState {
    case New, Cached, Downloading
}

public struct ImageInstance {

    public let image: UIImage?
    public let data: NSData?
    public let state: ImageInstanceState
    public let url: NSURL?

    init(image: UIImage?, data: NSData? = nil, state: ImageInstanceState, url: NSURL?) {
        self.image = image
        self.state = state
        self.url = url
        self.data = data
    }
}
