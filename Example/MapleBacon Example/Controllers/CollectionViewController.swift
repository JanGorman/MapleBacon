//
//  Copyright © 2020 Schnaub. All rights reserved.
//

import MapleBacon
import UIKit

final class CollectionViewController: UICollectionViewController {

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
      await cell.imageView.setImage(from: url)
    }
    return cell
  }
}
