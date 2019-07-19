//
//  Copyright © 2019 Jan Gorman. All rights reserved.
//

import UIKit

func resizedImage(from image: UIImage?, for size: CGSize, scale: CGFloat = UIScreen.main.scale) -> UIImage? {
  guard let image = image else {
    return nil
  }
  let factor = CGAffineTransform(scaleX: scale, y: scale)
  let sizeInPixels = size.applying(factor)
  let renderer = UIGraphicsImageRenderer(size: sizeInPixels)
  return renderer.image { _ in
    image.draw(in: CGRect(origin: .zero, size: sizeInPixels))
  }
}
