//
//  Copyright © 2020 Schnaub. All rights reserved.
//

import MapleBacon
import UIKit

final class PrefetchViewController: UICollectionViewController {

  private var imageURLs: [URL] = []

  override func viewDidLoad() {
    super.viewDidLoad()

    imageURLs = imageURLsFromBundle()
    collectionView.prefetchDataSource = self
    collectionView?.reloadData()
  }

  private func imageURLsFromBundle() -> [URL] {
    let file = Bundle.main.path(forResource: "images", ofType: "plist")!
    let urls = NSArray(contentsOfFile: file) as! [String]
    return urls.compactMap { URL(string: $0) }
  }

  override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    imageURLs.count
  }

  override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell: ImageCollectionViewCell = collectionView.dequeue(indexPath: indexPath)
    let url = imageURLs[indexPath.item]
    cell.imageView.setImage(with: url)
    return cell
  }

}

extension PrefetchViewController: UICollectionViewDataSourcePrefetching {

  func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
    for indexPath in indexPaths {
      let url = imageURLs[indexPath.item]
      MapleBacon.shared.hydrateCache(url: url)
    }
  }

}
