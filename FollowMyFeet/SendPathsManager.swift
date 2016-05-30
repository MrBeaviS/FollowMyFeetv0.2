//
//  SendPaths.swift
//  FollowMyFeet
//
//  Created by Nicholas Judd on 28/05/2016.
//  Copyright © 2016 Michael Beavis. All rights reserved.
//

import Foundation
import MultipeerConnectivity

protocol SendPathManagerDelegate {
    
    func connectedDevicesChanged(manager : SendPathManager, connectedDevices: [String])
    func foundPeer()
    func pathChanged(manager : SendPathManager, colorString: String)
    
}

class SendPathManager: NSObject{
    private let pathServiceType = "Path"
    var foundPeers = [MCPeerID]()
    private let myPeerId = MCPeerID(displayName: UIDevice.currentDevice().name)
    private let serviceAdvertiser: MCNearbyServiceAdvertiser
    private let serviceBrowser : MCNearbyServiceBrowser
    var delegate : SendPathManagerDelegate?
    
    override init() {
        print("TEST MULTIPEER")
        self.serviceAdvertiser = MCNearbyServiceAdvertiser(peer: myPeerId, discoveryInfo: nil, serviceType: pathServiceType)
        self.serviceBrowser = MCNearbyServiceBrowser(peer: myPeerId, serviceType: pathServiceType)
        super.init()
        self.serviceAdvertiser.delegate = self
        self.serviceAdvertiser.startAdvertisingPeer()
        self.serviceBrowser.delegate = self
        self.serviceBrowser.startBrowsingForPeers()
    }
    
    deinit {
        self.serviceAdvertiser.stopAdvertisingPeer()
        self.serviceBrowser.stopBrowsingForPeers()
    }
    
    func sendPath(path : Path) {
        NSLog("%@", "sendColor: \(path)")
        let pathData = NSKeyedArchiver.archivedDataWithRootObject(path)
        NSUserDefaults().setObject(pathData, forKey: "path")
        if session.connectedPeers.count > 0 {
            do {
                try self.session.sendData(pathData, toPeers: self.session.connectedPeers, withMode: MCSessionSendDataMode.Unreliable)
            } catch let error as NSError {
                print(error)
            }
        }
        
    }
    
    lazy var session : MCSession = {
        let session = MCSession(peer: self.myPeerId, securityIdentity: nil, encryptionPreference: MCEncryptionPreference.Required)
        session.delegate = self
        return session
    }()
}


extension MCSessionState {
    
    func stringValue() -> String {
        switch(self) {
        case .NotConnected: return "NotConnected"
        case .Connecting: return "Connecting"
        case .Connected: return "Connected"
        }
    }
    
}


extension SendPathManager: MCNearbyServiceAdvertiserDelegate {
    
    func advertiser(advertiser: MCNearbyServiceAdvertiser, didNotStartAdvertisingPeer error: NSError) {
        print("didNotStartAdvertisingPeer: \(error)")
    }
    
    func advertiser(advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: NSData?, invitationHandler: (Bool, MCSession) -> Void) {
        print("didReceiveInvitationFromPeer \(peerID)")
        invitationHandler(true, self.session)
    }
}

extension SendPathManager : MCNearbyServiceBrowserDelegate {
    func browser(browser: MCNearbyServiceBrowser, didNotStartBrowsingForPeers error: NSError) {
        print("%@", "didNotStartBrowsingForPeers: \(error)")
    }
    
    
    func browser(browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        /*for (index, aPeer) in foundPeers{
            if aPeer == peerID {
                foundPeers.removeAtIndex(index)
                break
            }
        }*/
        print("%@", "lostPeer: \(peerID)")
    }
    
    func browser(browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
        print("foundPeer: \(peerID)")
        print("invitePeer: \(peerID)")
        foundPeers.append(peerID)
        
        delegate?.foundPeer()
        //browser.invitePeer(peerID, toSession: self.session, withContext: nil, timeout: 10)
    }
}

extension SendPathManager : MCSessionDelegate {
    
    func session(session: MCSession, peer peerID: MCPeerID, didChangeState state: MCSessionState) {
        print("%@", "peer \(peerID) didChangeState: \(state.stringValue())")
        self.delegate?.connectedDevicesChanged(self, connectedDevices: session.connectedPeers.map({$0.displayName}))

    }
    
    func session(session: MCSession, didReceiveData data: NSData, fromPeer peerID: MCPeerID) {
        print("%@", "didReceiveData: \(data)")
        if let loadedData = NSUserDefaults().dataForKey("path") {
            
            if let loadedPath = NSKeyedUnarchiver.unarchiveObjectWithData(loadedData) as? Path {
                print("to send a path \(loadedPath)")
            }
        }
    }
    
    func session(session: MCSession, didReceiveStream stream: NSInputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
        print("%@", "didReceiveStream")
    }
    
    func session(session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, atURL localURL: NSURL, withError error: NSError?) {
        print("%@", "didFinishReceivingResourceWithName")
    }
    
    func session(session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, withProgress progress: NSProgress) {
        print("%@", "didStartReceivingResourceWithName")
    }
    
}