//
//  LoadingScreen.swift
//  FollowMyFeet
//
//  Created by Nicholas Judd on 28/05/2016.
//  Copyright © 2016 Michael Beavis. All rights reserved.
//

import Foundation
import UIKit
class LoadingScreen: UIViewController {
    @IBOutlet weak var loading: UIImageView!
    override func viewDidLoad() {
        let imageGif: [UIImage] = [UIImage(named: "walkingshoe1")!,
                        UIImage(named: "walkingshoe2")!,
                        UIImage(named: "walkingshoe3")!,
                        UIImage(named: "walkingshoe4")!,
                        UIImage(named: "walkingshoe5")!,
                        UIImage(named: "walkingshoe6")!,
                        UIImage(named: "walkingshoe7")!,
                        UIImage(named: "walkingshoe8")!,
                        UIImage(named: "walkingshoe9")!,
                        UIImage(named: "walkingshoe10")!,
                        UIImage(named: "walkingshoe11")!,
                        UIImage(named: "walkingshoe12")!]
 
        loading.animationImages = imageGif;
        loading.animationDuration = 0.5
        loading.startAnimating()
        UIView.animateWithDuration(5.0, delay: 0.0, options: .AllowAnimatedContent, animations: {
            self.loading.frame = CGRect(x: 0,y: 0, width: self.view.frame.width * 4, height: self.view.frame.width * 4)
        }, completion: nil)
        
        let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(6 * Double(NSEC_PER_SEC)))
        dispatch_after(delayTime, dispatch_get_main_queue()) {
            self.triggerSegue()
        }
    }

    func triggerSegue(){
        performSegueWithIdentifier("animationDone", sender: nil)
    }
}