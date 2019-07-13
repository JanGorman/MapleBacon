//
//  Copyright © 2019 Jan Gorman. All rights reserved.
//

import SwiftUI
import Foundation
import Combine
import MapleBacon

final class MapleBaconImage: BindableObject {

  private let url: URL

  var didChange = PassthroughSubject<UIImage?, Never>()

  private(set) var image: UIImage? {
    didSet {
      didChange.send(image)
    }
  }

  init(url: URL) {
    self.url = url
  }

  func fetch() {
    _ = MapleBacon.shared.image(with: url).sink { image in
      self.image = image
    }
  }

}
