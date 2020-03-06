//
//  Copyright © 2020 Schnaub. All rights reserved.
//

import Foundation

/// Container structure that associates two keys with a single value.
/// Internally it keeps two Dictionaries, the first associates the keys with one another
/// and the second one associates one of the keys with the value. To ensure that remove
/// and insert are as fast as possible, removing a value for the second key type will not
/// remove it from the lookup map. Since the link between the keys is broken, this won't
/// lead to unexpected values but bear in mind that the lookup Dictionary will grow indefinitely.
final class DoubleKeyedContainer<FirstKey: Hashable, SecondKey: Hashable, Value> {

  private var firstContainer: [FirstKey: SecondKey] = [:]
  private var secondContainer: [SecondKey: Value] = [:]

  subscript(_ key: FirstKey) -> Value? {
    get {
      guard let lookup = firstContainer[key] else {
        return nil
      }
      return secondContainer[lookup]
    }
  }

  subscript(_ key: SecondKey) -> Value? {
    get {
      secondContainer[key]
    }
  }

  func insert(_ value: Value, forKeys keys: (FirstKey, SecondKey)) {
    firstContainer[keys.0] = keys.1
    secondContainer[keys.1] = value
  }

  func update(_ value: Value, forKey key: FirstKey) {
    guard let lookup = firstContainer[key] else {
      return
    }
    secondContainer[lookup] = value
  }

  func update(_ value: Value, forKey key: SecondKey) {
    secondContainer[key] = value
  }

  func removeValue(forKeys: (FirstKey, SecondKey)) {
    firstContainer[forKeys.0] = nil
    secondContainer[forKeys.1] = nil
  }

  func removeValue(forKey key: FirstKey) {
    guard let lookup = firstContainer[key] else {
      return
    }
    removeValue(forKeys: (key, lookup))
  }

  func removeValue(forKey key: SecondKey) {
    secondContainer[key] = nil
  }

}
