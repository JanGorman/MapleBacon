//
//  Copyright © 2020 Schnaub. All rights reserved.
//

import MapleBacon
import UIKit

final class ImageTransformerViewController: UICollectionViewController {

  private var imageURLs: [URL] = []
  private var imageTransformer = SepiaImageTransformer()

  override func viewDidLoad() {
    super.viewDidLoad()

    imageURLs = imageURLsFromBundle()
    collectionView?.reloadData()
  }

  private func imageURLsFromBundle() -> [URL] {
    let file = Bundle.main.path(forResource: "images", ofType: "plist")!
    let urls = NSArray(contentsOfFile: file) as! [String]
    return urls.compactMap(URL.init(string:))
  }

  override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    imageURLs.count
  }

  override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell: ImageCollectionViewCell = collectionView.dequeue(indexPath: indexPath)
    let url = imageURLs[indexPath.item]
    cell.imageView.setImage(with: url, displayOptions: [.downsampled], imageTransformer: imageTransformer)
    return cell
  }

}

private class SepiaImageTransformer: ImageTransforming {

  let identifier = "com.schnaub.SepiaImageTransformer"

  func transform(image: UIImage) -> UIImage? {
    let filter = CIFilter(name: "CISepiaTone")!

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
