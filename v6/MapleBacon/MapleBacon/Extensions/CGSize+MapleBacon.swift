//
//  Copyright © 2020 Schnaub. All rights reserved.
//

import UIKit

extension CGSize {
    static func * (size: CGSize, scale: CGFloat) -> CGSize {
        size.applying(CGAffineTransform(scaleX: scale, y: scale))
    }
}
