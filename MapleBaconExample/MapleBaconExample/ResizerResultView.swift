//
// Copyright (c) 2015 Zalando SE. All rights reserved.
//

import UIKit
import MapleBacon

class ResizerResultView: UIView {

    var image: UIImage?
    var selectedContentMode: UIViewContentMode?
    let deviceScale = UIScreen.mainScreen().scale

    override func drawRect(rect: CGRect) {
        if let contentMode = selectedContentMode, let image = image {
            Resizer.resizeImage(image, contentMode: contentMode, toSize: rect.size,
                    interpolationQuality: kCGInterpolationHigh, async: false) {
                resizedImage in
                let xOffset = rect.size.width > resizedImage.size.width / self.deviceScale ? (rect.size.width - resizedImage.size.width / self.deviceScale) / 2 : 0
                let yOffset = rect.size.height > resizedImage.size.height / self.deviceScale ? (rect.size.height - resizedImage.size.height / self.deviceScale) / 2 : 0
                resizedImage.drawInRect(CGRectMake(xOffset, yOffset, resizedImage.size.width / self.deviceScale, resizedImage.size.height / self.deviceScale))
            }
        }
    }

}
