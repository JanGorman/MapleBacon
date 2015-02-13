//
// Copyright (c) 2015 Zalando SE. All rights reserved.
//

import Foundation
import UIKit
import MapleBacon

class ImageCell: UICollectionViewCell {

    @IBOutlet weak var imageView: UIImageView?

    override func prepareForReuse() {
        self.imageView?.image = nil
    }
}

class ImageExampleViewController: UICollectionViewController {

    var imageURLs = ["http://media.giphy.com/media/lI6nHr5hWXlu0/giphy.gif"]

    override func viewDidLoad() {
        if let file = NSBundle.mainBundle().pathForResource("imageURLs", ofType: "plist") {
            if let paths = NSArray(contentsOfFile: file) {
                for url in paths {
                    imageURLs.append(url as! String)
                }
            }
        }

        collectionView?.reloadData()
        super.viewDidLoad()
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        let gradient = CAGradientLayer()
        gradient.frame = view.frame
        gradient.colors = [UIColor(red: 127 / 255, green: 187 / 255, blue: 154 / 255, alpha: 1).CGColor,
                           UIColor(red: 14 / 255, green: 43 / 255, blue: 57 / 255, alpha: 1).CGColor]
        view.layer.insertSublayer(gradient, atIndex: 0)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        MapleBaconStorage.sharedStorage.clearMemoryStorage()
    }

    @IBAction func clearCache(sender: AnyObject) {
        MapleBaconStorage.sharedStorage.clearStorage()
    }

    // MARK: UICollectionViewDataSource

    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageURLs.count
    }

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("ImageCell", forIndexPath: indexPath) as! ImageCell
        var url = imageURLs[indexPath.row]
        if let imageURL = NSURL(string: imageURLs[indexPath.row]) {
            cell.imageView?.setImageWithURL(imageURL) {
                (imageInstance, error) in
                if error == nil {
                    let transition = CATransition()
                    cell.imageView?.layer.addAnimation(transition, forKey: "fade")
                }
            }
        }
        return cell
    }
}
