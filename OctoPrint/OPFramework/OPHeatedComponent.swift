//
//  OPHeatedComponent.swift
//  OctoPrint
//
//  Created by Michael Teeuw on 25-07-15.
//  Copyright © 2015 Michael Teeuw. All rights reserved.
//

import Foundation




class OPHeatedComponent : OPComponent {
    
    // Properties
    
    var identifier:String
    var componentType:OPComponentType {
        get {
            assert(false, "OPHeatedComponent should not be used directly.")
        }
    }
    
    var updatedAt:NSDate = NSDate() {
        didSet {
            OPManager.notificationCenter.postNotificationKey(.DidUpdateComponent, object: self)
        }
    }
    
    
    var actualTemperature:Float = 0 {
        didSet {
            if actualTemperature != oldValue {
                updatedAt = NSDate()
            }
        }
    }
    
    var targetTemperature:Float = 0 {
        didSet {
            if targetTemperature != oldValue {
                updatedAt = NSDate()
            }
        }
    }
    
    var temperatureOffset:Float = 0 {
        didSet {
            if temperatureOffset != oldValue {
                updatedAt = NSDate()
            }
        }
    }
    
    // Methods
    
    required init(identifier: String) {
        self.identifier = identifier
    }
    
    func setTargetTemperature(targetTemperature:Float) {
        assert(false, "OPHeatedComponent should not be used directly.")
    }
    
    func setTemperatureOffset(targetTemperature:Float) {
        assert(false, "OPHeatedComponent should not be used directly.")
    }
    

}



