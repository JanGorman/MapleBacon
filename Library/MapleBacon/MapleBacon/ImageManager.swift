//
// Copyright (c) 2015 Zalando SE. All rights reserved.
//

import UIKit

public final class ImageManager {

    public static let sharedManager = ImageManager()
    
    fileprivate let downloadQueue = OperationQueue()
    fileprivate var downloadsInProgress = [URL: ImageDownloadOperation]()

    deinit {
        downloadQueue.cancelAllOperations()
    }

    public func downloadImage(atUrl url: URL, cacheScaled: Bool, imageView: UIImageView?,
                              storage: Storage = MapleBaconStorage.sharedStorage,
                              completion: ImageDownloaderCompletion?) -> ImageDownloadOperation? {
        if let cachedImage = storage.image(forKey: url.absoluteString) {
            completion?(ImageInstance(image: cachedImage, state: .cached, url: url), nil)
        } else {
            if downloadsInProgress[url] == nil {
                let downloadOperation = ImageDownloadOperation(imageURL: url)
                downloadOperation.qualityOfService = .userInitiated
                downloadOperation.completionHandler = downloadHandlerWithStorage(url, cacheScaled: cacheScaled,
                                                                                 imageView: imageView, storage: storage,
                                                                                 completion: completion)
                downloadsInProgress[url] = downloadOperation
                downloadQueue.addOperation(downloadOperation)
                return downloadOperation
            } else {
                completion?(ImageInstance(image: nil, state: .downloading, url: nil), nil)
                delay(by: .milliseconds(1)) {
                    _ = self.downloadImage(atUrl: url, cacheScaled: cacheScaled, imageView: imageView, storage: storage,
                                           completion: completion)
                }
            }
        }
        return nil
    }

    private func downloadHandlerWithStorage(_ url: URL, cacheScaled: Bool, imageView: UIImageView?, storage: Storage,
                                            completion: ImageDownloaderCompletion?) -> ImageDownloaderCompletion {
        return { [weak self] imageInstance, _ in
            self?.downloadsInProgress[url] = nil
            if let newImage = imageInstance?.image {
                if cacheScaled && imageView != nil && newImage.images == nil {
                    self?.resizeAndStore(image: newImage, imageView: imageView!, storage: storage,
                                         key: url.absoluteString)
                } else if let imageData = imageInstance?.data {
                    storage.store(image: newImage, data: imageData, forKey: url.absoluteString)
                }
                completion?(ImageInstance(image: newImage, state: .new, url: imageInstance?.url), nil)
            }
        }
    }

    private func resizeAndStore(image: UIImage, imageView: UIImageView, storage: Storage, key: String) {
        Resizer.resize(image: image, contentMode: imageView.contentMode, toSize: imageView.bounds.size,
                       interpolationQuality: .default) { resizedImage in
                        storage.store(image: resizedImage, data: nil, forKey: key)
        }
    }

    public func hasDownloadsInProgress() -> Bool {
        return !downloadsInProgress.isEmpty
    }

}
