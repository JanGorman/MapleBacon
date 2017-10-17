//
//  Copyright © 2017 Jan Gorman. All rights reserved.
//

import UIKit

final class ImageCell: UICollectionViewCell {

  @IBOutlet private(set) var imageView: UIImageView!

  override func prepareForReuse() {
    super.prepareForReuse()
    imageView.image = nil
  }

}
