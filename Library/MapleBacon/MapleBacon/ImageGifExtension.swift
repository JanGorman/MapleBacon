//
// Copyright (c) 2015 Zalando SE. All rights reserved.
//

import UIKit
import ImageIO

extension UIImage {

    static func imageWithCachedData(_ data: Data) -> UIImage? {
        guard !data.isEmpty else { return nil }
        return isAnimatedImage(data) ? animatedImageWithData(data) : UIImage(data: data)
    }

    private static func animatedImageWithData(_ data: Data) -> UIImage? {
        let source = CGImageSourceCreateWithData(data as CFData, nil)
        return UIImage.animatedImageWithSource(source)
    }

    private static func isAnimatedImage(_ data: Data) -> Bool {
        var length = UInt16(0)
        (data as NSData).getBytes(&length, range: NSRange(location: 0, length: 2))
        return CFSwapInt16(length) == 0x4749
    }

    private static func animatedImageWithSource(_ source: CGImageSource!) -> UIImage? {
        let (images, delays) = createImagesAndDelays(source)
        let gifDuration = delays.reduce(0, +)
        let frames = framesFromImages(images, delays: delays)
        return UIImage.animatedImage(with: frames, duration: Double(gifDuration) / 1000.0)
    }

    private static func framesFromImages(_ images: [CGImage], delays: [Int]) -> [UIImage] {
        let gcd = DivisionMath.greatestCommonDivisor(delays)
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

    private static func createImagesAndDelays(_ source: CGImageSource) -> ([CGImage], [Int]) {
        let count = Int(CGImageSourceGetCount(source))
        var images = [CGImage]()
        var delayCentiseconds = [Int]()
        for i in 0 ..< count {
            if let image = CGImageSourceCreateImageAtIndex(source, i, nil) {
                images.append(image)
                delayCentiseconds.append(delayCentisecondsForImageAtIndex(source, index: i))
            }
        }
        return (images, delayCentiseconds)
    }

    private static func delayCentisecondsForImageAtIndex(_ source: CGImageSource, index: Int) -> Int {
        guard let properties = CGImageSourceCopyPropertiesAtIndex(source, index, nil) as? NSDictionary else { return -1 }
        if let gifProperties = properties[kCGImagePropertyGIFDictionary as String] as? NSDictionary {
            var delayTime = gifProperties[kCGImagePropertyGIFUnclampedDelayTime as String] as! NSNumber
            if delayTime.doubleValue == 0 {
                delayTime = gifProperties[kCGImagePropertyGIFDelayTime as String] as! NSNumber
            }
            return Int(delayTime.doubleValue * 1000)
        }
        return -1
    }

    private final class DivisionMath {

        static func greatestCommonDivisor(_ array: [Int]) -> Int {
            return array.reduce(array[0]) { self.greatestCommonDivisorForPair($0, $1) }
        }

        static func greatestCommonDivisorForPair(_ a: Int?, _ b: Int?) -> Int {
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
