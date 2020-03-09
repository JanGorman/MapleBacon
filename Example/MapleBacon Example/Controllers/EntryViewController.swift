//
//  Copyright © 2020 Schnaub. All rights reserved.
//

import MapleBacon
import UIKit

final class EntryViewController: UITableViewController {

  @IBAction private func clearCache(_ sender: Any) {
    MapleBacon.shared.clearCache(.all)
  }

}
