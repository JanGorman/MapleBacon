//
// Copyright (c) 2015 Zalando SE. All rights reserved.
//

import UIKit

public typealias ResizerCompletion = (UIImage) -> Void

public final class Resizer {

    fileprivate static let deviceScale = UIScreen.main.scale

    public static func resize(image: UIImage, toSize size: CGSize, async: Bool = true,
                                completion: @escaping ResizerCompletion) {
        resize(image: image, contentMode: .scaleToFill, toSize: size, interpolationQuality: .default, async: async,
               completion: completion)
    }

    public static func resize(image: UIImage, contentMode: UIViewContentMode, toSize size: CGSize,
                              interpolationQuality quality: CGInterpolationQuality,
                              async: Bool = true, completion: @escaping ResizerCompletion) {
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
        case .scaleToFill, .redraw:
            newSize = CGSize(width: image.size.width * horizontalRatio, height: image.size.height * verticalRatio)
            offset = offsetFromSize(newSize, toSize: size)
            newX = offset.width / 2
            newY = offset.height / 2
        case .scaleAspectFill:
            let ratio = max(horizontalRatio, verticalRatio)
            newSize = CGSize(width: image.size.width * ratio, height: image.size.height * ratio)
            offset = offsetFromSize(newSize, toSize: size)
            newX = offset.width / 2
            newY = offset.height / 2
        case .scaleAspectFit:
            let ratio = min(horizontalRatio, verticalRatio)
            newSize = CGSize(width: image.size.width * ratio, height: image.size.height * ratio)
            offset = offsetFromSize(newSize, toSize: size)
            newX = offset.width / 2
            newY = offset.height / 2
        case .center:
            break
        case .top:
            newY = 0
        case .bottom:
            newY = offset.height
        case .left:
            newX = 0
        case .right:
            newX = offset.width
        case .topLeft:
            newX = 0
            newY = 0
        case .topRight:
            newX = offset.width
            newY = 0
        case .bottomLeft:
            newX = 0
            newY = offset.height
        case .bottomRight:
            newX = offset.width
            newY = offset.height
        }

        let scaleDependentNewSize = CGSize(width: newSize.width * deviceScale, height: newSize.height * deviceScale)
        let newBounds = CGRect(x: newX * deviceScale, y: newY * deviceScale, width: size.width * deviceScale,
                               height: size.height * deviceScale)

        if async {
            DispatchQueue.global(qos: .background).async {
                self.resizeImageFromImage(image, toSize: scaleDependentNewSize, newBounds: newBounds,
                                          interpolationQuality: quality, async: async, completion: completion)
            }
        } else {
            resizeImageFromImage(image, toSize: scaleDependentNewSize, newBounds: newBounds,
                                 interpolationQuality: quality, async: async, completion: completion)
        }
    }

    private static func resizeImageFromImage(_ image: UIImage, toSize size: CGSize, newBounds bounds: CGRect,
                                             interpolationQuality quality: CGInterpolationQuality, async: Bool,
                                             completion: @escaping ResizerCompletion) {
        var imageToReturn = image
        if let resizedImage = imageFrom(image: image, toSize: size, interpolationQuality: quality),
           let croppedImage = croppedImageFromImage(resizedImage, toBounds: bounds) {
            imageToReturn = croppedImage
        }
        if async {
            DispatchQueue.main.async {
                completion(imageToReturn)
            }
        } else {
            completion(imageToReturn)
        }
    }

    private static func offsetFromSize(_ size: CGSize, toSize: CGSize) -> CGSize {
        return CGSize(width: size.width - toSize.width, height: size.height - toSize.height)
    }

    private static func imageFrom(image: UIImage, toSize size: CGSize,
                                  interpolationQuality quality: CGInterpolationQuality) -> UIImage? {
        return imageFrom(image: image, toSize: size, usingTransform: transformForOrientationImage(image, toSize: size),
                         drawTransposed: drawTransposed(orientation: image.imageOrientation),
                         interpolationQuality: quality)
    }
    
    private static func drawTransposed(orientation: UIImageOrientation) -> Bool {
        switch (orientation) {
        case .left, .leftMirrored, .right, .rightMirrored:
            return true
        default:
            return false
        }
    }

    private static func croppedImageFromImage(_ image: UIImage, toBounds bounds: CGRect) -> UIImage? {
        if let cgimage = image.cgImage?.cropping(to: bounds) {
            return UIImage(cgImage: cgimage)
        }
        return nil
    }

    private static func imageFrom(image: UIImage, toSize size: CGSize,
                                  usingTransform transform: CGAffineTransform, drawTransposed transpose: Bool,
                                  interpolationQuality quality: CGInterpolationQuality) -> UIImage? {
      let newRect = CGRect(x: 0, y: 0, width: size.width, height: size.height).integral
      let transposedRect = CGRect(x: 0, y: 0, width: newRect.size.height, height: newRect.size.width)
      let cgImage = image.cgImage
      
      let bitmap = CGContext(data: nil, width: Int(newRect.size.width),
                             height: Int(newRect.size.height), bitsPerComponent: (cgImage?.bitsPerComponent)!,
                             bytesPerRow: (cgImage?.bytesPerRow)! * Int(deviceScale), space: (cgImage?.colorSpace!)!,
                             bitmapInfo: (cgImage?.bitmapInfo.rawValue)!)
      
      bitmap?.concatenate(transform)
      bitmap?.interpolationQuality = quality
      bitmap?.draw(cgImage!, in: transpose ? transposedRect : newRect)
      if let cgImage = bitmap?.makeImage() {
        return UIImage(cgImage: cgImage)
      }
      return nil
    }

    private static func transformForOrientationImage(_ image: UIImage, toSize size: CGSize) -> CGAffineTransform {
        var transform: CGAffineTransform = .identity

        switch (image.imageOrientation) {
        case .down, .downMirrored:
            transform = transform.translatedBy(x: size.width, y: size.height)
            transform = transform.rotated(by: CGFloat(M_PI))
        case .left, .leftMirrored:
            transform = transform.translatedBy(x: size.width, y: 0)
            transform = transform.rotated(by: CGFloat(M_PI_2))
        case .right, .rightMirrored:
            transform = transform.translatedBy(x: 0, y: size.height)
            transform = transform.rotated(by: CGFloat(-M_PI_2))
        default:
            break
        }

        switch (image.imageOrientation) {
        case .downMirrored, .upMirrored:
            transform = transform.translatedBy(x: size.width, y: 0)
            transform = transform.scaledBy(x: -1, y: 1)
        case .leftMirrored, .rightMirrored:
            transform = transform.translatedBy(x: size.height, y: 0)
            transform = transform.scaledBy(x: -1, y: 1)
        default:
            break
        }

        return transform
    }

}
