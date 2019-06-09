//
//  Copyright © 2019 Jan Gorman. All rights reserved.
//

import SwiftUI
import MapleBacon
import UIKit

struct UICollectionViewExample : View {

  let imageURLs: [URL]

  var body: some View {
    UICollectionViewWrapper(imageURLs: imageURLs)
  }

}

#if DEBUG
struct UICollectionViewExample_Previews : PreviewProvider {
  static var previews: some View {
    UICollectionViewExample(imageURLs: imageURLsFromBundle())
  }
}
#endif
