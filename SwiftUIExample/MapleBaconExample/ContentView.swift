//
//  Copyright © 2019 Jan Gorman. All rights reserved.
//

import SwiftUI

struct ContentView: View {

  private static let url = URL(string: "https://www.dropbox.com/s/mlquw9k6ogvspox/MapleBacon.png?raw=1")!

  var body: some View {
    NavigationView {
      List {
        NavigationLink(destination: UICollectionViewExample(imageURLs: imageURLsFromBundle())) {
          Text("UICollectionView")
        }
        NavigationLink(destination: UIButtonExample()) {
          Text("UIButton")
        }
        NavigationLink(destination: UIImageViewExample()) {
          Text("UIImageView")
        }
        NavigationLink(destination: ImageExampleView(image: MapleBaconImage(url: Self.url))) {
          Text("Image")
        }
        NavigationLink(destination: TransformerExample()) {
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
