//
// Copyright (c) 2015 Zalando SE. All rights reserved.
//

import UIKit

final class ResizerResultViewController: UIViewController {

    var selectedContentMode: UIViewContentMode?

    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private var resultView: ResizerResultView!

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
