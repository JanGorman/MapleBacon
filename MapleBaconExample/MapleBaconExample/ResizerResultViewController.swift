//
// Copyright (c) 2015 Zalando SE. All rights reserved.
//

import UIKit

class ResizerResultViewController: UIViewController {

    var selectedContentMode: UIViewContentMode?

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var resultView: ResizerResultView!

    override func viewDidLoad() {
        super.viewDidLoad()
        if let contentMode = selectedContentMode {
            title = contentMode.simpleDescription()
            imageView.contentMode = contentMode
            resultView.image = imageView.image
            resultView.selectedContentMode = contentMode
        }
    }

}
