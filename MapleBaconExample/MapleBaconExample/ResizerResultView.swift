//
// Copyright (c) 2015 Zalando SE. All rights reserved.
//

import UIKit
import MapleBacon

class ResizerResultView: UIView {

    var image: UIImage?
    var selectedContentMode: UIViewContentMode?
    let deviceScale = UIScreen.main().scale

    override func draw(_ rect: CGRect) {
        if
            let contentMode = selectedContentMode,
            let image = image
        {
            let resizer = Resizer(image: image)
            resizer.resize(toSize: rect.size, contentMode: contentMode, interpolationQuality: CGInterpolationQuality.high, async: false) {
                (resizedImage) in
                
                let xOffset = rect.size.width > resizedImage.size.width / self.deviceScale ? (rect.size.width - resizedImage.size.width / self.deviceScale) / 2 : 0
                let yOffset = rect.size.height > resizedImage.size.height / self.deviceScale ? (rect.size.height - resizedImage.size.height / self.deviceScale) / 2 : 0
                resizedImage.draw(in: CGRect(x: xOffset, y: yOffset, width: resizedImage.size.width / self.deviceScale, height: resizedImage.size.height / self.deviceScale))
            }
        }
    }
}
