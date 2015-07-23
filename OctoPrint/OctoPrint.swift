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

struct StateFlags {
    var operational:Bool
    var paused:Bool
    var printing:Bool
    var sdReady:Bool
    var error:Bool
    var ready:Bool
    var closedOrError:Bool
}

class OctoPrint {
    
    let baseUrl = "http://192.168.0.30/api/"
    
    var delegate:OctoPrintDelegate?
    
    var updateTimeStamp:NSDate?
    
    
    // version
    var apiVersion:String = "Unknown"
    var serverVersion:String = "Unknown"
    
    // printer
    var printerStateText:String = "Unknown"
    
    var printerStateFlags:StateFlags = StateFlags(operational: false, paused: false, printing: false, sdReady: false, error: false, ready: false, closedOrError: false)
    var bedTemperature:Temperature = Temperature(actual: 0, target: 0, offset: 0)
    var extruderTemperatures:[String:Temperature] = [:]
    
    
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
  
    func performAPICall(endPoint:String, successCallback:(JSON)->Void) {
        self.manager.request(.GET, generateEndPointURLString(endPoint)).responseJSON {
            (request, response, json, error) -> Void in
            if let error = error {
                self.handleApiError(error)
            } else {
                if let json = json {
                    successCallback(JSON(json))
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
        self.delegate?.octoPrintDidUpdate()
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
                
            self.bedTemperature = Temperature(
                actual: json["temperature"]["bed"]["actual"].float ?? 0,
                target: json["temperature"]["bed"]["target"].float ?? 0,
                offset: json["temperature"]["bed"]["offset"].float ?? 0)
            
            for index in 0...3 {
                let toolName = "tool\(index)"
                if json["temperature"][toolName] != nil {
                    self.extruderTemperatures[toolName] = Temperature(
                        actual: json["temperature"][toolName]["actual"].float ?? 0,
                        target: json["temperature"][toolName]["target"].float ?? 0,
                        offset: json["temperature"][toolName]["offset"].float ?? 0)
                }
            }
            
            self.handleUpdate()
            
        })
        
    }
    
    
   
}

protocol OctoPrintDelegate {
    func octoPrintDidUpdate()
}