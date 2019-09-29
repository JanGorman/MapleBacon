//
//  Copyright © 2019 Jan Gorman. All rights reserved.
//

import Foundation

final class MemoryCache<Key: Hashable, Value> {

  private class WrappedKey: NSObject {

    private let key: Key

    override var hash: Int {
      key.hashValue
    }

    init(key: Key) {
      self.key = key
    }

    override func isEqual(_ object: Any?) -> Bool {
      guard let value = object as? WrappedKey else {
        return false
      }
      return value.key == key
    }

  }

  private class Entry {

    let value: Value

    init(value: Value) {
      self.value = value
    }

  }

  private let wrapped = NSCache<WrappedKey, Entry>()

  init(name: String) {
    wrapped.name = name
  }

  subscript(key: Key) -> Value? {
    get {
      return value(forKey: key)
    }
    set {
      guard let value = newValue else {
        removeValue(forKey: key)
        return
      }
      insert(value, forKey: key)
    }
  }

  func insert(_ value: Value, forKey key: Key) {
    let entry = Entry(value: value)
    wrapped.setObject(entry, forKey: WrappedKey(key: key))
  }

  func value(forKey key: Key) -> Value? {
    let entry = wrapped.object(forKey: WrappedKey(key: key))
    return entry?.value
  }

  func removeValue(forKey key: Key) {
    wrapped.removeObject(forKey: WrappedKey(key: key))
  }

  func clear() {
    wrapped.removeAllObjects()
  }

}
