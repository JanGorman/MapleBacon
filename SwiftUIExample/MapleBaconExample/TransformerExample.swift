//
//  Copyright © 2019 Jan Gorman. All rights reserved.
//

import SwiftUI
import MapleBacon
import CoreImage
import UIKit

struct TransformerExample : View {
  var body: some View {
    let url = URL(string: "https://www.dropbox.com/s/mlquw9k6ogvspox/MapleBacon.png?raw=1")
    let transformer = SepiaImageTransformer().appending(transformer: VignetteImageTransformer())

    return MapleBaconImageView(url: url, transformer: transformer)
      .scaledToFit()
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

#if DEBUG
struct TransformerExample_Previews : PreviewProvider {
  static var previews: some View {
    TransformerExample()
  }
}
#endif
