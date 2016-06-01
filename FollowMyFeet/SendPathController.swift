//
//  SendPathController.swift
//  FollowMyFeet
//
//  Created by Nicholas Judd on 28/05/2016.
//  Copyright © 2016 Michael Beavis. All rights reserved.
//

import Foundation
import UIKit
import MultipeerConnectivity
import MapKit
class SendPathController: UIViewController, UITableViewDataSource, UITableViewDelegate  {
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    let pathService = SendPathManager()
    var pathData: Path? = nil
    var dataList : [SendDataClass]?
    var data: dataAccess = dataAccess.sharedInstance
    @IBOutlet weak var peerTable: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        appDelegate.pathService.delegate = self
        appDelegate.pathService.browser.startBrowsingForPeers()
        //appDelegate.pathService.advertiser.startAdvertisingPeer()
        peerTable.delegate = self
        peerTable.dataSource = self
        foundPeer()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        
            let destinationVC = segue.destinationViewController as! ViewController
            let viewController = destinationVC
            viewController.providedPath = true
            viewController.providedLocation = false
            var pathList: [Location] = []
            for aresponse in dataList!{
                let newCoordinate : CLLocationCoordinate2D = CLLocationCoordinate2DMake(aresponse.latitude as!  CLLocationDegrees, aresponse.longitude as! CLLocationDegrees)
                 let tempLoc = self.data.createLocation(newCoordinate, latDelta: aresponse.latDelta as! CLLocationDegrees, longDelta: aresponse.longDelta as! CLLocationDegrees, name: aresponse.name!, info: aresponse.info!)
                pathList.append(tempLoc)
            }
            viewController.locs.removeAll()
            viewController.locs = pathList
       
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return appDelegate.pathService.foundPeers.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell")! as UITableViewCell
        cell.textLabel?.text = appDelegate.pathService.foundPeers[indexPath.item].displayName
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let selectedPeer = appDelegate.pathService.foundPeers[indexPath.row] as MCPeerID
        appDelegate.pathService.browser.invitePeer(selectedPeer, toSession: appDelegate.pathService.session, withContext: nil, timeout: 20)
        

    }
}

extension SendPathController : SPManagerDelegate {
    
    func foundPeer() {
        print(appDelegate.pathService.foundPeers)
        peerTable.reloadData()
    }
    
    func lostPeer() {
        peerTable.reloadData()

    }
    
    func invitationWasReceived(fromPeer: String) {
        let alert = UIAlertController(title: "", message: "\(fromPeer) wants to chat with you.", preferredStyle: UIAlertControllerStyle.Alert)
        
        let acceptAction: UIAlertAction = UIAlertAction(title: "Accept", style: UIAlertActionStyle.Default) { (alertAction) -> Void in
            self.appDelegate.pathService.invitationHandler(true, self.appDelegate.pathService.session)
        }
        
        let declineAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel) { (alertAction) -> Void in
            self.appDelegate.pathService.invitationHandler(false, self.appDelegate.pathService.session)
        }
        
        alert.addAction(acceptAction)
        alert.addAction(declineAction)
        
        NSOperationQueue.mainQueue().addOperationWithBlock { () -> Void in
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    func connectedWithPeer(peerID: MCPeerID) {
        NSOperationQueue.mainQueue().addOperationWithBlock { () -> Void in
            self.appDelegate.pathService.sendPath(self.pathData!, index: 0)
            NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(SendPathController.dataRecived(_:)), name: "receivedPDataNotification", object: nil)
        }
    }
    
    func dataRecived(notification: NSNotification){
        // Get the dictionary containing the data and the source peer from the notification.
//        let receivedData = notification.object as! NSData
//        
//        // Convert the data (NSData) into a Dictionary object.
//        dataList = NSKeyedUnarchiver.unarchiveObjectWithData(receivedData)! as? [SendDataClass]
//        var pathList: [Location] = []
//        for aresponse in dataList!{
//            print(dataList!.count)
//            let newCoordinate : CLLocationCoordinate2D = CLLocationCoordinate2DMake(aresponse.latitude as!  CLLocationDegrees, aresponse.longitude as! CLLocationDegrees)
//            let tempLoc = self.data.createLocation(newCoordinate, latDelta: aresponse.latDelta as! CLLocationDegrees, longDelta: aresponse.longDelta as! CLLocationDegrees, name: aresponse.name!, info: aresponse.info!)
//            pathList.append(tempLoc)
//            print(pathList.count)
//        }
//        self.data.createPath("test", info: "test", loc: pathList)
//        var pathName: String?
//        var pathInfo: String?
//        let addPathAlert = UIAlertController(title:  "Add a Path",message: "Path Details", preferredStyle: UIAlertControllerStyle.Alert)
//        addPathAlert.addTextFieldWithConfigurationHandler { (textField: UITextField!) -> Void in
//            textField.placeholder = "Enter Path Name"
//        }
//        addPathAlert.addTextFieldWithConfigurationHandler { (textField: UITextField!) -> Void in
//            textField.placeholder = "Enter Path Info"
//        }
//        let cancelButton = UIAlertAction(title: "Cancel", style: .Default) { (alert: UIAlertAction!) -> Void in
//            addPathAlert.dismissViewControllerAnimated(true, completion: nil)
//        }
//        let createPathButton = UIAlertAction(title: "Create Path", style: .Default) { (alert: UIAlertAction!) -> Void in
//            if let text = addPathAlert.textFields![0].text where !text.isEmpty {
//                pathName = text
//            }
//            if let text = addPathAlert.textFields![1].text where !text.isEmpty {
//                pathInfo = text
//            }
//            //sentinel to guard against user not entering pathInfo
//            if let pInfo = pathInfo{
//                print(pathList.count)
//                self.data.createPath(pathName!, info: pInfo, loc: pathList)
//            } else {
//                self.data.createPath(pathName!, info: "", loc: pathList)
//            }
//            
////        }
//        addPathAlert.addAction(cancelButton)
//        addPathAlert.addAction(createPathButton)
//        presentViewController(addPathAlert, animated:true, completion: nil)
    }

}