//
//  LocationViewController.swift
//  FollowMyFeet
//
//  Created by Nicholas Judd on 11/05/2016.
//  Copyright © 2016 Michael Beavis. All rights reserved.
//
//extrea icons from https://icons8.com/
import Foundation
import UIKit
import CoreData
import MapKit
class LocationTabController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBAction func ReturnToMap(sender: UIBarButtonItem) {
        self.dismissViewControllerAnimated(false, completion: nil)

    }
    @IBAction func saveAPath(sender: AnyObject) {
        var pathName: String?
        var pathInfo: String?
        let addPathAlert = UIAlertController(title:  "Add a Path",message: "Path Details", preferredStyle: UIAlertControllerStyle.Alert)
        addPathAlert.addTextFieldWithConfigurationHandler { (textField: UITextField!) -> Void in
            textField.placeholder = "Enter Path Name"
        }
        addPathAlert.addTextFieldWithConfigurationHandler { (textField: UITextField!) -> Void in
            textField.placeholder = "Enter Path Info"
        }
        let cancelButton = UIAlertAction(title: "Cancel", style: .Default) { (alert: UIAlertAction!) -> Void in
            addPathAlert.dismissViewControllerAnimated(true, completion: nil)
        }
        let createPathButton = UIAlertAction(title: "Create Path", style: .Default) { (alert: UIAlertAction!) -> Void in
            if let text = addPathAlert.textFields![0].text where !text.isEmpty {
                pathName = text
            }
            if let text = addPathAlert.textFields![1].text where !text.isEmpty {
                pathInfo = text
            }
            let locationList: [Location] = self.getSelectedLocations()
            self.data.createPath(pathName!, info: pathInfo!, loc: locationList)
        }
        addPathAlert.addAction(cancelButton)
        addPathAlert.addAction(createPathButton)
        presentViewController(addPathAlert, animated:true, completion: nil)
    }
    
    @IBOutlet weak var viewMap: UIBarButtonItem!
    @IBOutlet weak var locationTable: UITableView!
    var data: dataAccess = dataAccess.sharedInstance
    var locs: [Location]!
    var destionationLocation: CLLocation?
    var pathBool: Bool = false
    override func viewDidLoad() {
        super.viewDidLoad()
        locationTable.delegate = self
        locationTable.dataSource = self
        locs = data.getAllLocations()
    }
    
    @IBAction func unwindToLocationTabController(segue: UIStoryboardSegue){
        locs = data.getAllLocations()
        self.locationTable.reloadData()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        
        let destinationVC = segue.destinationViewController as! ViewController
        let viewController = destinationVC
        let locationList: [Location] = getSelectedLocations()
        viewController.locs.removeAll()
        viewController.locs = locationList
            if locationList.count > 1 {
                viewController.providedPath = true
                viewController.providedLocation = false
            }else {
                viewController.providedLocation = true
                viewController.providedPath = false
            }
        
    }
    
    func getSelectedLocations() -> [Location] {
        var locationList: [Location] = []
        let rows = self.locationTable.indexPathsForSelectedRows?.map{$0.row}
        if rows != nil{
            for index in 0..<rows!.count{
                locationList.append(locs![rows![index]])
                
            }
        }
        return locationList
    }
    
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        checkCount()
        
    }
    
    func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath){
        checkCount()
    }
    
    func checkCount(){
        if let list = self.locationTable.indexPathsForSelectedRows {
            if list.count == 1 {
                viewMap.enabled = true
                viewMap.title = "View Location"
            }else if list.count > 1 {
                viewMap.title = "View Path"
            }
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return locs!.count;
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
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
    
}