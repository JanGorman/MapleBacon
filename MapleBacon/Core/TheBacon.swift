//
//  Copyright © 2021 Schnaub. All rights reserved.
//

import Foundation
import UIKit

public final class TheBacon {

  public enum ScalingOption {
    case none
    case scaled(size: CGSize)
  }

  public static let shared = TheBacon()

  private let imageDownloader: ImageDownloader

  init(sessionConfiguration: URLSessionConfiguration = .default) {
    imageDownloader = ImageDownloader(sessionConfiguration: sessionConfiguration)
  }

  public func image(from url: URL, scalingOption: ScalingOption = .none) async throws -> UIImage {
    let image = try await imageDownloader.image(from: url)

    switch scalingOption {
    case .none:
      return image
    case let .scaled(size):
      return await image.byPreparingThumbnail(ofSize: size)!
    }
  }

}
