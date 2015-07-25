//
//  OPTool.swift
//  OctoPrint
//
//  Created by Michael Teeuw on 25-07-15.
//  Copyright © 2015 Michael Teeuw. All rights reserved.
//

import Foundation

class OPTool : OPHeatedComponent {
    
    static var apiTask = OPAPITask(endPoint: "printer/tool")
    
    
    override var componentType:OPComponentType {
        get {
            return .Tool
        }
    }
    
    // Methods
    
    override func setTargetTemperature(targetTemperature:Float) {
        
        OPTool.apiTask.parameters([
            "command": "target",
            "targets": [
                self.identifier: targetTemperature
            ]
        ]).method(.POST).onSuccess({ (json)->() in
            
            // self.broadcastNotification(.DidSetPrinterTool)
            
        }).fire()
        
    }
    
}

class OPToolArray {
    
    var tools:[OPTool] = []
    var count:Int {
        get {
            return tools.count
        }
    }
    
    subscript(identifier: String) -> OPTool {
        //print("Search for identifier: \(identifier)")
        for tool in self.tools {
            if tool.identifier == identifier {
                return tool
            }
        }
        
        let tool = OPTool(identifier: identifier)
        tools.append(tool)
        return tool
    }
    
    subscript(index: Int) -> OPTool {
        return tools[index]
    }
    
}