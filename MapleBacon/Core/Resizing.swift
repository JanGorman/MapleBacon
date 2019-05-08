//
//  Copyright © 2019 Jan Gorman. All rights reserved.
//

import UIKit

func resizedImage(from image: UIImage?, for size: CGSize) -> UIImage? {
  guard let image = image else {
    return nil
  }
  let renderer = UIGraphicsImageRenderer(size: size)
  return renderer.image { _ in
    image.draw(in: CGRect(origin: .zero, size: size))
  }
}
