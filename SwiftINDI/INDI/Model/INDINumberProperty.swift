//
//  INDINumberProperty.swift
//  SwiftINDI
//
//  Created by Don Willems on 18/03/2020.
//  Copyright © 2020 lapsedpacifist. All rights reserved.
//

import Foundation

/**
 * Instances of this class represent an INDI number property vector, which is a vector of
 * number properties that holds one or more properties with numerical information.
 */
public class INDINumberPropertyVector : INDIDefaultPropertyVector {
    
    /**
     * Initialises the INDI number property vector with the supplied values. INDI properties and
     * property vectors should only be created within the SwiftINDI framework.
     *
     * - Parameter name: The name of the INDI number property vector.
     * - Parameter device: The device for which this INDI number property is valid.
     * - Parameter label: The name of the INDI number property that should be used in a graphical user interface (GUI),
     * i.e. a human readable name. If this property is not defined (i.e. is `nil`), the `name`
     * of the INDI property should be used as the label.  This value is optional.
     * - Parameter group: A name for the group of properties containing
     * this INDI number property vector. This value is optional.
     * - Parameter state: The state (idle, ok, busy, or alert) of the property.
     * - Parameter read: True when the client can read the INDI number property.
     * - Parameter write: True when the client can write to the property, i.e. change the property value.
     * - Parameter timeout: The worse-case time to affect. The default value should be `0`. If the INDI number property is read only, this property
     * is not relevant.
     * - Parameter timestamp: The moment when the propery was valid.
     * - Parameter message: An optional comment on the property.
     */
    init(_ name: String, device: INDIDevice, label: String?, group: String?, state: INDIPropertyState, read: Bool, write: Bool, timeout: Int, timestamp: Date?, message: String?) {
        super.init(name, of: .numberProperty, device: device, label: label, group: group, state: state, read: read, write: write, timeout: timeout, timestamp: timestamp, message: message)
    }
}

/**
 * Instances of this class represent an INDI number property, which is a property that holds
 * numerical information.
 */
public class INDINumberProperty : INDIDefaultProperty {
    
    /**
     * A `printf` style format for GUI display.
     */
    public let format: String
    
    /**
     * The minimum value for this numerical property.
     */
    public let minimum : Double
    
    /**
     * The maximum value for this numerical property.
     */
    public let maximum : Double
    
    /**
     * The size of an allowed increment. If this value is `nil` it will be ignored.
     */
    public let stepSize : Double?
    
    /**
     * Initialises the INDI number property with the supplied values. INDI properties and
     * property vectors should only be created within the SwiftINDI framework.
     *
     * - Parameter name: The name of the INDI number property.
     * - Parameter label: The name of the INDI number property that should be used in a graphical user interface (GUI),
     * i.e. a human readable name. If this property is not defined (i.e. is `nil`), the `name`
     * of the INDI property should be used as the label.
     * - Parameter vector: The INDI number property vector to which this property will be added as a member.
     */
    init(_ name: String, label: String?, format: String, minimumValue minimum: Double, maximumValue maximum: Double, stepSize: Double?, inPropertyVector vector: INDINumberPropertyVector) {
        self.format = format
        self.minimum = minimum
        self.maximum = maximum
        self.stepSize = stepSize
        super.init(name, of: .numberProperty, label: label, inPropertyVector: vector)
    }
    
    /**
     * The current value of the number property, or `nil` if the property's value has not been set.
     */
    public var numberValue : Double? {
        get {
            return value as? Double
        } set {
            value = newValue
        }
    }
}
