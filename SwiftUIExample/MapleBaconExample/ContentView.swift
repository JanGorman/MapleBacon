//
//  Copyright © 2019 Jan Gorman. All rights reserved.
//

import SwiftUI

struct ContentView : View {
  var body: some View {
    NavigationView {
      List {
        NavigationButton(destination: UICollectionViewExample(imageURLs: imageURLsFromBundle())) {
          Text("UICollectionView")
        }
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
