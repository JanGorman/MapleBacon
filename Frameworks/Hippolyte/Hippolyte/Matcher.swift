//
//  Copyright © 2017 Jan Gorman. All rights reserved.
//

import Foundation

public class Matcher: Hashable {

  func matches(string: String?) -> Bool {
    return false
  }

  func matches(data: Data?) -> Bool {
    return false
  }

  func isEqual(to other: Matcher) -> Bool {
    return false
  }

  public var hashValue: Int {
    return 0
  }

  public static func ==(lhs: Matcher, rhs: Matcher) -> Bool {
    return lhs.isEqual(to: rhs)
  }

}

public protocol Matcheable {

  func matcher() -> Matcher

}

public class StringMatcher: Matcher {

  let string: String

  public init(string: String) {
    self.string = string
  }

  public override func matches(string: String?) -> Bool {
    return self.string == string
  }

  public override func matches(data: Data?) -> Bool {
    return self.string.data(using: .utf8) == data
  }

  public override var hashValue: Int {
    return string.hashValue
  }

  override func isEqual(to other: Matcher) -> Bool {
    if let o = other as? StringMatcher {
      return o.string == string
    }
    return false
  }

}

public class RegexMatcher: Matcher {

  let regex: NSRegularExpression

  public init(regex: NSRegularExpression) {
    self.regex = regex
  }

  public override func matches(string: String?) -> Bool {
    guard let string = string else { return false }
    return regex.numberOfMatches(in: string, options: [], range: NSRange(string.startIndex..., in: string)) > 0
  }

  public override var hashValue: Int {
    return regex.hashValue
  }

  override func isEqual(to other: Matcher) -> Bool {
    if let o = other as? RegexMatcher {
      return o.regex == regex
    }
    return false
  }

}

public class DataMatcher: Matcher {

  let data: Data

  public init(data: Data) {
    self.data = data
  }

  public override func matches(data: Data?) -> Bool {
    return self.data == data
  }

  public override var hashValue: Int {
    return data.hashValue
  }

  override func isEqual(to other: Matcher) -> Bool {
    if let o = other as? DataMatcher {
      return o.data == data
    }
    return false
  }

}
