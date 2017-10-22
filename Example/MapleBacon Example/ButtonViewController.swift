//
//  Copyright © 2017 Jan Gorman. All rights reserved.
//

import UIKit
import MapleBacon

final class ButtonViewController: UIViewController {

  @IBOutlet private var button: UIButton!

  override func viewDidLoad() {
    super.viewDidLoad()

    let normal = URL(string: "https://www.dropbox.com/s/mmz0uh4nc71zxxv/normal.png?raw=1")
    button.setImage(with: normal, for: .normal)
    let selected = URL(string: "https://www.dropbox.com/s/y7ltti1e0n9yvfn/selected.png?raw=1")
    button.setImage(with: selected, for: .selected)
  }

  @IBAction func toggleButton(_ sender: UIButton) {
    sender.isSelected = !sender.isSelected
  }

}
