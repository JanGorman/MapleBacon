//
// Copyright (c) 2015 Zalando SE. All rights reserved.
//

import UIKit

private var ImageViewAssociatedObjectOperationHandle: UInt8 = 0
private var ImageViewAssociatedObjectKeyHandle: UInt8 = 1

extension UIImageView {

    public func setImageWithURL(url: NSURL, placeholder: UIImage? = nil, crossFadePlaceholder crossFade: Bool = true,
            cacheScaled: Bool = false, completion: ImageDownloaderCompletion? = nil) {
        if let placeholder = placeholder {
            image = placeholder
        }
        cancelDownload()
        self.key = url
        if let operation = downloadOperationWithURL(url, placeholder: placeholder, crossFadePlaceholder: crossFade,
            cacheScaled: cacheScaled, completion: completion) {
            self.operation = operation
        }
    }

    private func downloadOperationWithURL(url: NSURL, placeholder: UIImage? = nil, crossFadePlaceholder crossFade: Bool = true,
            cacheScaled: Bool = false, completion: ImageDownloaderCompletion? = nil) -> ImageDownloadOperation? {
        return ImageManager.sharedManager.downloadImageAtURL(url, cacheScaled: cacheScaled, imageView: self) {
            [weak self] imageInstance, error in
            dispatch_async(dispatch_get_main_queue()) {
                if let instance = imageInstance {
                    if let _ = placeholder where crossFade && instance.state != .Cached {
                        self?.layer.addAnimation(CATransition(), forKey: nil)
                    }
                    if (self?.key == instance.url) {
                        self?.image = instance.image
                    }
                }
                completion?(imageInstance, error)
            }
        }
    }

    private var operation: ImageDownloadOperation? {
        get {
            return objc_getAssociatedObject(self, &ImageViewAssociatedObjectOperationHandle) as? ImageDownloadOperation
        }
        set {
            objc_setAssociatedObject(self, &ImageViewAssociatedObjectOperationHandle, newValue,
                    objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    private var key: NSURL? {
        get {
            return objc_getAssociatedObject(self, &ImageViewAssociatedObjectKeyHandle) as? NSURL
        }
        set {
            objc_setAssociatedObject(self, &ImageViewAssociatedObjectKeyHandle, newValue,
                objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

    
    func cancelDownload() {
        operation?.cancel()
        key = nil
    }

}
