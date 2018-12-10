//
//  Copyright © 2017 Jan Gorman. All rights reserved.
//

import XCTest
import Nimble
import MapleBacon

final class ImageTransformerTests: XCTestCase {

  private class FirstDummyTransformer: ImageTransformer, CallCounting {

    let identifier = "com.schnaub.FirstDummyTransformer"

    var callCount = 0

    func transform(image: UIImage) -> UIImage? {
      callCount += 1
      return image
    }

  }

  private class SecondDummyTransformer: ImageTransformer, CallCounting {

    let identifier = "com.schnaub.SecondDummyTransformer"

    var callCount = 0

    func transform(image: UIImage) -> UIImage? {
      callCount += 1
      return image
    }

  }

  private class ThirdDummyTransformer: ImageTransformer, CallCounting {

    let identifier = "com.schnaub.ThirdDummyTransformer"

    var callCount = 0

    func transform(image: UIImage) -> UIImage? {
      callCount += 1
      return image
    }

  }

  func testItsComposable() {
    let first = FirstDummyTransformer()
    let second = SecondDummyTransformer()
    let third = ThirdDummyTransformer()

    let composed = first.appending(transformer: second).appending(transformer: third)

    expect(composed.identifier).to(beginWith(first.identifier))
    expect(composed.identifier).to(contain(second.identifier))
    expect(composed.identifier).to(endWith(third.identifier))
  }

  func testItsComposableWithCustomOperator() {
    let first = FirstDummyTransformer()
    let second = SecondDummyTransformer()
    let third = ThirdDummyTransformer()

    let composed = first >>> second >>> third

    expect(composed.identifier).to(beginWith(first.identifier))
    expect(composed.identifier).to(contain(second.identifier))
    expect(composed.identifier).to(endWith(third.identifier))
  }

  func testItCallsAllTransformers() {
    let first = FirstDummyTransformer()
    let second = SecondDummyTransformer()
    let third = ThirdDummyTransformer()

    let composed = first.appending(transformer: second).appending(transformer: third)
    let image = TestHelper().image
    _ = composed.transform(image: image)
    
    expect(first.callCount) == 1
    expect(second.callCount) == 1
    expect(third.callCount) == 1
  }

}
