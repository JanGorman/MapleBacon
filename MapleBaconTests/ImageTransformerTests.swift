//
//  Copyright © 2017 Jan Gorman. All rights reserved.
//

import XCTest
import MapleBacon

class ImageTransformerTests: XCTestCase {

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

    XCTAssertTrue(composed.identifier.contains(first.identifier))
    XCTAssertTrue(composed.identifier.contains(second.identifier))
    XCTAssertTrue(composed.identifier.contains(third.identifier))
  }

  func testItsComposableWithCustomOperator() {
    let first = FirstDummyTransformer()
    let second = SecondDummyTransformer()
    let third = ThirdDummyTransformer()

    let composed = first >>> second >>> third

    XCTAssertTrue(composed.identifier.contains(first.identifier))
    XCTAssertTrue(composed.identifier.contains(second.identifier))
    XCTAssertTrue(composed.identifier.contains(third.identifier))
  }

  func testItCallsAllTransformers() {
    let first = FirstDummyTransformer()
    let second = SecondDummyTransformer()
    let third = ThirdDummyTransformer()

    let composed = first.appending(transformer: second).appending(transformer: third)
    let image = TestHelper().testImage()
    _ = composed.transform(image: image)

    XCTAssertEqual(first.callCount, 1)
    XCTAssertEqual(second.callCount, 1)
    XCTAssertEqual(third.callCount, 1)
  }

}
