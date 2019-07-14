//
//  Copyright © 2019 Jan Gorman. All rights reserved.
//

import UIKit

func imageURLsFromBundle() -> [URL] {
  guard let file = Bundle.main.path(forResource: "images", ofType: "plist"),
        let urlStrings = NSArray(contentsOfFile: file) as? [String] else {
      return []
  }
  return urlStrings.compactMap { URL(string: $0) }
}

extension UICollectionView {

  func dequeue<T>(indexPath: IndexPath) -> T {
    let id = String(describing: T.self)
    return dequeueReusableCell(withReuseIdentifier: id, for: indexPath) as! T
  }

  final func registerNib(ofType type: AnyClass) {
    let id = String(describing: type.self)
    register(UINib(nibName: id, bundle: nil), forCellWithReuseIdentifier: id)
  }

}
