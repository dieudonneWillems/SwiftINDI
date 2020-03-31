//
//  INDITextViewPopoverView.swift
//  SwiftINDIGUI
//
//  Created by Don Willems on 31/03/2020.
//  Copyright © 2020 lapsedpacifist. All rights reserved.
//

import Cocoa
import SwiftINDI

public class INDITextPropertyView: NSView {
    
    @IBOutlet weak public var labelTF : NSTextField?
    @IBOutlet weak public var identifierTF : NSTextField?
    @IBOutlet weak public var valueTF : NSTextField?
    
    public var property : INDITextProperty? {
        didSet {
            if property == nil {
                labelTF?.stringValue = "Unknown INDI Text Property"
                identifierTF?.stringValue = ""
                valueTF?.stringValue = ""
            } else {
                labelTF?.stringValue = property!.label != nil ? property!.label! : property!.name
                identifierTF?.stringValue = property!.name
                valueTF?.stringValue = property!.textValue != nil ? property!.textValue! : ""
            }
        }
    }
    
    @IBAction func textPropertyValueChanged(sender: NSTextField) {
        property?.textValue = sender.stringValue
    }
}
