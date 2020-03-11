//
//  Copyright © 2020 Schnaub. All rights reserved.
//

import UIKit

public protocol DataConvertible {
  associatedtype Result

  static func convert(from data: Data) -> Result?

  func toData() -> Data
}

extension Data: DataConvertible {
  public static func convert(from data: Data) -> Data? {
    data
  }

  public func toData() -> Data {
    self
  }
}

extension UIImage: DataConvertible {

  private var hasAlphaChannel: Bool {
    guard let alphaInfo = cgImage?.alphaInfo else {
      return false
    }
    switch alphaInfo {
    case .first, .last, .premultipliedFirst, .premultipliedLast, .alphaOnly:
      return true
    case .none, .noneSkipFirst, .noneSkipLast:
      return false
    @unknown default:
      fatalError("Unkown alphaInfo \(alphaInfo)")
    }
  }

  public static func convert(from data: Data) -> UIImage? {
    UIImage(data: data, scale: UIScreen.main.scale)
  }

  public func toData() -> Data {
    hasAlphaChannel ? pngData()! : jpegData(compressionQuality: 1)!
  }
}
