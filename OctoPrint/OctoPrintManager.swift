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

enum OctoPrintAPIMethod {
    case GET
    case POST
}

class OctoPrintAPITask: NSObject {
    
    var endPoint:String
    private var successBlock:((JSON?)->())?
    private var failureBlock:((NSError)->())?
    private var parameters:[String: AnyObject]?
    private var method:OctoPrintAPIMethod = .GET
    
    var lastSuccessfulRun:NSDate?
    
    private var repeatTimer:NSTimer?
    private var repeatInterval:NSTimeInterval?
    
    init (endPoint:String) {
        self.endPoint = endPoint
    }
    
    func fire() -> OctoPrintAPITask {
        executeCall()
        return self
    }
    
    func method(method:OctoPrintAPIMethod) -> OctoPrintAPITask  {
        self.method = method
        return self
    }
    
    func parameters(parameters:[String: AnyObject]?) -> OctoPrintAPITask {
        self.parameters = parameters
        return self
    }
    
    func onSuccess(successBlock: ((JSON?)->())?) -> OctoPrintAPITask {
        self.successBlock = successBlock
        return self
    }
    
    func onFailure(failureBlock: ((NSError)->())?) -> OctoPrintAPITask {
        self.failureBlock = failureBlock
        return self
    }
    
    func autoRepeat(repeatInterval:NSTimeInterval?) -> OctoPrintAPITask {
        self.repeatInterval = repeatInterval
        self.scheduleTimer()
        return self
    }
    
    private func scheduleTimer() {
        repeatTimer?.invalidate()
        repeatTimer = nil
        if let repeatInterval = repeatInterval {
            repeatTimer = NSTimer.scheduledTimerWithTimeInterval(repeatInterval, target: self, selector: Selector("fire"), userInfo: nil, repeats: false)
        }
    }
    
    private func executeCall() {
        let endPoint = "http://192.168.0.30/api/\(self.endPoint)"
        
        OctoPrintManager.sharedInstance.alamoFireManager.request((self.method == .GET) ? .GET : .POST, endPoint, parameters: parameters, encoding: .JSON).responseJSON {
            (request, response, jsonData, error) -> Void in
            if let error = error {
                self.failureBlock?(error)
                self.scheduleTimer()
            } else {
                let json = JSON(jsonData ?? [])
                self.lastSuccessfulRun = NSDate()
                self.successBlock?(json)
                self.scheduleTimer()
            }
        }
    }
}

enum OctoPrintNotifications:String {
    case DidUpdate = "com.xonaymedia.OctoPrintApp.OctoPrintDidUpdate"
    case DidUpdateVersion = "com.xonaymedia.OctoPrintApp.OctoPrintDidUpdateVersion"
    case DidUpdatePrinter = "com.xonaymedia.OctoPrintApp.OctoPrintDidUpdatePrinter"
    case DidSetPrinterTool = "com.xonaymedia.OctoPrintApp.OctoPrintDidDidSetPrinterTool"
}

class OctoPrintManager {
    static let sharedInstance = OctoPrintManager()
    
    var alamoFireManager:Alamofire.Manager = {
        var defaultHeaders = Alamofire.Manager.sharedInstance.session.configuration.HTTPAdditionalHeaders ?? [:]
        defaultHeaders["X-Api-Key"] = "6F72A90FCD4C4AF6A7F7836F787681B6"
        
        let configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
        configuration.HTTPAdditionalHeaders = defaultHeaders
        
        return Alamofire.Manager(configuration: configuration)
    }()
    
    
    // update info
    var updateTimeStamp:NSDate?
  
    // version
    var apiVersion:String = "Unknown"
    var serverVersion:String = "Unknown"
    
    // printer
    var printerStateText:String = "Unknown"
    var printerStateFlags:StateFlags = StateFlags(operational: false, paused: false, printing: false, sdReady: false, error: false, ready: false, closedOrError: false)
    var temperatures:[String:Temperature] = [:]
    
    private enum tasks {
        static var updateVersion = OctoPrintAPITask(endPoint: "version")
        static var updatePrinter = OctoPrintAPITask(endPoint: "printer")
        static var setPrinterTool = OctoPrintAPITask(endPoint: "printer/tool")
    }
    
    func updateVersion(autoUpdate interval: NSTimeInterval? = nil) {
        tasks.updateVersion.onSuccess({ (json)->() in
            if let json = json {
                self.updateTimeStamp = tasks.updateVersion.lastSuccessfulRun
                if let version = json["api"].string {
                    self.apiVersion = version
                }
                
                if let version = json["server"].string {
                    self.serverVersion = version
                }
                
                self.broadcastNotification(.DidUpdate)
                self.broadcastNotification(.DidUpdateVersion)
                
            }
        }).autoRepeat(interval).fire()
    }
    
    func updatePrinter(autoUpdate interval: NSTimeInterval? = nil) {
        tasks.updatePrinter.onSuccess({ (json)->() in
            
            if let json = json {
                
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
                
                self.broadcastNotification(.DidUpdate)
                self.broadcastNotification(.DidUpdatePrinter)
                
            }
            
        }).autoRepeat(interval).fire()
    }
    
    func setTargetTemperature(targetTemperature:Float, forTool toolName:String) {
        
        print("Target for \(toolName): \(targetTemperature)")
        
        tasks.setPrinterTool.parameters([
            "command": "target",
            "targets": [
                toolName: targetTemperature
            ]
        ]).method(.POST).onSuccess({ (json)->() in
            self.broadcastNotification(.DidSetPrinterTool)
        }).fire()

    }
   
    func toolTypeForTemperatureIdentifier(identifier:String) ->ToolType {
        if identifier == "bed" {
            return .Bed
        }
        return .Extruder
    }
    
    private func broadcastNotification(notification:OctoPrintNotifications) {
        print(notification.rawValue)
        NSNotificationCenter.defaultCenter().postNotificationName(notification.rawValue, object: self)
    }
}

