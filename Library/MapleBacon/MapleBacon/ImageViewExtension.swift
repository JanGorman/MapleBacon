//
// Copyright (c) 2015 Zalando SE. All rights reserved.
//

import UIKit

var ImageViewAssociatedObjectHandle: UInt8 = 0

extension UIImageView {

    public func setImageWithURL(url: NSURL, cacheScaled: Bool = false) {
        setImageWithURL(url, cacheScaled: cacheScaled, completion: nil)
    }

    public func setImageWithURL(url: NSURL, cacheScaled: Bool = false, completion: ImageDownloaderCompletion?) {
        cancelDownload()
        let operation = ImageManager.sharedManager.downloadImageAtURL(url, cacheScaled: cacheScaled, imageView: self) {
            [weak self] (imageInstance, error) in

            dispatch_async(dispatch_get_main_queue()) {
                if let image = imageInstance?.image {
                    self?.image = image
                }
                completion?(imageInstance, error)
            }
        }
        if operation != nil {
            self.operation = operation
        }
    }

    var operation: ImageDownloadOperation? {
        get {
            return objc_getAssociatedObject(self, &ImageViewAssociatedObjectHandle) as? ImageDownloadOperation
        }
        set {
            objc_setAssociatedObject(self, &ImageViewAssociatedObjectHandle, newValue,
                    objc_AssociationPolicy(OBJC_ASSOCIATION_RETAIN_NONATOMIC))
        }
    }

    func cancelDownload() {
        if let operation = self.operation {
            operation.cancel()
        }
    }

}
