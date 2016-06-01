//
//  SendPaths.swift
//  FollowMyFeet
//
//  Created by Nicholas Judd on 28/05/2016.
//  Copyright © 2016 Michael Beavis. All rights reserved.
//

import Foundation
import MultipeerConnectivity
import MapKit
protocol SPManagerDelegate {
    func foundPeer()
    
    func lostPeer()
    
    func invitationWasReceived(fromPeer: String)
    
    func connectedWithPeer(peerID: MCPeerID)
    
    func dataRecived(notification: NSNotification)
}

class SendPathManager: NSObject, MCSessionDelegate, MCNearbyServiceBrowserDelegate, MCNearbyServiceAdvertiserDelegate{
    var path: Path?
    var session: MCSession!
    var peer: MCPeerID!
    var browser: MCNearbyServiceBrowser!
    var advertiser: MCNearbyServiceAdvertiser!
    var foundPeers = [MCPeerID]()
    var invitationHandler: ((Bool, MCSession)->Void)!
    var delegate: SPManagerDelegate?
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    var data: dataAccess = dataAccess.sharedInstance
    
    override init() {
        super.init()
        
        peer = MCPeerID(displayName: UIDevice.currentDevice().name)
        session = MCSession(peer: peer)
        session.delegate = self
        browser = MCNearbyServiceBrowser(peer: peer, serviceType: "appcoda-mpc")
        browser.delegate = self
        advertiser = MCNearbyServiceAdvertiser(peer: peer, discoveryInfo: nil, serviceType: "appcoda-mpc")
        advertiser.delegate = self
    }
    
    func advertiser(advertiser: MCNearbyServiceAdvertiser, didNotStartAdvertisingPeer error: NSError) {
//        NSLog("%@", "didNotStartAdvertisingPeer: \(error)")
    }
    
    func advertiser(advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: NSData?, invitationHandler: (Bool, MCSession) -> Void) {
        self.invitationHandler = invitationHandler
        delegate?.invitationWasReceived(peerID.displayName)
    }
    
    func browser(browser: MCNearbyServiceBrowser, didNotStartBrowsingForPeers error: NSError) {
//        NSLog("%@", "didNotStartBrowsingForPeers: \(error)")
    }
    
    func browser(browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
        foundPeers.append(peerID)
        delegate?.foundPeer()
    }
    
    func browser(browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        for (index, aPeer) in foundPeers.enumerate(){
            if aPeer == peerID {
                foundPeers.removeAtIndex(index)
                break
            }
        }
        
        delegate?.lostPeer()
    }
    
    
    func session(session: MCSession, peer peerID: MCPeerID, didChangeState state: MCSessionState) {
        switch state{
        case MCSessionState.Connected:
            print("Connected to session: \(session)")
            delegate?.connectedWithPeer(peerID)
            
        case MCSessionState.Connecting:
            print("Connecting to session:")
            
        default:
            print("Did not connect to session:")
        }
    }
    
    func session(session: MCSession, didReceiveData data: NSData, fromPeer peerID: MCPeerID) {
        print("%@", "didReceiveData: \(data)")
        let dataList: [SendDataClass] = (NSKeyedUnarchiver.unarchiveObjectWithData(data)! as? [SendDataClass])!
        var pathList: [Location] = []
        for aresponse in dataList{
            print(dataList.count)
            let newCoordinate : CLLocationCoordinate2D = CLLocationCoordinate2DMake(aresponse.latitude as!  CLLocationDegrees, aresponse.longitude as! CLLocationDegrees)
            let tempLoc = self.data.createLocation(newCoordinate, latDelta: aresponse.latDelta as! CLLocationDegrees, longDelta: aresponse.longDelta as! CLLocationDegrees, name: aresponse.name!, info: aresponse.info!)
            pathList.append(tempLoc)
            print(pathList.count)
        }
        self.data.createPath("Recived", info: "Recived", loc: pathList)
        
//        NSNotificationCenter.defaultCenter().postNotificationName("receivedPDataNotification", object: data)
    }
    
    func session(session: MCSession, didReceiveStream stream: NSInputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
        NSLog("%@", "didReceiveStream")
    }
    
    func session(session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, atURL localURL: NSURL, withError error: NSError?) {
        print("%@", "didFinishReceivingResourceWithName")
    }
    
    func session(session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, withProgress progress: NSProgress) {
        print("%@", "didStartReceivingResourceWithName")
    }
    //TODO work out how to store and then send the needed data
    func sendPath(pathName : Path, index: Int) {
        var data: SendDataClass?
        var dataList: [SendDataClass] = []
        for aresponse in pathName.location!{
            data = SendDataClass(location: aresponse as! Location)
//            print(data?.name)
            dataList.append(data!)
//            print(dataList.count)
        }
        
        let dataToSend : NSData = NSKeyedArchiver.archivedDataWithRootObject(dataList)
        do {
//            print("%@", "sendingData: \(dataToSend)")
            try appDelegate.pathService.session.sendData(dataToSend, toPeers: appDelegate.pathService.foundPeers, withMode: MCSessionSendDataMode.Reliable)
        } catch let error as NSError {
            print(error.localizedDescription)
            
        }
    }
    
}

