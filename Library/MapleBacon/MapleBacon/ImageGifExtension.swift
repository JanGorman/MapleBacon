//
// Copyright (c) 2015 Zalando SE. All rights reserved.
//

import UIKit
import ImageIO

extension UIImage {

    class func imageWithCachedData(data: NSData) -> UIImage? {
        return isAnimatedImage(data) ? animatedImageWithData(data) : UIImage(data: data)!
    }

    private class func animatedImageWithData(data: NSData) -> UIImage {
        let source = CGImageSourceCreateWithData(data as CFDataRef, nil)
        return UIImage.animatedImageWithSource(source)
    }

    private class func isAnimatedImage(data: NSData) -> Bool {
        var length = UInt16(0)
        data.getBytes(&length, range: NSRange(location: 0, length: 2))
        return CFSwapInt16(length) == 0x4749
    }

    private class func animatedImageWithSource(source: CGImageSourceRef!) -> UIImage {
        let (images, delays) = createImagesAndDelays(source)
        let gifDuration = delays.reduce(0, combine: +)
        let frames = framesFromImages(images, delays: delays)
        return UIImage.animatedImageWithImages(frames, duration: Double(gifDuration) / 1000.0)
    }

    private class func framesFromImages(images: [CGImageRef], delays: [Int]) -> [UIImage] {
        let gcd = DivisionMath.greatestCommonDivisor(delays)
        var frames = [UIImage]()
        for i in 0 ..< images.count {
            let frame = UIImage(CGImage: images[Int(i)])!
            let frameCount = Int(delays[Int(i)] / gcd)

            for j in 0 ..< frameCount {
                frames.append(frame)
            }
        }
        return frames
    }

    private class func createImagesAndDelays(source: CGImageSourceRef) -> ([CGImageRef], [Int]) {
        let count = Int(CGImageSourceGetCount(source))
        var images = [CGImageRef]()
        var delayCentiseconds = [Int]()
        for i in 0 ..< count {
            images.append(CGImageSourceCreateImageAtIndex(source, i, nil))
            delayCentiseconds.append(delayCentisecondsForImageAtIndex(source, index: i))
        }
        return (images, delayCentiseconds)
    }

    private class func delayCentisecondsForImageAtIndex(let source: CGImageSourceRef, let index: Int) -> Int {
        let cfProperties = CGImageSourceCopyPropertiesAtIndex(source, index, nil)
        let properties: NSDictionary = cfProperties
        let gifProperties: NSDictionary = properties.valueForKey(kCGImagePropertyGIFDictionary as! String) as! NSDictionary
        var delayTime: NSNumber = gifProperties.valueForKey(kCGImagePropertyGIFUnclampedDelayTime as! String) as! NSNumber
        if delayTime.doubleValue == 0 {
            delayTime = gifProperties.valueForKey(kCGImagePropertyGIFDelayTime as! String) as! NSNumber
        }
        return Int(delayTime.doubleValue * 1000)
    }

    private class DivisionMath {

        class func greatestCommonDivisor(array: [Int]) -> Int {
            return array.reduce(array[0]) {
                self.greatestCommonDivisorForPair($0, $1)
            }
        }

        class func greatestCommonDivisorForPair(a: Int?, _ b: Int?) -> Int {
            switch (a, b) {
            case (.None, .None):
                return 0
            case (let a, .Some(0)):
                return a!
            default:
                return greatestCommonDivisorForPair(b!, a! % b!)
            }
        }

    }

}
