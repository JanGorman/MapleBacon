//
//  Copyright © 2020 Schnaub. All rights reserved.
//

import MapleBacon
import XCTest

final class ImageTransformingTests: XCTestCase {

  func testComposition() throws {
    let first = FirstDummyTransformer()
    let second = SecondDummyTransformer()
    let third = ThirdDummyTransformer()

    let composed = first.appending(transformer: second).appending(transformer: third)

    XCTAssertTrue(composed.identifier.hasPrefix(first.identifier))
    XCTAssertTrue(composed.identifier.contains(second.identifier))
    XCTAssertTrue(composed.identifier.hasSuffix(third.identifier))
  }

  func testOperatorComposition() {
    let first = FirstDummyTransformer()
    let second = SecondDummyTransformer()
    let third = ThirdDummyTransformer()

    let composed = first >>> second >>> third

    XCTAssertTrue(composed.identifier.hasPrefix(first.identifier))
    XCTAssertTrue(composed.identifier.contains(second.identifier))
    XCTAssertTrue(composed.identifier.hasSuffix(third.identifier))
  }

  func testTransfomerCalling() {
    let first = FirstDummyTransformer()
    let second = SecondDummyTransformer()
    let third = ThirdDummyTransformer()

    let composed = first.appending(transformer: second).appending(transformer: third)
    _ = composed.transform(image: makeImage())

    XCTAssertEqual(first.callCount, 1)
    XCTAssertEqual(second.callCount, 1)
    XCTAssertEqual(third.callCount, 1)
  }

}

private class FirstDummyTransformer: ImageTransforming {

  let identifier = "com.schnaub.FirstDummyTransformer"

  var callCount = 0

  func transform(image: UIImage) -> UIImage? {
    callCount += 1
    return image
  }

}

private class SecondDummyTransformer: ImageTransforming {

  let identifier = "com.schnaub.SecondDummyTransformer"

  var callCount = 0

  func transform(image: UIImage) -> UIImage? {
    callCount += 1
    return image
  }

}

private class ThirdDummyTransformer: ImageTransforming {

  let identifier = "com.schnaub.ThirdDummyTransformer"

  var callCount = 0

  func transform(image: UIImage) -> UIImage? {
    callCount += 1
    return image
  }

}
