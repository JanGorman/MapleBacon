//
// Copyright (c) 2015 Zalando SE. All rights reserved.
//

import UIKit
import MapleBacon

final class ResizerResultView: UIView {

    var image: UIImage?
    var selectedContentMode: UIViewContentMode?
    let deviceScale = UIScreen.main.scale

    override func draw(_ rect: CGRect) {
        if let contentMode = selectedContentMode, let image = image {
            Resizer.resize(image: image, contentMode: contentMode, toSize: rect.size, interpolationQuality: .high,
                           async: false) { resizedImage in
                            let xOffset = self.xOffset(forImage: resizedImage, fittingRect: rect)
                            let yOffset = self.yOffset(forImage: resizedImage, fittingRect: rect)
                            let rect = CGRect(x: xOffset, y: yOffset, width: resizedImage.size.width / self.deviceScale,
                                              height: resizedImage.size.height / self.deviceScale)
                            resizedImage.draw(in: rect)
            }
        }
    }
  
  private func xOffset(forImage image: UIImage, fittingRect rect: CGRect) -> CGFloat {
    return rect.size.width > image.size.width / deviceScale ? (rect.size.width - image.size.width / deviceScale) / 2 : 0
  }
  
  private func yOffset(forImage image: UIImage, fittingRect rect: CGRect) -> CGFloat {
    return rect.size.height > image.size.height / deviceScale ? (rect.size.height - image.size.height / deviceScale) / 2 : 0
  }

}
