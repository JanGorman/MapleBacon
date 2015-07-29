//
// Copyright (c) 2015 Zalando SE. All rights reserved.
//

import UIKit
import MapleBacon

class ImageCell: UICollectionViewCell {
    @IBOutlet weak var imageView: UIImageView?
    override func prepareForReuse() {
        super.prepareForReuse()
        self.imageView?.image = nil
    }
}

class ImageExampleViewController: UICollectionViewController {

    var imageURLs = ["http://media.giphy.com/media/lI6nHr5hWXlu0/giphy.gif"]

    override func viewDidLoad() {
        super.viewDidLoad()
        if let file = NSBundle.mainBundle().pathForResource("imageURLs", ofType: "plist"),
           let paths = NSArray(contentsOfFile: file) {
                for url in paths {
                    imageURLs.append(url as! String)
                }
        }

        collectionView?.reloadData()
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
        MapleBaconStorage.sharedStorage.clearStorage()
    }

    @IBAction func clearCache(sender: AnyObject) {
        MapleBaconStorage.sharedStorage.clearStorage()
    }

}

extension ImageExampleViewController {

    // MARK: UICollectionViewDataSource

    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageURLs.count
    }

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("ImageCell", forIndexPath: indexPath) as! ImageCell
        let url = imageURLs[indexPath.row]
        if let imageURL = NSURL(string: imageURLs[indexPath.row]) {
            cell.imageView?.setImageWithURL(imageURL) {
                (_, error) in
                if error == nil {
                    let transition = CATransition()
                    cell.imageView?.layer.addAnimation(transition, forKey: "fade")
                }
            }
        }
        return cell
    }

}
