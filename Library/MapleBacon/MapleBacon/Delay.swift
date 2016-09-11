//
//  Copyright (c) 2015 Zalando SE. All rights reserved.
//

import Foundation

/// Delay execution by some DispatchTimeInterval. Runs on the main thread.
///
/// - Parameter by: The DispatchTimeInterval to delay execution by
/// - Parameter closure: The closure to run.
func delay(by delay: DispatchTimeInterval, closure: @escaping () -> Void) {
    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + delay, execute: closure)
}
