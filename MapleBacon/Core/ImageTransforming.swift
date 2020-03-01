//
//  Copyright © 2020 Schnaub. All rights reserved.
//

import UIKit

public protocol ImageTransforming {
  /// The transformer's identifier. Any unique string.
  var identifier: String { get }

  /// The transform function to apply
  ///
  /// - Parameter image: The image to transform
  /// - Returns: The transformed image
  func transform(image: UIImage) -> UIImage?
}

infix operator >>>: AdditionPrecedence

public func >>>(transformer1: ImageTransforming, transformer2: ImageTransforming) -> ImageTransforming {
  transformer1.appending(transformer: transformer2)
}

public extension ImageTransforming {

  /// Appends one transformer to another
  ///
  /// - Parameter transformer: The transformer to append
  /// - Returns: A new transformer that will run both transformers after one another
  func appending(transformer: ImageTransforming) -> ImageTransforming {
    let chainIdentifier = identifier.appending(" -> \(transformer.identifier)")

    return BaseComposableImageTransformer(identifier: chainIdentifier) { image in
      guard let image = self.transform(image: image) else {
        return nil
      }
      return transformer.transform(image: image)
    }
  }

}

private class BaseComposableImageTransformer: ImageTransforming {

  let identifier: String
  private let call: (UIImage) -> UIImage?

  init(identifier: String, call: @escaping (UIImage) -> UIImage?) {
    self.identifier = identifier
    self.call = call
  }

  func transform(image: UIImage) -> UIImage? {
    call(image)
  }

}

func ==(lhs: ImageTransforming, rhs: ImageTransforming) -> Bool {
  lhs.identifier == rhs.identifier
}
