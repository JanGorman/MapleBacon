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

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(Identifiers.DefaultCellIdentifier, forIndexPath: indexPath) as UITableViewCell
        cell.textLabel?.text = data[indexPath.row].simpleDescription()
        return cell
    }

    override func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
        selectedContentMode = data[indexPath.row]
        return indexPath
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == Identifiers.ShowResizerResultSegueIdentifier {
            let resultVC = segue.destinationViewController as ResizerResultViewController
            resultVC.selectedContentMode = self.selectedContentMode
        }
    }

}
