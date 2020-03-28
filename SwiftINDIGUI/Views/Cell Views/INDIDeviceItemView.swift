//
//  INDIDeviceItemView.swift
//  SwiftINDIGUI
//
//  Created by Don Willems on 26/03/2020.
//  Copyright © 2020 lapsedpacifist. All rights reserved.
//

import Cocoa
import SwiftINDI

class INDIDeviceItemView: NSView {
    
    @IBOutlet weak public var deviceName : NSTextField?
    @IBOutlet weak public var iconView : NSImageView?
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
