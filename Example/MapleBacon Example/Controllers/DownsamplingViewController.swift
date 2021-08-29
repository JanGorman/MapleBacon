//
//  Copyright © 2020 Schnaub. All rights reserved.
//

import MapleBacon
import UIKit

final class DownsamplingViewController: UICollectionViewController {

  private var imageURLs: [URL] = []

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
    Task {
      let size = cell.imageView.bounds.size * UIScreen.main.scale
      await cell.imageView.setImage(from: url, scalingOption: .scaled(size: size))
    }
    return cell
  }

}

extension CGSize {
    static func * (size: CGSize, scale: CGFloat) -> CGSize {
        size.applying(CGAffineTransform(scaleX: scale, y: scale))
    }
}
