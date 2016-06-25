//
// Copyright (c) 2015 Zalando SE. All rights reserved.
//

import UIKit

class ResizerTestViewController: UITableViewController {

    let data = UIViewContentMode.allValues
    var selectedContentMode: UIViewContentMode?

    struct Identifiers {
        static let DefaultCellIdentifier = "Default"
        static let ShowResizerResultSegueIdentifier = "ShowResizerResult"
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: Identifiers.DefaultCellIdentifier, for: indexPath as IndexPath) as UITableViewCell
        cell.textLabel?.text = self.data[indexPath.row].simpleDescription()
        return cell
    }
    
    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        selectedContentMode = data[indexPath.row]
        return indexPath
    }

    override func prepare(for segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == Identifiers.ShowResizerResultSegueIdentifier {
            let resultVC = segue.destinationViewController as! ResizerResultViewController
            resultVC.selectedContentMode = self.selectedContentMode
        }
    }

}
