//
//  Copyright © 2019 Jan Gorman. All rights reserved.
//

import SwiftUI
import Foundation
import Combine
import MapleBacon

final class MapleBaconImage: ObservableObject {

  private let url: URL

  @Published var image: UIImage? = nil

  init(url: URL) {
    self.url = url
  }

  func fetch() {
    _ = MapleBacon.shared.image(with: url).sink { image in
      self.image = image
    }
  }

}
