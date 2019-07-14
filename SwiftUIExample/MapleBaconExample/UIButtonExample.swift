//
//  Copyright © 2019 Jan Gorman. All rights reserved.
//

import SwiftUI

struct UIButtonExample: View {
  var body: some View {
    MapleBaconButton()
  }
}

#if DEBUG
struct UIButtonExample_Previews : PreviewProvider {
  static var previews: some View {
    UIButtonExample()
  }
}
#endif
