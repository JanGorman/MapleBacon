//
//  Copyright © 2017 Jan Gorman. All rights reserved.
//

import UIKit
import MapleBacon

final class ImageViewController: UIViewController {

  @IBOutlet private var imageView: UIImageView! {
    didSet {
      UIApplication.shared.isNetworkActivityIndicatorVisible = true
      let url = URL(string: "https://www.dropbox.com/s/mlquw9k6ogvspox/MapleBacon.png?raw=1")
      imageView.setImage(with: url, placeholder: #imageLiteral(resourceName: "placeholder"), progress: { progress, total in
        self.downloadProgressView.progress = Float(progress) / Float(total)
      }, completion: { [weak self] _ in
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
        self?.downloadProgressView.isHidden = true
      })
    }
  }
  @IBOutlet private var downloadProgressView: UIProgressView!

}
