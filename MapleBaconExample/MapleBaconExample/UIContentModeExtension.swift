//
// Copyright (c) 2015 Zalando SE. All rights reserved.
//

import UIKit

extension UIViewContentMode {

    func simpleDescription() -> String {
        switch self {
        case .scaleToFill:
            return "ScaleToFill"
        case .scaleAspectFit:
            return "ScaleAspectFit"
        case .scaleAspectFill:
            return "ScaleAspectFill"
        case .redraw:
            return "Redraw"
        case .center:
            return "Center"
        case .top:
            return "Top"
        case .bottom:
            return "Bottom"
        case .left:
            return "Left"
        case .right:
            return "Right"
        case .topLeft:
            return "TopLeft"
        case .topRight:
            return "TopRight"
        case .bottomLeft:
            return "BottomLeft"
        case .bottomRight:
            return "BottomRight"
        }
    }

    static let allValues = [scaleToFill, scaleAspectFit, scaleAspectFill, redraw, center, top, bottom, left, right,
                            topLeft, topRight, bottomLeft, bottomRight]

}
