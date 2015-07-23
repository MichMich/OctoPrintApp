//
//  OctoPrint.swift
//  OctoPrint
//
//  Created by Michael Teeuw on 22-07-15.
//  Copyright © 2015 Michael Teeuw. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON


struct Temperature {
    var actual:Float
    var target:Float
    var offset:Float
}

enum ToolType {
    case Bed
    case Extruder
}

struct StateFlags {
    var operational:Bool
    var paused:Bool
    var printing:Bool
    var sdReady:Bool
    var error:Bool
    var ready:Bool
    var closedOrError:Bool
}


let octoPrintDidUpdateNotifiction = "com.xonaymedia.OctoPrintApp.OctoPrintDidUpdate"

class OctoPrint {
    static let sharedInstance = OctoPrint()
    
    
    let baseUrl = "http://192.168.0.30/api/"
    
    var updateTimeStamp:NSDate?
  
    // version
    var apiVersion:String = "Unknown"
    var serverVersion:String = "Unknown"
    
    // printer
    var printerStateText:String = "Unknown"
    
    var printerStateFlags:StateFlags = StateFlags(operational: false, paused: false, printing: false, sdReady: false, error: false, ready: false, closedOrError: false)
    var temperatures:[String:Temperature] = [:]
    
    
    var manager:Alamofire.Manager = {
        var defaultHeaders = Alamofire.Manager.sharedInstance.session.configuration.HTTPAdditionalHeaders ?? [:]
        defaultHeaders["X-Api-Key"] = "6F72A90FCD4C4AF6A7F7836F787681B6"
        
        let configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
        configuration.HTTPAdditionalHeaders = defaultHeaders
        
        return Alamofire.Manager(configuration: configuration)
    }()
    
  
    
    func generateEndPointURLString(endPoint:String) -> String {
        return baseUrl + endPoint
    }
  
    func performAPICall(endPoint:String, parameters: [String: AnyObject]? = nil, post: Bool = false, successCallback:(JSON)->Void) {

        self.manager.request((post) ? .POST : .GET, generateEndPointURLString(endPoint), parameters: parameters, encoding: .JSON).responseJSON {
            (request, response, json, error) -> Void in
            if let error = error {
                
                self.handleApiError(error)
            } else {
                if let json = json {
                    successCallback(JSON(json))
                } else {
                    successCallback(JSON([]))
                }
            }
        }
    }
    
    func handleApiError(error:NSError) {
        print("API recieved error!")
        print(error);
    }
    
    func handleUpdate() {
        self.updateTimeStamp = NSDate()
        NSNotificationCenter.defaultCenter().postNotificationName(octoPrintDidUpdateNotifiction, object: self)
    }
    
    func updateAll() {
        updateVersion()
        updatePrinter()
    }
    
    func updateVersion() {
        performAPICall("version", successCallback: { json in

            if let version = json["api"].string {
                self.apiVersion = version
            }
            
            if let version = json["server"].string {
                self.serverVersion = version
            }

            self.handleUpdate()
        })
    }
    
    func updatePrinter() {
        performAPICall("printer", successCallback: { json in
            
            self.printerStateText = json["state"]["text"].string ?? "Unknown"
            
            self.printerStateFlags = StateFlags(
                operational: json["state"]["flags"]["operational"].bool ?? false,
                paused: json["state"]["flags"]["paused"].bool ?? false,
                printing: json["state"]["flags"]["printing"].bool ?? false,
                sdReady: json["state"]["flags"]["sdReady"].bool ?? false,
                error: json["state"]["flags"]["error"].bool ?? false,
                ready: json["state"]["flags"]["ready"].bool ?? false,
                closedOrError: json["state"]["flags"]["closedOrError"].bool ?? false)
            
            for (key, subJson) in json["temperature"] {
                self.temperatures[key] = Temperature(
                    actual: subJson["actual"].float ?? 0,
                    target: subJson["target"].float ?? 0,
                    offset: subJson["offset"].float ?? 0)
            }
            
            self.handleUpdate()
            
        })
    }
    

    
    func toolTypeForTemperatureIdentifier(identifier:String) ->ToolType {
        if identifier == "bed" {
            return .Bed
        }
        return .Extruder
    }
    
    func setTargetTemperature(targetTemperature:Float, forTool toolName:String) {
        print("Target for \(toolName): \(targetTemperature)")
        
        let payload = [
            "command": "target",
            "targets": [
                toolName: targetTemperature
            ]
        ]
        
        performAPICall("printer/tool", parameters: payload, post: true) {
            (_) -> Void in
            print("Done!")
        }
        
    }
   
}

