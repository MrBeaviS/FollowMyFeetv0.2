//
//  SendPathController.swift
//  FollowMyFeet
//
//  Created by Nicholas Judd on 28/05/2016.
//  Copyright © 2016 Michael Beavis. All rights reserved.
//

import Foundation
import UIKit

class SendPathController: UIViewController {
    let pathService = SendPathManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        pathService.delegate = self
        foundPeer()
    }
}

extension SendPathController : SendPathManagerDelegate {
    
    func connectedDevicesChanged(manager: SendPathManager, connectedDevices: [String]) {
        NSOperationQueue.mainQueue().addOperationWithBlock { () -> Void in
            //print("Connections: \(connectedDevices)")
            //print(connectedDevices.count)
        }
    }
    
    func foundPeer() {
        print(pathService.foundPeers)
    }
    
    
    func pathChanged(manager: SendPathManager, colorString: String) {
        NSOperationQueue.mainQueue().addOperationWithBlock { () -> Void in}
    }
    
}