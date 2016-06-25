//
// Copyright (c) 2015 Zalando SE. All rights reserved.
//

import UIKit

public typealias ResizerCompletion = (UIImage) -> Void

internal extension CGSize {
    
    func scaled(factor: CGFloat? = nil) -> CGSize {
        let scale = factor ?? UIScreen.main().scale
        return CGSize(width: self.width * scale, height: self.height * scale)
    }
    
    func zeroBoundedRect() -> CGRect {
        return CGRect(x: 0, y: 0, width: self.width, height: self.height)
    }
}

internal extension CGRect {
    
    func scaled(factor: CGFloat? = nil) -> CGRect {
        let scale = factor ?? UIScreen.main().scale
        return CGRect(x: self.origin.x * scale, y: self.origin.y * scale, width: self.size.width * scale, height: self.size.height * scale)
    }
    
    func zeroBoundedRect() -> CGRect {
        return CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height)
    }
}

// MARK: - Resizer Class -
public class Resizer {
    
    var image: UIImage
    
    /**
     Internal entity to compute and hold resizing values
    */
    private struct ResizeCalculationEntity {
        
        var currentSize: CGSize  = CGSize()
        var intendedSize: CGSize = CGSize()
        
        var horizontalRatio: CGFloat = 0
        var verticalRatio: CGFloat = 0
        var newSize: CGSize = CGSize()
        var offset: CGSize = CGSize()
        var offsetPoint: CGPoint = CGPoint()
        
        var resizeBounds: CGRect {
            return CGRect(x: self.offsetPoint.x, y: self.offsetPoint.y, width: self.intendedSize.width, height: self.intendedSize.height)
        }
        
        init(currentSize imgSize: CGSize, intendedSize size: CGSize) {
            
            self.currentSize = imgSize
            self.intendedSize = size
            
            self.horizontalRatio = size.width / imgSize.width
            self.verticalRatio = size.height / imgSize.height
            self.offset = CGSize(width: imgSize.width - size.width, height: imgSize.height - size.height)
            self.offsetPoint = CGPoint(x: self.offset.width / 2.0, y: self.offset.height / 2.0)
        }
        
        mutating func applyContentMode(contentMode: UIViewContentMode) {
            switch contentMode {
            case .scaleToFill, .redraw:
                self.newSize = CGSize(width: self.currentSize.width * self.horizontalRatio, height: self.currentSize.height * self.verticalRatio)
                self.offset  = self.calcOffset(fromSize: self.newSize, toSize: self.intendedSize)
            case .scaleAspectFill:
                let ratio = max(self.horizontalRatio, self.verticalRatio)
                newSize = CGSize(width: self.currentSize.width * ratio, height: currentSize.height * ratio)
                offset = self.calcOffset(fromSize: newSize, toSize: self.intendedSize)
            case .scaleAspectFit:
                let ratio = min(self.horizontalRatio, self.verticalRatio)
                newSize = CGSize(width: self.currentSize.width * ratio, height: self.currentSize.height * ratio)
                offset = self.calcOffset(fromSize: newSize, toSize: self.intendedSize)
            case .center:
                break
            case .top:
                self.offsetPoint.y = 0
            case .bottom:
                self.offsetPoint.y = self.offset.height
            case .left:
                self.offsetPoint.x = 0
            case .right:
                self.offsetPoint.x = self.offset.width
            case .topLeft:
                self.offsetPoint = CGPoint(x: 0, y: 0)
            case .topRight:
                self.offsetPoint = CGPoint(x: self.offset.width, y: 0)
            case .bottomLeft:
                self.offsetPoint = CGPoint(x: 0, y: self.offset.height)
            case .bottomRight:
                self.offsetPoint = CGPoint(x: self.offset.width, y: self.offset.height)
            }
        }
        
        private mutating func calcOffset(fromSize size: CGSize, toSize: CGSize) -> CGSize {
            let size = CGSize(width: size.width - toSize.width, height: size.height - toSize.height)
            self.offsetPoint = CGPoint(x: size.width / 2.0, y: size.height / 2.0)
            
            return size
        }
    }
    
    /**
     Inits with the image to transform
     */
    init(image: UIImage) {
        self.image = image
    }
    
    /**
     Resize fkt with default content mode and quality
     */
    public func resize(toSize size: CGSize, async: Bool = true, completion: ResizerCompletion) {
        self.resize(toSize: size, contentMode: .scaleToFill, interpolationQuality: .default, async: async, completion: completion)
    }
    
    /**
     Resize fkt
     */
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
        
        if
            let resizedImage = resize(toSize: size, usingTransform: transformForOrientation(toSize: size), drawTransposed: drawTransposed, interpolationQuality: quality),
            let croppedImage = crop(image: resizedImage, toBounds: bounds)
        {
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

    /**
     Actual resizing method
     */
    private func resize(toSize size: CGSize, usingTransform transform: CGAffineTransform, drawTransposed transpose: Bool, interpolationQuality quality: CGInterpolationQuality) -> UIImage? {
        
        let newRect = size.zeroBoundedRect().integral
        let transposedRect = newRect.zeroBoundedRect()
        
        guard let imageRef: CGImage = image.cgImage else {
            return nil
        }
        
        let bpc = imageRef.bitsPerComponent
        let bpr = imageRef.bytesPerRow * Int(UIScreen.main().scale)
        let crs = imageRef.colorSpace!
        let bmi = imageRef.bitmapInfo.rawValue
        
        guard let bitmap = CGContext(data: nil, width: Int(newRect.size.width), height: Int(newRect.size.height), bitsPerComponent: bpc, bytesPerRow: bpr, space: crs, bitmapInfo: bmi) else {
            return nil
        }
        
        bitmap.concatCTM(transform)
        bitmap.interpolationQuality = quality
        bitmap.draw(in: transpose ? transposedRect : newRect, image: imageRef)
        
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
