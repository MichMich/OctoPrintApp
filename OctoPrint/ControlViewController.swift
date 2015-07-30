//
//  ControlViewController.swift
//  OctoPrint
//
//  Created by Michael Teeuw on 26-07-15.
//  Copyright © 2015 Michael Teeuw. All rights reserved.
//

import UIKit

class ControlViewController: UIViewController {

    let ipView = IPCameraView(frame: CGRectZero)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Control"
        
        
        view.addSubview(ipView)
        ipView.translatesAutoresizingMaskIntoConstraints = false
        view.addConstraint(NSLayoutConstraint(item: ipView, attribute: .Width, relatedBy: .Equal, toItem: view, attribute: .Width, multiplier: 1, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: ipView, attribute: .Height, relatedBy: .Equal, toItem: view, attribute: .Width, multiplier: 3/4, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: ipView, attribute: .CenterX, relatedBy: .Equal, toItem: view, attribute: .CenterX, multiplier: 1, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: ipView, attribute: .Top, relatedBy: .Equal, toItem: view, attribute: .Top, multiplier: 1, constant: 64))
        
        ipView.backgroundColor = UIColor.blackColor()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "startStream", key: .DidUpdateSettings, object: OPManager.sharedInstance)
        

        startStream()
    }
    
    func startStream() {
        if let webcamStreamUrl = OPManager.sharedInstance.webcamStreamURL {
            ipView.hidden = false
            ipView.startWithURL(webcamStreamUrl)
        } else {
            ipView.hidden = true
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

   

}
