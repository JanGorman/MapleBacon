//
// Copyright (c) 2015 Zalando SE. All rights reserved.
//

import UIKit

private var ImageViewAssociatedObjectOperationHandle: UInt8 = 0
private var ImageViewAssociatedObjectKeyHandle: UInt8 = 1

extension UIImageView {

    public func setImage(withUrl url: URL, placeholder: UIImage? = nil, crossFadePlaceholder crossFade: Bool = true,
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

    private func downloadOperationWithURL(_ url: URL, placeholder: UIImage? = nil,
                                          crossFadePlaceholder crossFade: Bool = true, cacheScaled: Bool = false,
                                          completion: ImageDownloaderCompletion? = nil) -> ImageDownloadOperation? {
        return ImageManager.sharedManager.downloadImage(atUrl: url, cacheScaled: cacheScaled, imageView: self) {
            [weak self] imageInstance, error in
            DispatchQueue.main.async {
                if let instance = imageInstance {
                    if let _ = placeholder , crossFade && instance.state != .cached {
                        self?.layer.add(CATransition(), forKey: nil)
                    }
                    if self?.key == instance.url {
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
                                     .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    private var key: URL? {
        get {
            return objc_getAssociatedObject(self, &ImageViewAssociatedObjectKeyHandle) as? URL
        }
        set {
            objc_setAssociatedObject(self, &ImageViewAssociatedObjectKeyHandle, newValue,
                                     .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

    func cancelDownload() {
        operation?.cancel()
        key = nil
    }

}
