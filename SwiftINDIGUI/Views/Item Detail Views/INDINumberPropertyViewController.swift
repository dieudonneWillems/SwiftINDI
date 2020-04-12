//
//  INDINumberPropertyViewController.swift
//  SwiftINDIGUI
//
//  Created by Don Willems on 11/04/2020.
//  Copyright © 2020 lapsedpacifist. All rights reserved.
//

import Cocoa
import SwiftINDI

class INDINumberPropertyViewController: INDIViewController {
    
    @IBOutlet weak public var labelTF : NSTextField?
    @IBOutlet weak public var identifierTF : NSTextField?
    @IBOutlet weak public var valueTF : NSTextField?
    @IBOutlet weak public var minTF : NSTextField?
    @IBOutlet weak public var maxTF : NSTextField?
    @IBOutlet weak public var valueSlider : NSSlider?
    @IBOutlet weak public var valueStepper : NSStepper?
    
    public override var property : INDIProperty? {
        didSet {
            if property == nil || (property as? INDINumberProperty) == nil {
                labelTF?.stringValue = "Unknown INDI Number Property"
                identifierTF?.stringValue = ""
                valueTF?.stringValue = ""
            } else {
                let numberProperty = property as! INDINumberProperty
                labelTF?.stringValue = property!.label != nil ? property!.label! : property!.name
                identifierTF?.stringValue = property!.name
                let value = numberProperty.numberValue != nil ? numberProperty.numberValue! : 0.0
                let min = numberProperty.minimum
                var max = numberProperty.maximum
                if min == max {
                    max = min * 1000.0
                }
               // let step = numberProperty.stepSize != nil && numberProperty.stepSize > 0 ? numberProperty.stepSize! : (max-min)/10.0
                var step = 1.0
                var onlyTicks = true
                if numberProperty.stepSize != nil && numberProperty.stepSize! > 0.0 {
                    step = numberProperty.stepSize!
                } else {
                    step = (max-min)/10.0
                    onlyTicks = false
                }
                var nsteps = Int((max-min)/step + 0.5)
                if nsteps > 20 {
                    onlyTicks = false
                    let logfac = Int(log(Double(nsteps)/20.0)/log(5.0) + 1.0)
                    nsteps = Int(Double(nsteps)/pow(5.0, Double(logfac)))
                }
                valueTF?.doubleValue = value
                valueStepper?.doubleValue = value
                valueStepper?.minValue = min
                valueStepper?.maxValue = max
                valueStepper?.increment = step
                valueSlider?.allowsTickMarkValuesOnly = onlyTicks
                valueSlider?.doubleValue = value
                valueSlider?.minValue = min
                valueSlider?.maxValue = max
                valueSlider?.numberOfTickMarks = nsteps
                minTF?.stringValue = "\(min)"
                maxTF?.stringValue = "\(max)"
            }
        }
    }
    
    @IBAction func numberPropertyValueChanged(sender: NSObject) {
        if (property as? INDINumberProperty) != nil {
            let numberProperty = property as! INDINumberProperty
            if sender == valueTF {
                var value = valueTF!.doubleValue
                if numberProperty.stepSize != nil && numberProperty.stepSize! != 0 {
                    value = Double(Int(value / numberProperty.stepSize! + 0.5)) * numberProperty.stepSize!
                }
                valueSlider?.doubleValue = value
                valueStepper?.doubleValue = value
                numberProperty.numberValue = value
            } else if sender == valueSlider {
                var value = valueSlider!.doubleValue
                if numberProperty.stepSize != nil && numberProperty.stepSize! != 0 {
                    value = Double(Int(value / numberProperty.stepSize! + 0.5)) * numberProperty.stepSize!
                }
                valueTF?.doubleValue = value
                valueStepper?.doubleValue = value
                numberProperty.numberValue = value
            } else if sender == valueStepper {
                var value = valueStepper!.doubleValue
                if numberProperty.stepSize != nil && numberProperty.stepSize! != 0 {
                    value = Double(Int(value / numberProperty.stepSize! + 0.5)) * numberProperty.stepSize!
                }
                valueTF?.doubleValue = value
                valueSlider?.doubleValue = value
                numberProperty.numberValue = value
            }
        }
    }
    
}
