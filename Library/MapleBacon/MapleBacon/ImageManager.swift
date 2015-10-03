//
// Copyright (c) 2015 Zalando SE. All rights reserved.
//

import UIKit

public class ImageManager {

    public static let sharedManager = ImageManager()
    
    private let downloadQueue = NSOperationQueue()
    private var downloadsInProgress = [NSURL: ImageDownloadOperation]()

    deinit {
        downloadQueue.cancelAllOperations()
    }

    public func downloadImageAtURL(url: NSURL, cacheScaled: Bool, imageView: UIImageView?,
                                   storage: Storage = MapleBaconStorage.sharedStorage,
                                   completion: ImageDownloaderCompletion?) -> ImageDownloadOperation? {
        if let cachedImage = storage.image(forKey: url.absoluteString) {
            completion?(ImageInstance(image: cachedImage, state: .Cached, url: url), nil)
        } else {
            if downloadsInProgress[url] == nil {
                let downloadOperation = ImageDownloadOperation(imageURL: url)
                downloadOperation.qualityOfService = .UserInitiated
                downloadOperation.completionHandler = downloadHandlerWithStorage(url, cacheScaled: cacheScaled,
                        imageView: imageView, storage: storage, completion: completion)
                downloadsInProgress[url] = downloadOperation
                downloadQueue.addOperation(downloadOperation)
                return downloadOperation
            } else {
                completion?(ImageInstance(image: nil, state: .Downloading, url: nil), nil)
                delay(0.1) {
                    self.downloadImageAtURL(url, cacheScaled: cacheScaled, imageView: imageView, storage: storage, completion: completion)
                }
            }
        }
        return nil
    }

    private func downloadHandlerWithStorage(url: NSURL, cacheScaled: Bool, imageView: UIImageView?, storage: Storage, completion: ImageDownloaderCompletion?) -> ImageDownloaderCompletion {
        return { [weak self] (imageInstance, _) in
            self?.downloadsInProgress[url] = nil
            if let newImage = imageInstance?.image {
                if cacheScaled && imageView != nil && newImage.images == nil {
                    self?.resizeAndStoreImage(newImage, imageView: imageView!, storage: storage,
                        key: url.absoluteString)
                } else if let imageData = imageInstance?.data {
                    storage.storeImage(newImage, data: imageData, forKey: url.absoluteString)
                }
                completion?(ImageInstance(image: newImage, state: .New, url: imageInstance?.url), nil)
            }
        }
    }

    private func resizeAndStoreImage(image: UIImage, imageView: UIImageView, storage: Storage, key: String) {
        Resizer.resizeImage(image, contentMode: imageView.contentMode, toSize: imageView.bounds.size,
                interpolationQuality: .Default) {
            resizedImage in
            storage.storeImage(resizedImage, data: nil, forKey: key)
        }
    }

    public func hasDownloadsInProgress() -> Bool {
        return !downloadsInProgress.isEmpty
    }

}
