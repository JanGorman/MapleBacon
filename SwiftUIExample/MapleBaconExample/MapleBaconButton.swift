//
//  Copyright © 2019 Jan Gorman. All rights reserved.
//

import SwiftUI
import MapleBacon
import UIKit

struct MapleBaconButton : UIViewRepresentable {
  
  func makeUIView(context: Context) -> UIButton {
    let button = UIButton()
    let normal = URL(string: "https://www.dropbox.com/s/mmz0uh4nc71zxxv/normal.png?raw=1")
    button.setImage(with: normal, for: .normal)
    let selected = URL(string: "https://www.dropbox.com/s/y7ltti1e0n9yvfn/selected.png?raw=1")
    button.setImage(with: selected, for: .selected)
    return button
  }
  
  func updateUIView(_ uiView: UIButton, context: Context) {
    
  }
  
}

#if DEBUG
struct MapleBaconButton_Previews : PreviewProvider {
  static var previews: some View {
    MapleBaconButton()
  }
}
#endif
