//
//  INDITextViewPopoverView.swift
//  SwiftINDIGUI
//
//  Created by Don Willems on 31/03/2020.
//  Copyright © 2020 lapsedpacifist. All rights reserved.
//

import Cocoa
import SwiftINDI

public class INDITextPropertyViewController: INDIViewController {
    
    @IBOutlet weak public var labelTF : NSTextField?
    @IBOutlet weak public var identifierTF : NSTextField?
    @IBOutlet weak public var valueTF : NSTextField?
    
    public override var property : INDIProperty? {
        didSet {
            if property == nil || (property as? INDITextProperty) == nil {
                labelTF?.stringValue = "Unknown INDI Text Property"
                identifierTF?.stringValue = ""
                valueTF?.stringValue = ""
            } else {
                let textProperty = property as! INDITextProperty
                labelTF?.stringValue = property!.label != nil ? property!.label! : property!.name
                identifierTF?.stringValue = property!.name
                valueTF?.stringValue = textProperty.textValue != nil ? textProperty.textValue! : ""
            }
        }
    }
    
    @IBAction func textPropertyValueChanged(sender: NSTextField) {
        if (property as? INDITextProperty) != nil {
            let textProperty = property as! INDITextProperty
            textProperty.textValue = sender.stringValue
        }
    }
}
