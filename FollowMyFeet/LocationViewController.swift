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
import MapKit
class LocationViewController: UITableViewController {
    @IBAction func viewLocationOrPath(sender: AnyObject) {
    }
    @IBOutlet var locationTable: UITableView!
    @IBOutlet weak var viewMap: UIButton!
    var data: dataAccess = dataAccess.sharedInstance
    var locs: [Location]!
    var destionationLocation: CLLocation?
    var pathBool: Bool = false
    override func viewDidLoad() {
        super.viewDidLoad()
        locs = data.getAllLocations()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        let destinationVC = segue.destinationViewController as! UINavigationController
        let viewController = destinationVC.viewControllers[0] as! ViewController
        if (segue.identifier == "PathOrLocation") {
            var L: [Location] = []
            let rows = self.tableView.indexPathsForSelectedRows?.map{$0.row}
            for index in 0..<rows!.count{
                L.append(locs![rows![index]])
                viewController.locs.removeAll()
                viewController.locs = L
            }
                if pathBool {
                    viewController.providedPath = true
                    viewController.providedLocation = false
                }else {
                    viewController.providedLocation = true
                    viewController.providedPath = false
                }
            
           
        }
    
    }
    @IBAction func unwindToLocationController(segue: UIStoryboardSegue){
        locs = data.getAllLocations()
        self.locationTable.reloadData()
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        checkCount()
    }
    
    override func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath){
        
        viewMap.enabled = false
        checkCount()
    }
    
    func checkCount(){
        if let list = tableView.indexPathsForSelectedRows {
            if list.count > 1 {
                viewMap.enabled = true
                viewMap.setTitle("View Path", forState: .Normal)
                pathBool = true
            }else if list.count == 1 {
                viewMap.enabled = true
                viewMap.setTitle("View Location", forState: .Normal)
                pathBool = false
            }
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
    
    //need to write and implement delete
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