//
//  IPCameraView.swift
//  OctoPrint
//
//  Created by Michael Teeuw on 26-07-15.
//  Copyright © 2015 Michael Teeuw. All rights reserved.
//

import UIKit


class IPCameraView: UIImageView, NSURLSessionDataDelegate {
    

    
    var url = NSURL()
    var endMarkerData = NSData(bytes: [0xFF, 0xD9] as [UInt8], length: 2)
    var receivedData =  NSMutableData()
    var dataTask: NSURLSessionDataTask?
    
    deinit{
        self.dataTask?.cancel()
        self.dataTask = nil
    }
    
    func startWithURL(url:NSURL){
        let session = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration(), delegate: self, delegateQueue: nil)
        let request = NSURLRequest(URL: url )
        
        self.dataTask?.cancel()
        self.dataTask = session.dataTaskWithRequest(request)
        // Initialization code
        
        self.dataTask?.resume()
        self.contentMode = UIViewContentMode.ScaleAspectFit
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    func pause() {
        self.dataTask?.cancel()
        self.dataTask = nil
    }
    
    func stop(){
        self.pause()
    }
    
    func URLSession(session: NSURLSession,
        dataTask: NSURLSessionDataTask,
        didReceiveData: NSData) {
            

            
            self.receivedData.appendData(didReceiveData)
            
            
            
            let endRange:NSRange = self.receivedData.rangeOfData(self.endMarkerData, options: NSDataSearchOptions(rawValue: 0), range: NSMakeRange(0, self.receivedData.length))

            let endLocation = endRange.location + endRange.length
            
            
            
            
            
            if self.receivedData.length >= endLocation {
            

                
                let imageData = self.receivedData.subdataWithRange(NSMakeRange(0, endLocation))
                let receivedImage = UIImage(data: imageData)

                dispatch_async( dispatch_get_main_queue(), {
                    self.image = receivedImage
                })
                
           
                
                self.receivedData = NSMutableData(data: self.receivedData.subdataWithRange(NSMakeRange(endLocation, self.receivedData.length - endLocation)))
                
            }

            
    }
    
}