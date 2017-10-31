//
//  Copyright © 2017 Jan Gorman. All rights reserved.
//

import UIKit

/// The ImageTransformer protocol. Custom image transforms may conform to this protocol and register with MapleBacon.
/// To apply multiple transformers to an image you can chain them together into a pipeline using the
/// `appending(transformer:)` function. This will give you a new processor which can then be used.
public protocol ImageTransformer {

  /// The transformer's identifier. Any unique string.
  var identifier: String { get }

  /// The transform function to apply
  ///
  /// - Parameter image: The image to transform
  /// - Returns: The transformed image
  func transform(image: UIImage) -> UIImage?

}

public extension ImageTransformer {

  /// Appends one transformer to another
  ///
  /// - Parameter transformer: The transformer to append
  /// - Returns: A new transformer that will run both transformers after one another
  public func appending(transformer: ImageTransformer) -> ImageTransformer {
    let chainIdentifier = identifier.appending(" -> \(transformer.identifier)")

    return BaseComposableImageTransformer(identifier: chainIdentifier) { image in
      guard let image = self.transform(image: image) else { return nil }
      return transformer.transform(image: image)
    }
  }

}

private class BaseComposableImageTransformer: ImageTransformer {

  let identifier: String
  private let call: (UIImage) -> UIImage?

  init(identifier: String, call: @escaping (UIImage) -> UIImage?) {
    self.identifier = identifier
    self.call = call
  }

  func transform(image: UIImage) -> UIImage? {
    return call(image)
  }

}

func ==(lhs: ImageTransformer, rhs: ImageTransformer) -> Bool {
  return lhs.identifier == rhs.identifier
}
