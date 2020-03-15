//
//  Copyright © 2020 Schnaub. All rights reserved.
//

import Foundation

enum TimePeriod {
    case seconds(Int)
    case minutes(Int)
    case hours(Int)
    case days(Int)

    var timeInterval: TimeInterval {
        switch self {
        case .seconds(let value):
            return TimeInterval(value)
        case .minutes(let value):
            return TimeInterval(value * 60)
        case .hours(let value):
            return TimeInterval(value * 60 * 60)
        case .days(let value):
            return TimeInterval(value * 60 * 60 * 24)
        }
    }
}

extension Int {
  var second: TimeInterval {
      TimePeriod.seconds(self).timeInterval
  }
  var seconds: TimeInterval {
      TimePeriod.seconds(self).timeInterval
  }
  var minutes: TimeInterval {
      TimePeriod.minutes(self).timeInterval
  }
  var hour: TimeInterval {
      TimePeriod.hours(self).timeInterval
  }
  var hours: TimeInterval {
      TimePeriod.hours(self).timeInterval
  }
  var days: TimeInterval {
      TimePeriod.days(self).timeInterval
  }
}
