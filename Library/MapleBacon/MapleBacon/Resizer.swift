//
// Copyright (c) 2015 Zalando SE. All rights reserved.
//

import UIKit

public typealias ResizerCompletion = (UIImage) -> Void


public class Resizer {
    
    var image: UIImage
    

    private struct ResizeCalculationEntity {
        
        var currentSize: CGSize  = .zero
        var intendedSize: CGSize = .zero
        
        var horizontalRatio: CGFloat = 0
        var verticalRatio: CGFloat = 0
        var newSize: CGSize = .zero
        var offset: CGSize = .zero
        var offsetBy: CGPoint = .zero
        
        var resizeBounds: CGRect {
            return CGRect(x: offsetBy.x, y: offsetBy.y, width: intendedSize.width, height: intendedSize.height)
        }
        
        init(currentSize imgSize: CGSize, intendedSize size: CGSize) {
            
            self.currentSize = imgSize
            self.intendedSize = size
            
            self.horizontalRatio = size.width / imgSize.width
            self.verticalRatio = size.height / imgSize.height
            self.offset = CGSize(width: imgSize.width - size.width, height: imgSize.height - size.height)
            self.offsetBy = CGPoint(x: self.offset.width / 2.0, y: self.offset.height / 2.0)
        }
        
        mutating func applyContentMode(contentMode: UIViewContentMode) {
            switch contentMode {
            case .scaleToFill, .redraw:
                newSize = CGSize(width: currentSize.width * horizontalRatio, height: currentSize.height * verticalRatio)
                (offset, offsetBy)  = calcOffset(fromSize: newSize, toSize: intendedSize)
            case .scaleAspectFill:
                let ratio = max(horizontalRatio, verticalRatio)
                newSize = CGSize(width: currentSize.width * ratio, height: currentSize.height * ratio)
                (offset, offsetBy) = calcOffset(fromSize: newSize, toSize: intendedSize)
            case .scaleAspectFit:
                let ratio = min(horizontalRatio, verticalRatio)
                newSize = CGSize(width: currentSize.width * ratio, height: currentSize.height * ratio)
                (offset, offsetBy) = calcOffset(fromSize: newSize, toSize: intendedSize)
            case .center:
                break
            case .top:
                self.offsetBy.y = 0
            case .bottom:
                self.offsetBy.y = offset.height
            case .left:
                self.offsetBy.x = 0
            case .right:
                self.offsetBy.x = offset.width
            case .topLeft:
                self.offsetBy = CGPoint(x: 0, y: 0)
            case .topRight:
                self.offsetBy = CGPoint(x: offset.width, y: 0)
            case .bottomLeft:
                self.offsetBy = CGPoint(x: 0, y: offset.height)
            case .bottomRight:
                self.offsetBy = CGPoint(x: offset.width, y: offset.height)
            }
        }
        
        private func calcOffset(fromSize size: CGSize, toSize: CGSize) -> (offset: CGSize, offsetBy: CGPoint) {
            let offset = CGSize(width: size.width - toSize.width, height: size.height - toSize.height)
            let point  = CGPoint(x: offset.width / 2.0, y: offset.height / 2.0)
            
            return (offset, point)
        }
    }
    

    public init(image: UIImage) {
        self.image = image
    }
    
    public func resize(toSize size: CGSize, async: Bool = true, completion: ResizerCompletion) {
        self.resize(toSize: size, contentMode: .scaleToFill, interpolationQuality: .default, async: async, completion: completion)
    }
    
    public func resize(toSize size: CGSize, contentMode: UIViewContentMode, interpolationQuality quality: CGInterpolationQuality = .default, async: Bool = true, completion: ResizerCompletion) {
        
        // if image is already smaller/equal than/like requested abbort
        if image.size.height < size.height && image.size.width < size.width {
            completion(image)
            return
        }
        
        var resizeData = ResizeCalculationEntity(currentSize: image.size, intendedSize: size)
        resizeData.applyContentMode(contentMode: contentMode)
        
        let newSize   = resizeData.newSize.scaled()
        let newBounds = resizeData.resizeBounds.scaled()
        
        let action = {
            self.resize(toSize: newSize, toBounds: newBounds, interpolationQuality: quality, async: async, completion: completion)
        }

        if async {
            
            DispatchQueue.global().async(execute: action)
            return
        }
        
        action()
    }
    
    /**
     Prequisite reszing method
     */
    private func resize(toSize size: CGSize, toBounds bounds: CGRect, interpolationQuality quality: CGInterpolationQuality, async: Bool, completion: ResizerCompletion) {
        
        var imageToReturn = self.image
        
        let drawTransposed: Bool
        switch image.imageOrientation {
        case .left, .leftMirrored, .right, .rightMirrored:
            drawTransposed = true
        default:
            drawTransposed = false
        }
        
        if let resizedImage = resize(toSize: size, usingTransform: transformForOrientation(toSize: size), drawTransposed: drawTransposed, interpolationQuality: quality),
            croppedImage = crop(image: resizedImage, toBounds: bounds) {
            
            imageToReturn = croppedImage
        }
      
        let action = {
            completion(imageToReturn)
        }
        
        if async {
            DispatchQueue.main.async(execute: action)
            return
        }
        
        action()
    }

    private func resize(toSize size: CGSize, usingTransform transform: CGAffineTransform, drawTransposed transpose: Bool, interpolationQuality quality: CGInterpolationQuality) -> UIImage? {
        
        let newRect = size.zeroBoundedRect().integral
        let transposedRect = newRect.zeroBoundedRect()
        
        guard let image = image.cgImage else { return nil }
        
        let bitsPerComponent = image.bitsPerComponent
        let bytesPerRow      = image.bytesPerRow * Int(UIScreen.main().scale)
        let colorSpace       = image.colorSpace!
        let bitmapInfo       = image.bitmapInfo.rawValue
        
        guard let bitmap = CGContext(data: nil, width: Int(newRect.size.width), height: Int(newRect.size.height), bitsPerComponent: bitsPerComponent, bytesPerRow: bytesPerRow, space: colorSpace, bitmapInfo: bitmapInfo) else {
            return nil
        }
        
        bitmap.concatCTM(transform)
        bitmap.interpolationQuality = quality
        bitmap.draw(in: transpose ? transposedRect : newRect, image: image)
        
        if let cgimage = bitmap.makeImage() {
            return UIImage(cgImage: cgimage)
        }
        
        return nil
    }
    
    private func crop(image: UIImage, toBounds bounds: CGRect) -> UIImage? {
        if let cgimage = image.cgImage!.cropping(to: bounds) {
            return UIImage(cgImage: cgimage)
        }
        return nil
    }
    
    private func transformForOrientation(toSize size: CGSize) -> CGAffineTransform {
        var transform = CGAffineTransform()
        
        switch image.imageOrientation {
        case .down, .downMirrored:
            transform = transform.translateBy(x: size.width, y: size.height)
            transform = transform.rotate(CGFloat(M_PI))
        case .left, .leftMirrored:
            transform = transform.translateBy(x: size.width, y: 0)
            transform = transform.rotate(CGFloat(M_PI_2))
        case .right, .rightMirrored:
            transform = transform.translateBy(x: 0, y: size.height)
            transform = transform.rotate(CGFloat(-M_PI_2))
        default:
            break
        }
        
        switch image.imageOrientation {
        case .downMirrored, .upMirrored:
            transform = transform.translateBy(x: size.width, y: 0)
            transform = transform.scaleBy(x: -1, y: 1)
        case .leftMirrored, .rightMirrored:
            transform = transform.translateBy(x: size.height, y: 0)
            transform = transform.scaleBy(x: -1, y: 1)
        default:
            break
        }
        
        return transform
    }
}
