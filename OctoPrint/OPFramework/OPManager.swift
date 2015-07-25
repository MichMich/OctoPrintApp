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

/*
 * Structs & enums
 */

struct ToolTemperature {
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

enum ToolType {
    case Bed
    case Tool
}

enum OctoPrintNotifications:String {
    case DidUpdate = "com.xonaymedia.OctoPrintApp.OctoPrintDidUpdate"
    case DidUpdateVersion = "com.xonaymedia.OctoPrintApp.OctoPrintDidUpdateVersion"
    case DidUpdatePrinter = "com.xonaymedia.OctoPrintApp.OctoPrintDidUpdatePrinter"
    case DidSetPrinterTool = "com.xonaymedia.OctoPrintApp.OctoPrintDidDidSetPrinterTool"
    case DidSetPrinterBed = "com.xonaymedia.OctoPrintApp.OctoPrintDidDidSetPrinterBed"
}







class OPManager {
    static let sharedInstance = OPManager()
    
    // update info
    var updateTimeStamp:NSDate?
  
    // version
    var apiVersion:String = "Unknown"
    var serverVersion:String = "Unknown"
    
    // printer
    var printerStateText:String = "Unknown"
    var printerStateFlags:StateFlags = StateFlags(operational: false, paused: false, printing: false, sdReady: false, error: false, ready: false, closedOrError: false)

    let bed:OPBed = OPBed(identifier: "bed")
    let tools = OPToolArray()
    
    private enum tasks {
        static var updateVersion = OPAPITask(endPoint: "version")
        static var updatePrinter = OPAPITask(endPoint: "printer")
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
                self.updateTimeStamp = tasks.updatePrinter.lastSuccessfulRun
                
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
                    
                    let heatedComponent:OPHeatedComponent
                    
                    if key == "bed" {
                        heatedComponent = self.bed
                    } else {
                        heatedComponent = self.tools[key]
                    }
                    
                    heatedComponent.actualTemperature = subJson["actual"].float ?? 0
                    heatedComponent.targetTemperature = subJson["target"].float ?? 0
                    heatedComponent.temperatureOffset = subJson["offset"].float ?? 0
                    
                }
                
                self.broadcastNotification(.DidUpdate)
                self.broadcastNotification(.DidUpdatePrinter)
                
            }
            
        }).autoRepeat(interval).fire()
    }
    
    // Private methods
    private func broadcastNotification(notification:OctoPrintNotifications) {
        NSNotificationCenter.defaultCenter().postNotificationKey(notification, object: self)
    }
}




/*
 * Extensions
 */


// Alamofire.Manager extension to create managers with default headers.

extension Alamofire.Manager {
    convenience init(withHeaders headers: [String:String]) {
        var defaultHeaders = Alamofire.Manager.sharedInstance.session.configuration.HTTPAdditionalHeaders ?? [:]
        
        for (key, value) in headers {
            defaultHeaders[key] = value
        }
        
        let configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
        configuration.HTTPAdditionalHeaders = defaultHeaders
        
        self.init(configuration: configuration)
    }
}


//  NSNotificationCenter extension to handle OctoPrintNotifications.

extension NSNotificationCenter {
    
    func addObserver(observer: AnyObject, selector aSelector: Selector, key aKey: OctoPrintNotifications) {
        self.addObserver(observer, selector: aSelector, name: aKey.rawValue, object: nil)
    }
    
    func addObserver(observer: AnyObject, selector aSelector: Selector, key aKey: OctoPrintNotifications, object anObject: AnyObject?) {
        self.addObserver(observer, selector: aSelector, name: aKey.rawValue, object: anObject)
    }
    
    func removeObserver(observer: AnyObject, key aKey: OctoPrintNotifications, object anObject: AnyObject?) {
        self.removeObserver(observer, name: aKey.rawValue, object: anObject)
    }
    
    func postNotificationKey(key: OctoPrintNotifications, object anObject: AnyObject?) {
        self.postNotificationName(key.rawValue, object: anObject)
    }
    
    func postNotificationKey(key: OctoPrintNotifications, object anObject: AnyObject?, userInfo aUserInfo: [NSObject : AnyObject]?) {
        self.postNotificationName(key.rawValue, object: anObject, userInfo: aUserInfo)
    }
    
    func addObserverForKey(key: OctoPrintNotifications, object obj: AnyObject?, queue: NSOperationQueue?, usingBlock block: (NSNotification!) -> Void) -> NSObjectProtocol {
        return self.addObserverForName(key.rawValue, object: obj, queue: queue, usingBlock: block)
    }
    
}

