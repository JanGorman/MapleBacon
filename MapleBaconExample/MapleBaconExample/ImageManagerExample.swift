//
// Copyright (c) 2015 Zalando SE. All rights reserved.
//

import UIKit
import MapleBacon

final class ImageCell: UICollectionViewCell {

    @IBOutlet fileprivate var imageView: UIImageView?

    override func prepareForReuse() {
        super.prepareForReuse()
        imageView?.image = nil
    }

}

final class ImageExampleViewController: UICollectionViewController {

    fileprivate var imageURLs = ["http://media.giphy.com/media/lI6nHr5hWXlu0/giphy.gif"]

    override func viewDidLoad() {
        super.viewDidLoad()
        if let file = Bundle.main.path(forResource: "imageURLs", ofType: "plist"),
           let paths = NSArray(contentsOfFile: file) as? [String] {
                for url in paths {
                    imageURLs.append(url)
                }
        }
        collectionView?.reloadData()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let gradient = CAGradientLayer()
        gradient.frame = view.frame
        gradient.colors = [UIColor(red: 127 / 255, green: 187 / 255, blue: 154 / 255, alpha: 1).cgColor,
                           UIColor(red: 14 / 255, green: 43 / 255, blue: 57 / 255, alpha: 1).cgColor]
        view.layer.insertSublayer(gradient, at: 0)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        MapleBaconStorage.sharedStorage.clearMemoryStorage()
    }

    @IBAction func clearCache(_ sender: AnyObject) {
        MapleBaconStorage.sharedStorage.clearStorage()
    }

}

extension ImageExampleViewController {

    // MARK: UICollectionViewDataSource

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageURLs.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageCell", for: indexPath) as! ImageCell
        if let imageURL = URL(string: imageURLs[(indexPath as NSIndexPath).row]) {
            cell.imageView?.setImageWithURL(imageURL) { _, error in
                guard error == nil else { return }
                cell.imageView?.layer.add(CATransition(), forKey: nil)
            }
        }
        return cell
    }

}
