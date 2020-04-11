//
//  INDIConnectPropertyViewController.swift
//  SwiftINDIGUI
//
//  Created by Don Willems on 11/04/2020.
//  Copyright © 2020 lapsedpacifist. All rights reserved.
//

import Cocoa
import SwiftINDI

class INDIConnectPropertyViewController: INDIViewController {
    
    @IBOutlet weak public var labelTF : NSTextField?
    @IBOutlet weak public var identifierTF : NSTextField?
    @IBOutlet weak public var connectButton : NSButton?
    
    public override var propertyVector : INDIPropertyVector? {
        didSet {
            if propertyVector == nil || (propertyVector as? INDISwitchPropertyVector) == nil {
                labelTF?.stringValue = "Unknown INDI Switch Property Vector"
                identifierTF?.stringValue = ""
                connectButton?.title = "Error"
            } else if (propertyVector as? INDISwitchPropertyVector) != nil {
                let switchPropertyVector = propertyVector as! INDISwitchPropertyVector
                labelTF?.stringValue = switchPropertyVector.label != nil ? switchPropertyVector.label! : switchPropertyVector.name
                identifierTF?.stringValue = switchPropertyVector.name
                if switchPropertyVector.rule == .oneOfMany && switchPropertyVector.on[0].name == "CONNECT" {
                    connectButton?.title = "Disconnect"
                    connectButton?.state = .on
                } else {
                    connectButton?.title = "Connect"
                    connectButton?.state = .off
                }
            }
        }
    }
    
    @IBAction func switchPropertyValueChanged(sender: NSButton) {
        if (propertyVector as? INDISwitchPropertyVector) != nil {
            let switchPropertyVector = propertyVector as! INDISwitchPropertyVector
            if sender.state == .on {
                connectButton?.title = "Disconnect"
                switchPropertyVector.switchOn(name: "CONNECT")
            } else {
                connectButton?.title = "Connect"
                switchPropertyVector.switchOn(name: "DISCONNECT")
            }
        }
    }
}
