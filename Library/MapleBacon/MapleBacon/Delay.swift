//
//  Copyright (c) 2015 Zalando SE. All rights reserved.
//

import Foundation

func delay(delay: Double, closure: () -> Void) {
    
    let time = DispatchTime.now() + Double(Int64(delay * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
    DispatchQueue.main.after(when: time, execute: closure)
}
