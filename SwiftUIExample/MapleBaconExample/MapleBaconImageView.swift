//
//  Copyright © 2019 Jan Gorman. All rights reserved.
//

import SwiftUI
import MapleBacon
import UIKit

struct MapleBaconImageView: UIViewRepresentable {

  let url: URL?
  let transformer: ImageTransformer?

  init(url: URL?, transformer: ImageTransformer? = nil) {
    self.url = url
    self.transformer = transformer
  }
  
  func makeUIView(context: Context) -> UIImageView {
    let view = UIImageView(frame: .zero)
    view.setImage(with: url, transformer: transformer)
    return view
  }
  
  func updateUIView(_ uiView: UIImageView, context: Context) {
    
  }
  
}

#if DEBUG
struct MapleBaconImageView_Previews : PreviewProvider {
  static var previews: some View {
    let url = URL(string: "https://www.dropbox.com/s/mlquw9k6ogvspox/MapleBacon.png?raw=1")
    return MapleBaconImageView(url: url).scaledToFit()
  }
}
#endif
