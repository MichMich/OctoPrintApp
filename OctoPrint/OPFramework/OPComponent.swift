//
//  OPComponent.swift
//  OctoPrint
//
//  Created by Michael Teeuw on 25-07-15.
//  Copyright © 2015 Michael Teeuw. All rights reserved.
//

import Foundation


enum OPComponentType {
    case PrintHead
    case Tool
    case Bed
    case SDCard
    case Unknown
}

protocol OPComponent {
    
    var identifier: String { get set }
    var componentType: OPComponentType { get }
    var updatedAt:NSDate {get set}

    init(identifier:String)
}

extension OPComponent {

}