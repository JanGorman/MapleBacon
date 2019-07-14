//
//  Copyright © 2019 Jan Gorman. All rights reserved.
//

import SwiftUI
import MapleBacon

struct ImageExampleView : View {

  @ObjectBinding var image: MapleBaconImage

  var body: some View {
    VStack {
      if image.image != nil {
        Image(uiImage: image.image!)
      } else {
        Text("Loading")
      }
    }
    .onAppear {
      self.image.fetch()
    }
  }

}

#if DEBUG
struct ImageExampleView_Previews : PreviewProvider {
  static var previews: some View {
    let url = URL(string: "https://www.dropbox.com/s/mlquw9k6ogvspox/MapleBacon.png?raw=1")!
    return ImageExampleView(image: MapleBaconImage(url: url))
  }
}
#endif
