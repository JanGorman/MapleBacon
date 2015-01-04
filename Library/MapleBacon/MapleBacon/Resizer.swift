//
// Copyright (c) 2015 Zalando SE. All rights reserved.
//

import UIKit

let deviceScale = UIScreen.mainScreen().scale

public typealias ResizerCompletion = (UIImage) -> Void

public class Resizer {

    public class func resizeImage(image: UIImage, toSize size: CGSize, async: Bool = true, completion: ResizerCompletion) {
        resizeImage(image, contentMode: .ScaleToFill, toSize: size, interpolationQuality: kCGInterpolationDefault,
                async: async, completion: completion)
    }

    public class func resizeImage(image: UIImage, contentMode: UIViewContentMode, toSize size: CGSize,
                                  interpolationQuality quality: CGInterpolationQuality,
                                  async: Bool = true, completion: ResizerCompletion) {
        if image.size.height < size.height && image.size.width < size.width {
            completion(image)
            return
        }
        let horizontalRatio = size.width / image.size.width
        let verticalRatio = size.height / image.size.height
        var newSize = image.size
        var offset = offsetFromSize(image.size, toSize: size)
        var newX = offset.width / 2
        var newY = offset.height / 2

        switch (contentMode) {
        case .ScaleToFill, .Redraw:
            newSize = CGSizeMake(image.size.width * horizontalRatio, image.size.height * verticalRatio)
            offset = offsetFromSize(newSize, toSize: size)
            newX = offset.width / 2
            newY = offset.height / 2
        case .ScaleAspectFill:
            let ratio = max(horizontalRatio, verticalRatio)
            newSize = CGSizeMake(image.size.width * ratio, image.size.height * ratio)
            offset = offsetFromSize(newSize, toSize: size)
            newX = offset.width / 2
            newY = offset.height / 2
        case .ScaleAspectFit:
            let ratio = min(horizontalRatio, verticalRatio)
            newSize = CGSizeMake(image.size.width * ratio, image.size.height * ratio)
            offset = offsetFromSize(newSize, toSize: size)
            newX = offset.width / 2
            newY = offset.height / 2
        case .Center:
            break
        case .Top:
            newY = 0
        case .Bottom:
            newY = offset.height
        case .Left:
            newX = 0
        case .Right:
            newX = offset.width
        case .TopLeft:
            newX = 0
            newY = 0
        case .TopRight:
            newX = offset.width
            newY = 0
        case .BottomLeft:
            newX = 0
            newY = offset.height
        case .BottomRight:
            newX = offset.width
            newY = offset.height
        }

        let scaleDependentNewSize = CGSizeMake(newSize.width * deviceScale, newSize.height * deviceScale)
        let newBounds = CGRectMake(newX * deviceScale, newY * deviceScale, size.width * deviceScale, size.height * deviceScale)

        if async {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), {
                self.resizeImageFromImage(image, toSize: scaleDependentNewSize, newBounds: newBounds,
                        interpolationQuality: quality, async: async, completion: completion)
            })
        } else {
            self.resizeImageFromImage(image, toSize: scaleDependentNewSize, newBounds: newBounds,
                    interpolationQuality: quality, async: async, completion: completion)
        }
    }

    private class func resizeImageFromImage(image: UIImage, toSize size: CGSize, newBounds bounds: CGRect,
                                            interpolationQuality quality: CGInterpolationQuality, async: Bool,
                                            completion: ResizerCompletion) {
        var imageToReturn = image
        if let resizedImage = imageFromImage(image, toSize: size, interpolationQuality: quality) {
            if let croppedImage = croppedImageFromImage(resizedImage, toBounds: bounds) {
                imageToReturn = croppedImage
            }
        }
        if async {
            dispatch_async(dispatch_get_main_queue(), {
                completion(imageToReturn)
            })
        } else {
            completion(imageToReturn)
        }
    }

    private class func offsetFromSize(size: CGSize, toSize: CGSize) -> CGSize {
        return CGSizeMake(size.width - toSize.width, size.height - toSize.height)
    }

    private class func imageFromImage(image: UIImage, toSize size: CGSize,
                                      interpolationQuality quality: CGInterpolationQuality) -> UIImage? {
        var drawTransposed: Bool!

        switch (image.imageOrientation) {
        case .Left, .LeftMirrored, .Right, .RightMirrored:
            drawTransposed = true
        default:
            drawTransposed = false
        }

        return imageFromImage(image, toSize: size, usingTransform: transformForOrientationImage(image, toSize: size),
                drawTransposed: drawTransposed, interpolationQuality: quality)
    }

    private class func croppedImageFromImage(image: UIImage, toBounds bounds: CGRect) -> UIImage? {
        return UIImage(CGImage: CGImageCreateWithImageInRect(image.CGImage, bounds))
    }

    private class func imageFromImage(image: UIImage, toSize size: CGSize,
                                      usingTransform transform: CGAffineTransform, drawTransposed transpose: Bool,
                                      interpolationQuality quality: CGInterpolationQuality) -> UIImage? {
        let newRect = CGRectIntegral(CGRectMake(0, 0, size.width, size.height))
        let transposedRect = CGRectMake(0, 0, newRect.size.height, newRect.size.width)
        let imageRef = image.CGImage
        let bitmap = CGBitmapContextCreate(nil, UInt(newRect.size.width), UInt(newRect.size.height),
                CGImageGetBitsPerComponent(imageRef), CGImageGetBytesPerRow(imageRef) * UInt(deviceScale),
                CGImageGetColorSpace(imageRef), CGImageGetBitmapInfo(imageRef))
        CGContextConcatCTM(bitmap, transform)
        CGContextSetInterpolationQuality(bitmap, quality)
        CGContextDrawImage(bitmap, transpose ? transposedRect : newRect, imageRef)
        let newImageRef = CGBitmapContextCreateImage(bitmap)

        return UIImage(CGImage: newImageRef)
    }

    private class func transformForOrientationImage(image: UIImage, toSize size: CGSize) -> CGAffineTransform {
        var transform = CGAffineTransformIdentity

        switch (image.imageOrientation) {
        case .Down, .DownMirrored:
            transform = CGAffineTransformTranslate(transform, size.width, size.height)
            transform = CGAffineTransformRotate(transform, CGFloat(M_PI))
        case .Left, .LeftMirrored:
            transform = CGAffineTransformTranslate(transform, size.width, 0)
            transform = CGAffineTransformRotate(transform, CGFloat(M_PI_2))
        case .Right, .RightMirrored:
            transform = CGAffineTransformTranslate(transform, 0, size.height)
            transform = CGAffineTransformRotate(transform, CGFloat(-M_PI_2))
        default:
            break
        }

        switch (image.imageOrientation) {
        case .DownMirrored, .UpMirrored:
            transform = CGAffineTransformTranslate(transform, size.width, 0)
            transform = CGAffineTransformScale(transform, -1, 1)
        case .LeftMirrored, .RightMirrored:
            transform = CGAffineTransformTranslate(transform, size.height, 0)
            transform = CGAffineTransformScale(transform, -1, 1)
        default:
            break
        }

        return transform
    }

}
