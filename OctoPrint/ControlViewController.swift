//
//  ControlViewController.swift
//  OctoPrint
//
//  Created by Michael Teeuw on 26-07-15.
//  Copyright © 2015 Michael Teeuw. All rights reserved.
//

import UIKit

class ControlViewController: UIViewController, DirectionControlDelegate {

    let ipView = IPCameraView(frame: CGRectZero)
    let xyControl = DirectionControl()
    let zControl = DirectionControl()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Control"
        
        xyControl.delegate = self
        zControl.delegate = self
        
        makeLayout()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "startStream", key: .DidUpdateSettings, object: OPManager.sharedInstance)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "setControlState", key: .DidUpdatePrinter)
    }
    
    override func viewDidAppear(animated: Bool) {
        startStream()
    }
    
    override func viewWillDisappear(animated: Bool) {
        ipView.stop()
    }
    
    func startStream() {
        if let webcamStreamUrl = OPManager.sharedInstance.webcamStreamURL {
            ipView.hidden = false
            ipView.startWithURL(webcamStreamUrl)
        } else {
            ipView.hidden = true
        }
    }
    
    func setControlState() {
        if !OPManager.sharedInstance.printerStateFlags.printing && OPManager.sharedInstance.printerStateFlags.operational {
            xyControl.enabled = true
            zControl.enabled = true
        } else {
            xyControl.enabled = false
            zControl.enabled = false
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func makeLayout() {
        
        // Create Cam Player
        view.addSubview(ipView)
        ipView.translatesAutoresizingMaskIntoConstraints = false
        view.addConstraint(NSLayoutConstraint(item: ipView, attribute: .Width, relatedBy: .Equal, toItem: view, attribute: .Width, multiplier: 1, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: ipView, attribute: .Height, relatedBy: .Equal, toItem: view, attribute: .Width, multiplier: 3/4, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: ipView, attribute: .CenterX, relatedBy: .Equal, toItem: view, attribute: .CenterX, multiplier: 1, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: ipView, attribute: .Top, relatedBy: .Equal, toItem: view, attribute: .Top, multiplier: 1, constant: 64))
        
        ipView.backgroundColor = UIColor.blackColor()
        
        
        // Create Controls
        let controlSize:CGFloat = 200.0
        let zControlWidth:CGFloat = 50.0
        
        let controlWrapper = UIView()
        view.addSubview(controlWrapper)
        controlWrapper.translatesAutoresizingMaskIntoConstraints = false
        
        // Position the control wrapper
        view.addConstraint(NSLayoutConstraint(item: controlWrapper, attribute: .CenterX, relatedBy: .Equal, toItem: view, attribute: .CenterX, multiplier: 1, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: controlWrapper, attribute: .Bottom, relatedBy: .Equal, toItem: view, attribute: .Bottom, multiplier: 1, constant: -80))
        
        // Add the controls to the control wrapper
        controlWrapper.addSubview(xyControl)
        controlWrapper.addSubview(zControl)
        xyControl.translatesAutoresizingMaskIntoConstraints = false
        zControl.translatesAutoresizingMaskIntoConstraints = false
        
        // Make the controls the approriate size
        controlWrapper.addConstraint(NSLayoutConstraint(item: xyControl, attribute: .Width, relatedBy: .Equal, toItem: controlWrapper, attribute: .Width, multiplier: 0, constant: controlSize))
        controlWrapper.addConstraint(NSLayoutConstraint(item: xyControl, attribute: .Height, relatedBy: .Equal, toItem: controlWrapper, attribute: .Width, multiplier: 0, constant: controlSize))
        controlWrapper.addConstraint(NSLayoutConstraint(item: zControl, attribute: .Width, relatedBy: .Equal, toItem: controlWrapper, attribute: .Width, multiplier: 0, constant: zControlWidth))
        controlWrapper.addConstraint(NSLayoutConstraint(item: zControl, attribute: .Height, relatedBy: .Equal, toItem: controlWrapper, attribute: .Width, multiplier: 0, constant: controlSize))
        
        // Space the two controls
        controlWrapper.addConstraint(NSLayoutConstraint(item: xyControl, attribute: .Right, relatedBy: .Equal, toItem: zControl, attribute: .Left, multiplier: 1, constant: -25))
        
        // Glue the xycontrol to the left side, top and bottom of the wrapper
        controlWrapper.addConstraint(NSLayoutConstraint(item: xyControl, attribute: .Top, relatedBy: .Equal, toItem: controlWrapper, attribute: .Top, multiplier: 1, constant: 0))
        controlWrapper.addConstraint(NSLayoutConstraint(item: xyControl, attribute: .Bottom, relatedBy: .Equal, toItem: controlWrapper, attribute: .Bottom, multiplier: 1, constant: 0))
        controlWrapper.addConstraint(NSLayoutConstraint(item: xyControl, attribute: .Left, relatedBy: .Equal, toItem: controlWrapper, attribute: .Left, multiplier: 1, constant: 0))
        
        // Glue the zcontrol to the right side, top and bottom of the wrapper
        controlWrapper.addConstraint(NSLayoutConstraint(item: zControl, attribute: .Top, relatedBy: .Equal, toItem: controlWrapper, attribute: .Top, multiplier: 1, constant: 0))
        controlWrapper.addConstraint(NSLayoutConstraint(item: zControl, attribute: .Bottom, relatedBy: .Equal, toItem: controlWrapper, attribute: .Bottom, multiplier: 1, constant: 0))
        controlWrapper.addConstraint(NSLayoutConstraint(item: zControl, attribute: .Right, relatedBy: .Equal, toItem: controlWrapper, attribute: .Right, multiplier: 1, constant: 0))
        
        
        
        
        xyControl.backgroundColor = UIColor.clearColor()
        xyControl.pointerColor = view.tintColor
        zControl.backgroundColor = UIColor.clearColor()
        zControl.pointerColor = view.tintColor
        
        
        
        
        zControl.allowedDirection = .Vertical

        
    }
   

}


// DirectionControlDelegate Methods

extension ControlViewController {
    
    func directionControlDidRelease(directionControl: DirectionControl) {
        if directionControl == xyControl {
            if directionControl.direction == .Vertical {
                OPManager.sharedInstance.printHead.jog(x: 0, y: directionControl.valueY * 100, z: 0)
            } else {
                OPManager.sharedInstance.printHead.jog(x: directionControl.valueX * 100, y: 0, z: 0)
            }
        } else {
            OPManager.sharedInstance.printHead.jog(x: 0, y: 0, z: directionControl.valueY * -100)
        }
        
        directionControl.reset()
        
    }
    
    func directionControlDidDrag(directionControl: DirectionControl) {
        if directionControl == xyControl {
            if directionControl.direction == .Vertical {
                print("Y: \(directionControl.valueY * 100)")
            } else {
                print("X: \(directionControl.valueX * 100)")
            }
        } else {
            print("Z: \(directionControl.valueY * -100)")
        }
    }
    
    func directionControlDidTapArrow(directionControl: DirectionControl, arrow: ArrowDirection) {

        if directionControl == xyControl {
            switch arrow {
                case .Up:
                    OPManager.sharedInstance.printHead.jog(x: 0, y: -1, z: 0)
                case .Down:
                    OPManager.sharedInstance.printHead.jog(x: 0, y: 1, z: 0)
                case .Left:
                    OPManager.sharedInstance.printHead.jog(x: -1, y: 0, z: 0)
                case .Right:
                    OPManager.sharedInstance.printHead.jog(x: 1, y: 0, z: 0)
            }
        } else {
            switch arrow {
                case .Up:
                    OPManager.sharedInstance.printHead.jog(x: 0, y: 0, z: 1)
                case .Down:
                    OPManager.sharedInstance.printHead.jog(x: 0, y: 0, z: -1)
                default:
                break
            }
        }
    }
}