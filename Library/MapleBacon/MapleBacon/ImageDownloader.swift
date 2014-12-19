//
//  Copyright (c) 2014 Zalando SE. All rights reserved.
//

import Foundation
import UIKit

let ImageDownloaderErrorDomain = "ImageDownloader"


public typealias ImageDownloaderCompletion = (ImageInstance?, NSError?) -> Void

public protocol ImageDownloaderDelegate {
    func imageDownloaderDelegate(downloader: ImageDownloader, didReportProgress progress: NSProgress);
}

public class ImageDownloader: NSObject, NSURLSessionDownloadDelegate {

    private let queue = dispatch_queue_create(nil, DISPATCH_QUEUE_SERIAL)

    private var imageURL: NSURL?
    private var delegate: ImageDownloaderDelegate?
    private var completionHandler: ImageDownloaderCompletion?
    private var sessionConfig: NSURLSessionConfiguration!
    private var session: NSURLSession!
    private var task: NSURLSessionDownloadTask!
    private var progress: NSProgress?
    private var resumeData: NSData?
    private var invalidated = false

    public convenience override init() {
        self.init(delegate: nil)
    }

    public init(delegate: ImageDownloaderDelegate?) {
        self.delegate = delegate
        super.init()
    }

    public func suspendDownload() {
        task.suspend()
    }

    public func resumeDownload() {
        dispatch_sync(queue) {
            self.task.resume()
        }
    }

    public func cancelDownload() {
        task.cancelByProducingResumeData {
            [unowned self] (data: NSData!) -> Void in
            self.resumeData = data
        }
    }

    public func downloadImageAtURL(url: NSString, completion: ImageDownloaderCompletion?) {
        downloadImageAtURL(NSURL(string: url)!, completion)
    }

    public func downloadImageAtURL(url: NSURL?, completion: ImageDownloaderCompletion?) {
        completionHandler = completion
        sessionConfig = NSURLSessionConfiguration.defaultSessionConfiguration()
        session = NSURLSession(configuration: sessionConfig, delegate: self, delegateQueue: NSOperationQueue.mainQueue())

        if let url = url {
            startTask(image: url)
        } else if let completion = completion {
            completion(nil, NSError(domain: ImageDownloaderErrorDomain, code: -1, userInfo: nil))
        }
    }

    private func startTask(image url: NSURL) {
        imageURL = url
        task = session.downloadTaskWithURL(imageURL!)
        resumeDownload()
    }

    public func URLSession(session: NSURLSession, downloadTask: NSURLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        if (progress == nil) {
            progress = NSProgress(totalUnitCount: totalBytesWritten)
        }
        progress!.completedUnitCount = bytesWritten
        delegate?.imageDownloaderDelegate(self, didReportProgress: progress!)
    }

    public func URLSession(session: NSURLSession, downloadTask: NSURLSessionDownloadTask, didFinishDownloadingToURL location: NSURL) {
        let newData = NSData(contentsOfURL: location)!
        let newImage = UIImage.imageWithData(newData)
        let newImageInstance = ImageInstance(image: newImage, data: newData, state: finishedState(), url: imageURL)
        completionHandler?(newImageInstance, nil)
        progress = nil
    }

    public func finishedState() -> ImageInstanceState {
        return invalidated ? .Invalidated : .New
    }

    public func URLSession(session: NSURLSession, task: NSURLSessionTask, didCompleteWithError error: NSError?) {
        if let error = error {
            println("API error: \(error), \(error.userInfo)")
            progress = nil
            completionHandler?(nil, error)
        }
    }

    public func URLSession(session: NSURLSession, task: NSURLSessionTask, willPerformHTTPRedirection response: NSHTTPURLResponse, newRequest request: NSURLRequest, completionHandler: (NSURLRequest!) -> Void) {
        self.completionHandler!(nil, nil)
        startTask(image: request.URL)
    }

    public func invalidateDownload() {
        invalidated = true
    }

}

public enum ImageInstanceState {
    case New, Cached, Downloading, Invalidated
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

    public func isInvalidated() -> Bool {
        return state == .Invalidated
    }

}
