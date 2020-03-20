//
//  INDILightProperty.swift
//  SwiftINDI
//
//  Created by Don Willems on 19/03/2020.
//  Copyright © 2020 lapsedpacifist. All rights reserved.
//

import Foundation

/**
 * Instances of this class represent an INDI light property vector, which is a vector of
 * light properties. Lights are properties that may be in one of the four states: idle, ok, busy,
 * or alert.
 */
public class INDILightPropertyVector : INDIDefaultPropertyVector {
    
    /**
     * Initialises the INDI light property vector with the supplied values. INDI properties and
     * property vectors should only be created within the SwiftINDI framework.
     *
     * - Parameter name: The name of the INDI light property vector.
     * - Parameter device: The device for which this INDI light property is valid.
     * - Parameter label: The name of the INDI light property that should be used in a graphical user interface (GUI),
     * i.e. a human readable name. If this property is not defined (i.e. is `nil`), the `name`
     * of the INDI property should be used as the label.  This value is optional.
     * - Parameter group: A name for the group of properties containing
     * this INDI light property vector. This value is optional.
     * - Parameter state: The state (idle, ok, busy, or alert) of the property.
     * - Parameter timeout: The worse-case time to affect. The default value should be `0`. If the INDI light property is read only, this property
     * is not relevant.
     * - Parameter timestamp: The moment when the propery was valid.
     * - Parameter message: An optional comment on the property.
     */
    init(_ name: String, device: INDIDevice, label: String?, group: String?, state: INDIPropertyState, timeout: Int, timestamp: Date?, message: String?) {
        super.init(name, of: .lightProperty, device: device, label: label, group: group, state: state, read: true, write: false, timeout: timeout, timestamp: timestamp, message: message)
    }
}

/**
 * Instances of this class represent an INDI light property.  Lights are properties that may be in
 * one of the four states: idle, ok, busy,
 * or alert.
 */
public class INDILightProperty : INDIDefaultProperty {
    
    /**
     * Initialises the INDI light property with the supplied values. INDI properties and
     * property vectors should only be created within the SwiftINDI framework.
     *
     * - Parameter name: The name of the INDI light property.
     * - Parameter label: The name of the INDI light property that should be used in a graphical user interface (GUI),
     * i.e. a human readable name. If this property is not defined (i.e. is `nil`), the `name`
     * of the INDI property should be used as the label.
     * - Parameter vector: The INDI light property vector to which this property will be added as a member.
     */
    init(_ name: String, label: String?, inPropertyVector vector: INDILightPropertyVector) {
        super.init(name, of: .lightProperty, label: label, inPropertyVector: vector)
    }
    
    /**
     * The current value of the light property, or `nil` if the property's value has not been set.
     * Light properties can only be read.
     */
    public internal(set) var lightValue : INDIPropertyState? {
        get {
            return value as? INDIPropertyState
        } set {
            value = newValue
        }
    }
}
