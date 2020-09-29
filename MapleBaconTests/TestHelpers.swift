//
//  Copyright © 2020 Schnaub. All rights reserved.
//

import UIKit
import MapleBacon

func dummyData() -> Data {
  let string = #function + #file
  return Data(string.utf8)
}

func makeImage() -> UIImage {
  let renderer = UIGraphicsImageRenderer(size: .init(width: 10, height: 10))
  return renderer.image { context in
    UIColor.black.setFill()
    context.fill(renderer.format.bounds)
  }
}

func makeImageData() -> Data {
  makeImage().pngData()!
}

final class FirstDummyTransformer: ImageTransforming {

  let identifier = "com.schnaub.FirstDummyTransformer"

  var callCount = 0

  func transform(image: UIImage) -> UIImage? {
    callCount += 1
    return image
  }

}

final class SecondDummyTransformer: ImageTransforming {

  let identifier = "com.schnaub.SecondDummyTransformer"

  var callCount = 0

  func transform(image: UIImage) -> UIImage? {
    callCount += 1
    return image
  }

}

final class ThirdDummyTransformer: ImageTransforming {

  let identifier = "com.schnaub.ThirdDummyTransformer"

  var callCount = 0

  func transform(image: UIImage) -> UIImage? {
    callCount += 1
    return image
  }

}
