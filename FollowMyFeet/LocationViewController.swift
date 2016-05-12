//
//  LocationViewController.swift
//  FollowMyFeet
//
//  Created by Nicholas Judd on 11/05/2016.
//  Copyright © 2016 Michael Beavis. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class LocationViewController: UITableViewController {
    var data: dataAccess = dataAccess.sharedInstance
    var locs: [Location]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("test")
        locs = data.getAllLocations()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        let destinationVC = segue.destinationViewController as! UINavigationController
        let viewController = destinationVC.viewControllers[0] as! ViewController
        if (segue.identifier == "Cell") {
            print("Im Here")
            let selectedRow = self.tableView.indexPathForCell(sender as! UITableViewCell)
            viewController.longitude = locs![selectedRow!.item].longitude
            viewController.latitude = locs![selectedRow!.item].latitude
        }
        
    }
    
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return locs!.count;
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)
            let location: Location = self.locs![indexPath.item]
            let title: UILabel = (cell.contentView.viewWithTag(2) as? UILabel)!
            let subtitle: UILabel = (cell.contentView.viewWithTag(3) as? UILabel)!
            let date: UILabel = (cell.contentView.viewWithTag(4) as? UILabel)!
            let dateFormatter        = NSDateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd | HH:mm"
            let dateString = dateFormatter.stringFromDate(location.dateCreated!)
            title.text = location.name
            subtitle.text = location.info
            date.text = dateString
            return cell;
    }
    
    /*override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        
        if editingStyle == .Delete {
            let cellID = collectionTable.cellForRowAtIndexPath(indexPath)! as UITableViewCell
            if (indexPath.row != 0){
                SBM.findAndDeleteCollection(cellID.textLabel!.text!)
                collectionTable.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
            }
        }
    }*/
}