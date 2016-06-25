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

    private var imageURLs = ["http://media.giphy.com/media/lI6nHr5hWXlu0/giphy.gif"]

    override func viewDidLoad() {
        super.viewDidLoad()
        if let file = Bundle.main().pathForResource("imageURLs", ofType: "plist"),
           paths = NSArray(contentsOfFile: file) as? [String] {
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

    @IBAction func clearCache(sender: AnyObject) {
        MapleBaconStorage.sharedStorage.clear()
    }

}

extension ImageExampleViewController {

    // MARK: UICollectionViewDataSource

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageURLs.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell: ImageCell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageCell", for: indexPath) as? ImageCell else {
            return UICollectionViewCell()
        }
        
        if let imageURL = URL(string: imageURLs[indexPath.row]) {
            cell.imageView?.setImage(withUrl: imageURL) {
                _, error in
                
                if nil == error {
                    cell.imageView?.layer.add(CATransition(), forKey: nil)
                }
            }
        }
        
        return cell
    }

}
