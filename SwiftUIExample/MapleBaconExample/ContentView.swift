//
//  Copyright © 2019 Jan Gorman. All rights reserved.
//

import SwiftUI

struct ContentView : View {
  var body: some View {
    NavigationView {
      List {
        Text("UICollectionView")
        NavigationButton(destination: UIButtonExample()) {
          Text("UIButton")
        }
        NavigationButton(destination: UIImageViewExample()) {
          Text("UIImageView")
        }
        NavigationButton(destination: TransformerExample()) {
          Text("Image Transformer")
        }
      }.navigationBarTitle(Text("Examples"))
    }
  }
}

#if DEBUG
struct ContentView_Previews : PreviewProvider {
  static var previews: some View {
    ContentView()
  }
}
#endif
