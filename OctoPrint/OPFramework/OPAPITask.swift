//
//  OPAPITask.swift
//  OctoPrint
//
//  Created by Michael Teeuw on 25-07-15.
//  Copyright © 2015 Michael Teeuw. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

class OPAPITask: NSObject {
    
    var alamofireManager = Alamofire.Manager()
    
    var endPoint:String
    private var successBlock:((JSON?)->())?
    private var failureBlock:((NSError)->())?
    private var parameters:[String: AnyObject]?
    private var method:Alamofire.Method = .GET
    
    var lastSuccessfulRun:NSDate?
    
    private var repeatTimer:NSTimer?
    private var repeatInterval:NSTimeInterval?
    
    init (endPoint:String) {
        self.endPoint = endPoint
        if (NSUserDefaults.standardUserDefaults().stringForKey("OctoPrintAPIKey") != nil) {
            let apiKey:String = NSUserDefaults.standardUserDefaults().stringForKey("OctoPrintAPIKey")!
            self.alamofireManager = Alamofire.Manager(withHeaders: ["X-Api-Key": apiKey])
        }
        super.init()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "userDefaultsDidChange", name: NSUserDefaultsDidChangeNotification, object: nil)
    }
    
    func fire() -> OPAPITask {
        executeCall()
        return self
    }
    
    func method(method:Alamofire.Method) -> OPAPITask  {
        self.method = method
        return self
    }
    
    func parameters(parameters:[String: AnyObject]?) -> OPAPITask {
        self.parameters = parameters
        return self
    }
    
    func onSuccess(successBlock: ((JSON?)->())?) -> OPAPITask {
        self.successBlock = successBlock
        return self
    }
    
    func onFailure(failureBlock: ((NSError)->())?) -> OPAPITask {
        self.failureBlock = failureBlock
        return self
    }
    
    func autoRepeat(repeatInterval:NSTimeInterval?) -> OPAPITask {
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
    
    @objc func userDefaultsDidChange() {
        if (NSUserDefaults.standardUserDefaults().stringForKey("OctoPrintAPIKey") != nil) {
            let apiKey:String = NSUserDefaults.standardUserDefaults().stringForKey("OctoPrintAPIKey")!
            self.alamofireManager = Alamofire.Manager(withHeaders: ["X-Api-Key": apiKey])
        }
    }
    
    private func executeCall() {
        
        if (NSUserDefaults.standardUserDefaults().stringForKey("OctoPrintHost") != nil) {
            let host = NSUserDefaults.standardUserDefaults().stringForKey("OctoPrintHost")!
            let endPoint = "http://\(host)/api/\(self.endPoint)"
            
            
            var message:String?
            
            self.alamofireManager
                .request(method, endPoint, parameters: parameters, encoding: .JSON)
                .responseString { request, response, string, error in
                    message = string
                }
                .responseJSON {
                    (request, response, jsonData, error) -> Void in
                    if let error = error {
                        //print(error)
                        print(message)
                        self.failureBlock?(error)
                        self.scheduleTimer()
                    } else {
                        //print(jsonData)
                        let json = JSON(jsonData ?? [])
                        self.lastSuccessfulRun = NSDate()
                        self.successBlock?(json)
                        self.scheduleTimer()
                    }
            }
        }
    }
}