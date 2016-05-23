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
        
        let destinationVC = segue.destinationViewController as! UINavigationController
        let viewController = destinationVC.viewControllers[0] as! ViewController
        var locationList: [Location] = []
        let rows = self.locationTable.indexPathsForSelectedRows?.map{$0.row}
        if rows != nil{
            for index in 0..<rows!.count{
                locationList.append(locs![rows![index]])
                viewController.locs.removeAll()
                viewController.locs = locationList
            }
            if locationList.count > 1 {
                viewController.providedPath = true
                viewController.providedLocation = false
            }else {
                viewController.providedLocation = true
                viewController.providedPath = false
            }
        }
    }
    
    
    
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        checkCount()
        
    }
    
    func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath){
        checkCount()
    }
    
    func checkCount(){
        if let list = self.locationTable.indexPathsForSelectedRows {
            if list.count == 0 {
                viewMap.title = "Create Location"
            }else if list.count == 1 {
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