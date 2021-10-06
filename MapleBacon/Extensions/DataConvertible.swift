//
//  Copyright © 2020 Schnaub. All rights reserved.
//

import UIKit

public protocol DataConvertible {
  associatedtype Result

  static func convert(from data: Data) -> Result?

  func toData() -> Data?
}

extension Data: DataConvertible {
  public static func convert(from data: Data) -> Data? {
    data
  }

  public func toData() -> Data? {
    self
  }
}

extension UIImage: DataConvertible {

  public static func convert(from data: Data) -> UIImage? {
    UIImage(data: data, scale: UIScreen.main.scale)
  }

  public func toData() -> Data? {
    let mutableData = NSMutableData()
    let options: NSDictionary = [
        kCGImageDestinationLossyCompressionQuality: 1
    ]
    guard
      let source = cgImage,
      let data = source.dataProvider?.data,
      let type = ImageType.fromData(data as Data),
      let destination = CGImageDestinationCreateWithData(mutableData as CFMutableData, type.rawValue as CFString, 1, nil)
    else {
      return nil
    }

    CGImageDestinationAddImage(destination, source, options)
    CGImageDestinationFinalize(destination)
    return mutableData as Data
  }
}

enum ImageType: String {
  case png = "public.png"
  case jpg = "public.jpeg"

  static func fromData(_ data: Data) -> Self? {
    func _match(_ prefixes: [UInt8?]) -> Bool {
      guard data.count >= prefixes.count else {
        return false
      }
      return zip(prefixes.indices, prefixes).allSatisfy { index, `prefix` in
        guard index < data.count else {
          return false
        }
        return data[index] == `prefix`
      }
    }

    if _match([0xFF, 0xD8, 0xFF]) {
      return .jpg
    }
    if _match([0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A]) {
      return .png
    }

    return nil
  }
}
