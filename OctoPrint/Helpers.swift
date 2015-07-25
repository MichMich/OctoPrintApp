//
//  Helpers.swift
//  OctoPrint
//
//  Created by Michael Teeuw on 23-07-15.
//  Copyright © 2015 Michael Teeuw. All rights reserved.
//

import Foundation


extension Float {
    func celciusString() -> String {
        
        if Float(Int(self)) == self {
           return "\(Int(self))º C"
        }
        
        return "\(self)º C"
    }
}

extension Int {
    func celciusString() -> String {
        return "\(self)º C"
    }
}