//
//  Copyright © 2017 Jan Gorman. All rights reserved.
//

import UIKit
import MapleBacon

final class ViewController: UICollectionViewController {

  private var imageUrls: [URL] = []

  override func viewDidLoad() {
    super.viewDidLoad()

    imageUrls = imageUrlsFromBundle()
    collectionView?.reloadData()
  }

  private func imageUrlsFromBundle() -> [URL] {
    guard let file = Bundle.main.path(forResource: "images", ofType: "plist"),
          let urlStrings = NSArray(contentsOfFile: file) as? [String] else { return [] }
    return urlStrings.map { URL(string: $0)! }
  }

  override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return imageUrls.count
  }

  override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell: ImageCell = collectionView.dequeue(indexPath: indexPath)
    cell.imageView.setImage(with: imageUrls[indexPath.item])
    return cell
  }

}
