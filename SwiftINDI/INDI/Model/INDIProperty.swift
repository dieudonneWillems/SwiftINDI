//
//  INDIProperty.swift
//  SwiftINDI
//
//  Created by Don Willems on 14/03/2020.
//  Copyright © 2020 lapsedpacifist. All rights reserved.
//

import Foundation

/**
 * This is an enumeration of the different property types that are supported by INDI.
 *
 * Property type can be accesed by the `propertyType` parameter of the `INDIPropertyVector`
 * and `INDIProperty` protocols and its implementations.
 */
public enum INDIPropertyType {
    
    /**
     * A property that holds one or more text elements.
     */
    case textProperty
    
    /**
     * A property that holds one or more numeric values.
     */
    case numberProperty
    
    /**
     * A property that holds one or more switches.
     */
    case switchProperty
    
    /**
     * A property that holds one or more passive indicator lights.
     */
    case lightProperty
    
    /**
     * A property that holds one or more Binary Large Objects (BLOBs).
     */
    case BLOBProperty
}

/**
 * The state an INDI property of a device is in.
 */
public enum INDIPropertyState {
    
    /**
     * The property is idle. If the property is represented in a graphical user interface (GUI) by
     * a colour, the colour for `.idle` should be grey.
     */
    case idle
    
    /**
     * The property is OK. If the property is represented in a graphical user interface (GUI) by
     * a colour, the colour for `.ok` should be green.
     */
    case ok
    
    /**
     * The property is busy. If the property is represented in a graphical user interface (GUI) by
     * a colour, the colour for `.busy` should be yellow.
     */
    case busy
    
    /**
     * The property is in an alert state. If the property is represented in a graphical user interface (GUI) by
     * a colour, the colour for `.alert` should be red.
     */
    case alert
}

/**
 * An enumeration of standard property vector names.
 */
public enum INDIStandardPropertyVectorName :  String, CaseIterable {
    /**
     * The connection switch used to establish a connection to a device.
     * This property vector will have `CONNECT` and `DISCONNECT` properties that can be either
     * `On` or `Off`.
     */
    case connection = "CONNECTION"
    
    /**
     * The property vector is not one of the standard property vectors.
     */
    case other = "Not a standard Property Vector"
}


/**
 * This protocol defines the intrerface of a vector of INDI properties.
 *
 * The different types of INDI properties need to conform to this interface, but will also
 * define their own parameters.
 */
public protocol INDIPropertyVector {
    
    /**
     * The type of the INDI property (text, numeric, switch, light, or BLOB).
     */
    var propertyType : INDIPropertyType {get}
    
    /**
     * The device to which this INDI property belongs.
     */
    var device : INDIDevice {get}
    
    /**
     * The name of the INDI property.
     */
    var name : String {get}
    
    /**
     * The name of the INDI property that should be used in a graphical user interface (GUI),
     * i.e. a human readable name. If this property is not defined (i.e. is `nil`), the `name`
     * of the INDI property should be used as the label.
     */
    var label : String? {get}
    
    /**
     * The name of the INDI property that should be used in a graphical user interface (GUI),
     * i.e. a human readble name. This property will have the same value of the `label`
     * property if this is not `nil`, otherwise it wil have the same value as the `name` property.
     */
    var uiLabel : String {get}
    
    /**
     * The name of the group to which the INDI property belongs. If this property is `nil`, it is
     * not defined, i.e. blank.
     */
    var group : String? {get}
    
    /**
     * The state in which the INDI property is in. Values can be `.idle`, `.ok`, `.busy`, or  `.alert`.
     * A GUI may represent the state in different colours. Suggested colours would be gray, green, yellow, and
     * red respectively.
     */
    var state : INDIPropertyState {get set}
    
    /**
     * Specifies that the INDI property can be read by the client.
     */
    var canBeRead : Bool {get}
    
    /**
     * Specifies that the INDI property can written to by the client. Light properties are never allowed to be written to.
     */
    var canBeWritten : Bool {get}
    
    /**
     * The worse-case time to affect. The default value should be `0`. If the INDI property is read only, this property
     * is not relevant.
     */
    var timeout : Int {get set}
    
    /**
     * The moment when the propery was valid.
     */
    var timestamp : Date? {get set}
    
    /**
     * A commentary (description) of the property.
     */
    var message : String? {get set}
    
    /**
     * The member properties of this vector.
     */
    var memberProperties : [INDIProperty] {get}
    
    /**
     * Returns the property with the specified name, or `nil` if the name is not known.
     *
     * - Parameter name: The name of the property.
     * - Returns: The property.
     */
    func property(name: String) -> INDIProperty?
    
    /**
     * This method chould be called when a property's value will change. The property vector will
     * notify the `device` that the property will change.
     *
     * - Parameter property: The property that will change.
     * - Parameter newValue: The new value of the property.
     */
    func property(_ property: INDIProperty, willChangeTo newValue: Any?)
    
    /**
     * This method chould be called when a property's value has changed. The property vector will
     * notify the `device` that the property has changed.
     *
     * - Parameter property: The property that has been changed.
     * - Parameter newValue: The new value of the property.
     */
    func property(_ property: INDIProperty, hasChangedTo newValue: Any?)
}


/**
 * This protocol defines the intrerface of an INDI property.
 *
 * The different types of INDI properties need to conform to this interface, but will also
 * define their own parameters.
 */
public protocol INDIProperty {
    
    /**
     * The type of the INDI property (text, numeric, switch, light, or BLOB).
     */
    var propertyType : INDIPropertyType {get}
    
    /**
     * The name of the INDI property.
     */
    var name : String {get}
    
    /**
     * The name of the INDI property that should be used in a graphical user interface (GUI),
     * i.e. a human readable name. If this property is not defined (i.e. is `nil`), the `name`
     * of the INDI property should be used as the label.
     */
    var label : String? {get}
    
    /**
     * The name of the INDI property that should be used in a graphical user interface (GUI),
     * i.e. a human readble name. This property will have the same value of the `label`
     * property if this is not `nil`, otherwise it wil have the same value as the `name` property.
     */
    var uiLabel : String {get}
    
    /**
     * The current value of the property, or `nil` if the property's value has not been set.
     */
    var value: Any? {get set}
    
    /**
     * The property vector associated with this property.
     */
    var propertyVector: INDIPropertyVector {get}
    
}



/**
 * Tests whether the property vectors are equal. Property vectors are equal if their `name` s are equal.
 * - Parameter lhs: The left hand property vector.
 * - Parameter rhs: The right hand property vector.
 * - Returns: `true` when the property vectors are equal, `false` if they are not.
 */
public func == (lhs: INDIPropertyVector, rhs: INDIPropertyVector) -> Bool {
    return lhs.name == rhs.name
}

/**
 * Tests whether the properties are equal. Properties are equal if their `name` s are equal.
 * - Parameter lhs: The left hand property.
 * - Parameter rhs: The right hand property.
 * - Returns: `true` when the properties are equal, `false` if they are not.
 */
public func == (lhs: INDIProperty, rhs: INDIProperty) -> Bool {
    return lhs.name == rhs.name
}
