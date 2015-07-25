//
//  OPBed.swift
//  OctoPrint
//
//  Created by Michael Teeuw on 25-07-15.
//  Copyright © 2015 Michael Teeuw. All rights reserved.
//

import Foundation


class OPBed : OPHeatedComponent {
    
    static var apiTask = OPAPITask(endPoint: "printer/bed")
    
    override var componentType:OPComponentType {
        get {
            return .Bed
        }
    }
    
    
    // Methods
    
    override func setTargetTemperature(targetTemperature:Float) {

        OPBed.apiTask.parameters([
            "command": "target",
            "target": targetTemperature
        ]).method(.POST).onSuccess({ (json)->() in
                //self.broadcastNotification(.DidSetPrinterBed)
        }).fire()
    }

}