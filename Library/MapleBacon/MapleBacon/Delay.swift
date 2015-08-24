//
//  Copyright (c) 2015 Zalando SE. All rights reserved.
//

import Foundation

func delay(delay: Double, closure: () -> Void) {
    let time = dispatch_time(DISPATCH_TIME_NOW, Int64(delay * Double(NSEC_PER_SEC)))
    dispatch_after(time, dispatch_get_main_queue(), closure)
}
