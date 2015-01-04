//
// Copyright (c) 2015 Zalando SE. All rights reserved.
//

import Foundation
import UIKit

var ImageViewAssociatedObjectHandle: UInt8 = 0

extension UIImageView {

    public func setImageWithURL(url: NSURL, cacheScaled: Bool = false) {
        setImageWithURL(url, cacheScaled: cacheScaled, nil)
    }

    public func setImageWithURL(url: NSURL, cacheScaled: Bool = false, completion: ImageDownloaderCompletion?) {
        cancelDownload()
        let operation = ImageManager.sharedManager.downloadImageAtURL(url, cacheScaled: cacheScaled, imageView: self,
                completion: {
                    [weak self] (imageInstance: ImageInstance?, error: NSError?) -> Void in

                    dispatch_async(dispatch_get_main_queue()) {
                        if let image = imageInstance?.image {
                            self?.image = image
                        }
                        if let completion = completion {
                            completion(imageInstance, error)
                        }
                    }
                })
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
