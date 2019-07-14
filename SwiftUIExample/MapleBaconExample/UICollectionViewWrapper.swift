//
//  Copyright © 2019 Jan Gorman. All rights reserved.
//

import SwiftUI
import UIKit

struct UICollectionViewWrapper: UIViewRepresentable {

  private enum Section {
    case main
  }

  let imageURLs: [URL]

  private let collectionView: UICollectionView
  private var dataSource: UICollectionViewDiffableDataSource<Section, URL>!

  init(imageURLs: [URL]) {
    self.imageURLs = imageURLs

    let view = UICollectionView(frame: .zero, collectionViewLayout: Self.createLayout())
    view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    view.backgroundColor = .white
    view.registerNib(ofType: ImageViewCell.self)
    collectionView = view

    dataSource = UICollectionViewDiffableDataSource<Section, URL>(collectionView: collectionView) {
      (collectionView, indexPath, url) -> UICollectionViewCell? in
      let cell = collectionView.dequeue(indexPath: indexPath) as ImageViewCell
      cell.imageView.setImage(with: url)
      return cell
    }
  }

  func makeUIView(context: Context) -> UICollectionView {
    let snapshot = NSDiffableDataSourceSnapshot<Section, URL>()
    snapshot.appendSections([.main])
    snapshot.appendItems(imageURLs)
    dataSource.apply(snapshot, animatingDifferences: false)

    return collectionView
  }

  func updateUIView(_ uiView: UICollectionView, context: Context) {
  }

  private static func createLayout() -> UICollectionViewLayout {
    let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                          heightDimension: .fractionalHeight(1))
    let item = NSCollectionLayoutItem(layoutSize: itemSize)

    let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                           heightDimension: .absolute(100))
    let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: 2)
    let spacing: CGFloat = 10
    group.interItemSpacing = .fixed(spacing)

    let section = NSCollectionLayoutSection(group: group)
    section.interGroupSpacing = spacing

    let layout = UICollectionViewCompositionalLayout(section: section)
    return layout
  }

}

#if DEBUG
struct UICollectionViewWrapper_Previews : PreviewProvider {
  static var previews: some View {
    UICollectionViewWrapper(imageURLs: imageURLsFromBundle())
  }
}
#endif
