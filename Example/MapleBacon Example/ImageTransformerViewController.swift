//
//  Copyright © 2017 Jan Gorman. All rights reserved.
//

import UIKit
import CoreImage
import MapleBacon

final class ImageTransformerViewController: UIViewController {

  @IBOutlet private var imageView: UIImageView! {
    didSet {
      let url = URL(string: "https://www.dropbox.com/s/mlquw9k6ogvspox/MapleBacon.png?raw=1")
      // MapleBacon only takes a single transformer but you can easily chain multiple transformers
      // into one via the appending(transformer:) method
      let transformer = SepiaImageTransformer().appending(transformer: VignetteImageTransformer())
      imageView.setImage(with: url, placeholder: #imageLiteral(resourceName: "placeholder"), transformer: transformer)
    }
  }

}

private class SepiaImageTransformer: ImageTransformer {

  let identifier = "com.schnaub.SepiaImageTransformer"

  func transform(image: UIImage) -> UIImage? {
    guard let filter = CIFilter(name: "CISepiaTone") else {
      return image
    }

    let ciImage = CIImage(image: image)
    filter.setValue(ciImage, forKey: kCIInputImageKey)
    filter.setValue(0.5, forKey: kCIInputIntensityKey)

    let context = CIContext()
    guard let outputImage = filter.outputImage,
          let cgImage = context.createCGImage(outputImage, from: outputImage.extent) else {
            return image
    }

    return UIImage(cgImage: cgImage)
  }

}

private class VignetteImageTransformer: ImageTransformer {

  let identifier = "com.schnaub.VignetteImageTransformer"

  func transform(image: UIImage) -> UIImage? {
    guard let filter = CIFilter(name: "CIVignette") else {
      return image
    }

    let ciImage = CIImage(image: image)
    filter.setValue(ciImage, forKey: kCIInputImageKey)

    let context = CIContext()
    guard let outputImage = filter.outputImage,
          let cgImage = context.createCGImage(outputImage, from: outputImage.extent) else {
            return image
    }

    return UIImage(cgImage: cgImage)
  }

}
