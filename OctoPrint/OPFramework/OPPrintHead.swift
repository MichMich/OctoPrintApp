//
//  OPPrintHead.swift
//  OctoPrint
//
//  Created by Michael Teeuw on 31-07-15.
//  Copyright © 2015 Michael Teeuw. All rights reserved.
//

import Foundation

class OPPrintHead : OPComponent {
    static var apiTask = OPAPITask(endPoint: "printer/printhead")

    var identifier:String
    
    var componentType:OPComponentType {
        get {
            return .PrintHead
        }
    }
    
    var updatedAt:NSDate = NSDate() {
        didSet {
            OPManager.notificationCenter.postNotificationKey(.DidUpdateComponent, object: self)
        }
    }
    
    required init(identifier: String) {
        self.identifier = identifier
    }
    
    func jog(x x:Float, y:Float, z:Float) {
        OPPrintHead.apiTask.parameters([
            "command": "jog",
            "x": x,
            "y": y,
            "z": z,
        ]).method(.POST).onSuccess({ (json)->() in
            OPManager.notificationCenter.postNotificationKey(.DidSetPrinterBed, object: self)
        }).fire()
    }
    
}