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
class PathTabController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var data: dataAccess = dataAccess.sharedInstance
    @IBOutlet weak var pathTable: UITableView!
    var path: [Path]!
    //var destionationLocation: CLLocation?
    var pathBool: Bool = false
    override func viewDidLoad() {
        super.viewDidLoad()
        pathTable.delegate = self
        pathTable.dataSource = self
        
        path = data.getAllPaths()
        print(path.count)
        for i in path{
            print(i.name)
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        
        let destinationVC = segue.destinationViewController as! UINavigationController
        let viewController = destinationVC.viewControllers[0] as! ViewController
        viewController.providedPath = true
        viewController.providedLocation = false
        var pathList: [Location] = []
        
        let rows = self.pathTable.indexPathsForSelectedRows?.map{$0.row}
        let pathToSend: Path = path![rows![0]]
        for aresponse in pathToSend.location!{
            pathList.append(aresponse as! Location)
        }
        viewController.locs.removeAll()
        viewController.locs = pathList
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return path!.count;
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)
        cell.textLabel?.text = path[indexPath.item].name
        cell.detailTextLabel?.text = path[indexPath.item].info
        return cell;
    }
    
}