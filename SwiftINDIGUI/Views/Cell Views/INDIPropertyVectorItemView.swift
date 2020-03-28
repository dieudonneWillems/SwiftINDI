//
//  INDIPropertyVectorItemView.swift
//  SwiftINDIGUI
//
//  Created by Don Willems on 27/03/2020.
//  Copyright © 2020 lapsedpacifist. All rights reserved.
//

import Cocoa
import SwiftINDI

class INDIPropertyVectorItemView: NSView {
    
    @IBOutlet weak public var propertyVectorName : NSTextField?
    @IBOutlet weak public var statusView : NSImageView?
    
    var status : INDIPropertyState = .idle {
        didSet {
            switch status {
            case .idle:
                self.statusView?.image = NSImage(named:"NSStatusNone")
            case .busy:
                self.statusView?.image = NSImage(named:"NSStatusPartiallyAvailable")
            case .ok:
                self.statusView?.image = NSImage(named:"NSStatusAvailable")
            case .alert:
                self.statusView?.image = NSImage(named:"NSStatusUnavailable")
            }
        }
    }
}
