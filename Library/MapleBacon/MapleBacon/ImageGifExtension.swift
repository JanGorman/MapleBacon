//
// Copyright (c) 2015 Zalando SE. All rights reserved.
//

import UIKit
import ImageIO

extension UIImage {

    class func image(withCachedData data: Data) -> UIImage? {
        guard data.count > 0 else { return nil }
        
        return isAnimatedImage(data: data) ? animatedImageWithData(data: data) : UIImage(data: data as Data)
    }

    private class func animatedImageWithData(data: Data) -> UIImage? {
        let source = CGImageSourceCreateWithData(data as CFData, nil)
        return UIImage.animatedImageWithSource(source: source)
    }

    private class func isAnimatedImage(data: Data) -> Bool {
        var length = UInt16(0)
        (data as NSData).getBytes(&length, range: NSRange(location: 0, length: 2))
        return CFSwapInt16(length) == 0x4749
    }

    private class func animatedImageWithSource(source: CGImageSource!) -> UIImage? {
        let (images, delays) = createImagesAndDelays(source: source)
        let gifDuration = delays.reduce(0, combine: +)
        let frames = framesFromImages(images: images, delays: delays)
        return UIImage.animatedImage(with: frames, duration: Double(gifDuration) / 1000.0)
    }

    private class func framesFromImages(images: [CGImage], delays: [Int]) -> [UIImage] {
        let gcd = DivisionMath.greatestCommonDivisor(array: delays)
        var frames = [UIImage]()
        for i in 0..<images.count {
            let frame = UIImage(cgImage: images[Int(i)])
            let frameCount = abs(Int(delays[Int(i)] / gcd))

            for _ in 0..<frameCount {
                frames.append(frame)
            }
        }
        return frames
    }

    private class func createImagesAndDelays(source: CGImageSource) -> ([CGImage], [Int]) {
        let count = Int(CGImageSourceGetCount(source))
        var images = [CGImage]()
        var delayCentiseconds = [Int]()
        for i in 0 ..< count {
            if let image = CGImageSourceCreateImageAtIndex(source, i, nil) {
                images.append(image)
                delayCentiseconds.append(delayCentisecondsForImageAtIndex(source: source, index: i))
            }
        }
        return (images, delayCentiseconds)
    }

    private class func delayCentisecondsForImageAtIndex(source: CGImageSource, index: Int) -> Int {
        
        guard
            let properties: NSDictionary = CGImageSourceCopyPropertiesAtIndex(source, index, nil) as? NSDictionary,
            let gifProperties = properties[String(kCGImagePropertyGIFDictionary)] as? NSDictionary,
            var delayTime: NSNumber = gifProperties[String(kCGImagePropertyGIFUnclampedDelayTime)] as? NSNumber
        else {
            return -1
        }
                
        if delayTime.doubleValue == 0 {
            
            if let propDelayTime: NSNumber = gifProperties[kCGImagePropertyGIFDelayTime as String] as? NSNumber {
                delayTime = propDelayTime
            }
        }
        
        return Int(delayTime.doubleValue * 1000)
    }

    private class DivisionMath {

        class func greatestCommonDivisor(array: [Int]) -> Int {
            return array.reduce(array[0]) {
                self.greatestCommonDivisorForPair($0, $1)
            }
        }

        class func greatestCommonDivisorForPair(_ a: Int?, _ b: Int?) -> Int {
            switch (a, b) {
            case (.none, .none):
                return 0
            case (let a, .some(0)):
                return a!
            default:
                return greatestCommonDivisorForPair(b!, a! % b!)
            }
        }

    }

}
