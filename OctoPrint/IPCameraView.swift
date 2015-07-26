//
//  IPCameraView.swift
//  OctoPrint
//
//  Created by Michael Teeuw on 26-07-15.
//  Copyright © 2015 Michael Teeuw. All rights reserved.
//

import UIKit


class IPCameraView: UIView, NSURLSessionDataDelegate {
    
    var imageView:UIImageView
    
    var url: NSURL
    var endMarkerData: NSData
    var receivedData: NSMutableData
    var dataTask: NSURLSessionDataTask
    
    override init(frame: CGRect) {
        self.endMarkerData = NSData(bytes: [0xFF, 0xD9] as [UInt8], length: 2)
        
        self.url = NSURL()
        self.receivedData = NSMutableData()
        
        self.imageView = UIImageView()
        
        self.dataTask = NSURLSessionDataTask()

        super.init(frame: frame)
        
        self.addSubview(self.imageView)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit{
        self.dataTask.cancel()
    }
    
    func startWithURL(url:NSURL){
        let session = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration(), delegate: self, delegateQueue: nil)
        
        
        let request = NSURLRequest(URL: url )
        
        self.dataTask = session.dataTaskWithRequest(request)
        
        
        // Initialization code
        
        self.dataTask.resume()
        
        let bounds = self.bounds
        self.imageView.frame = bounds
        self.imageView.contentMode = UIViewContentMode.ScaleAspectFit
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    func pause() {
        self.dataTask.cancel()
    }
    
    func stop(){
        self.pause()
    }
    
    func URLSession(session: NSURLSession,
        dataTask: NSURLSessionDataTask,
        didReceiveData: NSData) {
            
            
            self.receivedData.appendData(didReceiveData)
            
            //NSLog( "Did receive data" )
            
            //var endRange:NSRange = self.receivedData.rangeOfData(self.endMarkerData, options: nil, range: NSMakeRange(0, self.receivedData.length))
            
            let endRange:NSRange = self.receivedData.rangeOfData(self.endMarkerData, options: NSDataSearchOptions.Backwards, range: NSMakeRange(0, self.receivedData.length))
         
            
            
            let endLocation = endRange.location + endRange.length
            //long long endLocation = endRange.location + endRange.length;
            
           
            
            if self.receivedData.length >= endLocation {
                let imageData = self.receivedData.subdataWithRange(NSMakeRange(0, endLocation))
                let receivedImage = UIImage(data: imageData)

                dispatch_async( dispatch_get_main_queue(), {
                    self.imageView.image = receivedImage
                })
                
                
                self.receivedData = NSMutableData(data: self.receivedData.subdataWithRange(NSMakeRange(endLocation, self.receivedData.length - endLocation)))
                
            }

            
    }
    
}