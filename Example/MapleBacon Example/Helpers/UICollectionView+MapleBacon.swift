//
//  Copyright © 2020 Schnaub. All rights reserved.
//

import UIKit

extension UICollectionView {
  func dequeue<T>(indexPath: IndexPath) -> T {
    let id = String(describing: T.self)
    return dequeueReusableCell(withReuseIdentifier: id, for: indexPath) as! T
  }
}
