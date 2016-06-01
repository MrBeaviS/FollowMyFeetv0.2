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

    @IBAction func ReturnToMap(sender: UIBarButtonItem) {
        self.dismissViewControllerAnimated(false, completion: nil)
    }
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
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        pathTable.reloadData()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        if segue.identifier == "pathSegue" {
        let destinationVC = segue.destinationViewController as! ViewController
        let viewController = destinationVC
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
        }else if segue.identifier == "send"{
            let destinationVC = segue.destinationViewController as! SendPathController
            let viewController = destinationVC
            //let rows = self.pathTable.indexPathsForSelectedRows?.map{$0.row}
            viewController.pathData = path![0]
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return path!.count;
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)
        let title: UILabel = (cell.contentView.viewWithTag(1) as? UILabel)!
        let subtitle: UILabel = (cell.contentView.viewWithTag(2) as? UILabel)!
        title.text = path[indexPath.item].name
        subtitle.text = path[indexPath.item].info
        
        return cell;
    }
    
}