//
//  Copyright © 2019 Jan Gorman. All rights reserved.
//

import SwiftUI

struct UIImageViewExample : View {
  var body: some View {
    let url = URL(string: "https://www.dropbox.com/s/mlquw9k6ogvspox/MapleBacon.png?raw=1")
    return MapleBaconImageView(url: url)
      .scaledToFit()
  }
}

#if DEBUG
struct UIImageViewExample_Previews : PreviewProvider {
  static var previews: some View {
    UIImageViewExample()
  }
}
#endif
