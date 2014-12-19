//
//  Copyright (c) 2014 Zalando SE. All rights reserved.
//

import Foundation
import UIKit

extension UIImageView {

    public func setImageWithURL(url: NSURL, cacheScaled: Bool = false) {
        setImageWithURL(url, cacheScaled: cacheScaled, nil)
    }

    public func setImageWithURL(url: NSURL, cacheScaled: Bool = false, completion: ImageDownloaderCompletion?) {
        ImageManager.sharedManager.invalidateDownloadForImageView(self)
        objc_setAssociatedObject(self, &ImageViewAssociatedObjectHandle, url, objc_AssociationPolicy(OBJC_ASSOCIATION_RETAIN_NONATOMIC))

        ImageManager.sharedManager.downloadImageAtURL(url, cacheScaled: cacheScaled, imageView: self, completion: {
            [weak self] (imageInstance: ImageInstance?, error: NSError?) -> Void in

            dispatch_async(dispatch_get_main_queue()) {
                if let image = imageInstance?.image {
                    if !imageInstance!.isInvalidated() {
                        self?.image = image
                    }
                }
                if let completion = completion {
                    completion(imageInstance, error)
                }
            }
        })
    }

}
