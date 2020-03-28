//
//  INDIPropertyItemVIew.swift
//  SwiftINDIGUI
//
//  Created by Don Willems on 28/03/2020.
//  Copyright © 2020 lapsedpacifist. All rights reserved.
//

import Cocoa

class INDIPropertyItemVIew: NSView {
    
    @IBOutlet weak public var propertyName : NSTextField?
    
    var writePermission : Bool = true {
        didSet {
            // TODO: Use italic when the user is not allowed to write
        }
    }
    
}
