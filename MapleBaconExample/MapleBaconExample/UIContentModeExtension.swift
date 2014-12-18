//
//  Copyright (c) 2014 Zalando SE. All rights reserved.
//

import UIKit

extension UIViewContentMode {

    func simpleDescription() -> String {
        switch self {
        case .ScaleToFill:
            return "ScaleToFill"
        case .ScaleAspectFit:
            return "ScaleAspectFit"
        case .ScaleAspectFill:
            return "ScaleAspectFill"
        case .Redraw:
            return "Redraw"
        case .Center:
            return "Center"
        case .Top:
            return "Top"
        case .Bottom:
            return "Bottom"
        case .Left:
            return "Left"
        case .Right:
            return "Right"
        case .TopLeft:
            return "TopLeft"
        case .TopRight:
            return "TopRight"
        case .BottomLeft:
            return "BottomLeft"
        case .BottomRight:
            return "BottomRight"
        }
    }

    static let allValues = [ScaleToFill, ScaleAspectFit, ScaleAspectFill, Redraw,
                            Center, Top, Bottom, Left, Right, TopLeft, TopRight, BottomLeft, BottomRight]

}
