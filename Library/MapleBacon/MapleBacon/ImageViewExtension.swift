//
// Copyright (c) 2015 Zalando SE. All rights reserved.
//

import UIKit

private var imageViewAssociatedObjectOperationHandle: UInt8 = 0
private var imageViewAssociatedObjectKeyHandle: UInt8 = 1

extension UIImageView {

    public func setImageWithURL(url: URL, placeholder: UIImage? = nil, crossFadePlaceholder crossFade: Bool = true,
            cacheScaled: Bool = false, completion: ImageDownloaderCompletion? = nil) {
        if let placeholder = placeholder {
            image = placeholder
        }
        cancelDownload()
        self.key = url
        if let operation = downloadOperationWithURL(url: url, placeholder: placeholder, crossFadePlaceholder: crossFade,
            cacheScaled: cacheScaled, completion: completion) {
            self.operation = operation
        }
    }

    private func downloadOperationWithURL(url: URL, placeholder: UIImage? = nil, crossFadePlaceholder crossFade: Bool = true,
            cacheScaled: Bool = false, completion: ImageDownloaderCompletion? = nil) -> ImageDownloadOperation? {
        return ImageManager.sharedManager.downloadImage(atUrl: url, cacheScaled: cacheScaled, imageView: self) {
            [weak self] imageInstance, error in
            
            DispatchQueue.main.async(execute: { 
                if let instance = imageInstance {
                    
                    if let _ = placeholder where crossFade && instance.state != .Cached {
                        self?.layer.add(CATransition(), forKey: nil)
                    }
                    
                    if self?.key == instance.url {
                        self?.image = instance.image
                    }
                }
                
                completion?(imageInstance, error)
            })
        }
    }

    private var operation: ImageDownloadOperation? {
        get {
            return objc_getAssociatedObject(self, &imageViewAssociatedObjectOperationHandle) as? ImageDownloadOperation
        }
        set {
            objc_setAssociatedObject(self, &imageViewAssociatedObjectOperationHandle, newValue,
                    objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    private var key: NSURL? {
        get {
            return objc_getAssociatedObject(self, &imageViewAssociatedObjectKeyHandle) as? NSURL
        }
        set {
            objc_setAssociatedObject(self, &imageViewAssociatedObjectKeyHandle, newValue,
                objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

    
    func cancelDownload() {
        operation?.cancel()
        key = nil
    }

}
