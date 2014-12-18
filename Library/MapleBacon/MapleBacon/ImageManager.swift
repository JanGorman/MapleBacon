//
//  Copyright (c) 2014 Zalando SE. All rights reserved.
//

import Foundation
import UIKit

public class ImageManager: NSObject {

    lazy var downloadsInProgress = [NSURL: ImageDownloader]()

    public class var sharedManager: ImageManager {

        struct Singleton {
            static let instance = ImageManager()
        }

        return Singleton.instance
    }

    public func downloadImageAtURL(url: NSURL, cacheScaled: Bool, imageView: UIImageView?,
                                   storage: Storage = MapleBaconStorage.sharedStorage,
                                   completion: ImageDownloaderCompletion?) {
        let image = storage.image(forKey: url.absoluteString!)
        if let cachedImage = image {
            if let completion = completion {
                completion(ImageInstance(image: cachedImage, state: .Cached, url: url), nil)
            }
        } else {
            var imageDownloader = downloadsInProgress[url]
            if (imageDownloader == nil) {
                imageDownloader = ImageDownloader()
                downloadsInProgress[url] = imageDownloader

                imageDownloader!.downloadImageAtURL(url, completion: {
                    [unowned self] (imageInstance, error) in
                    self.downloadsInProgress.removeValueForKey(url)
                    if let completion = completion {
                        if let newImage = imageInstance?.image {
                            if cacheScaled && imageView != nil && newImage.images? == nil {
                                self.resizeAndStoreImage(newImage, imageView: imageView!, storage: storage,
                                        key: url.absoluteString!)
                            } else {
                                let imageData = imageInstance?.data
                                storage.storeImage(newImage, data: imageData!, forKey: url.absoluteString!)
                            }

                            completion(ImageInstance(image: newImage, state: .New, url: imageInstance?.url), nil)
                        }
                    }
                })
            } else if let completion = completion {
                completion(ImageInstance(image: nil, state: .Downloading, url: nil), nil)
            }
        }
    }

    private func resizeAndStoreImage(image: UIImage, imageView: UIImageView, storage: Storage, key: String) {
        Resizer.resizeImage(image, contentMode: imageView.contentMode,
                toSize: imageView.bounds.size,
                interpolationQuality: kCGInterpolationDefault, completion: {
            (resizedImage) in
            storage.storeImage(resizedImage, data: nil, forKey: key)
        })
    }

    public func hasDownloadsInProgress() -> Bool {
        return !downloadsInProgress.isEmpty
    }

}
