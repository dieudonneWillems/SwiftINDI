//
//  INDIDefaultProperty.swift
//  SwiftINDI
//
//  Created by Don Willems on 18/03/2020.
//  Copyright © 2020 lapsedpacifist. All rights reserved.
//

import Foundation

/**
 * Represents a default INDI property vector. This class should be overridden by more specific subclasses such as:
 * `INDITextPropertyVector` and  `INDINumberPropertyVector`.
 */
public class INDIDefaultPropertyVector : INDIPropertyVector {
    
    /**
     * The type of the INDI property (text, numeric, switch, light, or BLOB).
     */
    public let propertyType: INDIPropertyType
    
    /**
     * The device to which this INDI property belongs.
     */
    public let device: INDIDevice
    
    /**
     * The name of the INDI property.
     */
    public let name: String
    
    /**
     * The name of the INDI property that should be used in a graphical user interface (GUI),
     * i.e. a human readable name. If this property is not defined (i.e. is `nil`), the `name`
     * of the INDI property should be used as the label.
     */
    public let label: String?
    
    /**
     * The name of the group to which the INDI property belongs. If this property is `nil`, it is
     * not defined, i.e. blank.
     */
    public let group: String?
    
    /**
     * The state in which the INDI property is in. Values can be `.idle`, `.ok`, `.busy`, or  `.alert`.
     * A GUI may represent the state in different colours. Suggested colours would be gray, green, yellow, and
     * red respectively.
     */
    public let state: INDIPropertyState
    
    /**
     * Specifies that the INDI property can be read by the client.
     */
    public let canBeRead: Bool
    
    /**
     * Specifies that the INDI property can written to by the client. Light properties are never allowed to be written to.
     */
    public let canBeWritten: Bool
    
    /**
     * The worse-case time to affect. The default value should be `0`. If the INDI property is read only, this property
     * is not relevant.
     */
    public let timeout: Int
    
    /**
     * The moment when the propery was valid.
     */
    public let timestamp: Date?
    
    /**
     * A commentary (description) of the property.
     */
    public let message: String?
    
    /**
     * The member properties of this vector. This property is a `fileprivate`
     * property and can and should only be accessed from `INDIDefaultPropertyVectoy`
     * or  `INDIDefaultProperty`.
     */
    fileprivate var _memberProperties = [INDIProperty]()
    
    /**
     * The member properties of this vector.
     */
    public var memberProperties: [INDIProperty] {
        get {
            return _memberProperties
        }
    }
    
    /**
     * Initialises the INDI property vector with the supplied values. INDI properties and
     * property vectors should only be created within the SwiftINDI framework.
     *
     * - Parameter name: The name of the INDI property vector.
     * - Parameter type: The property type stored in this vector.
     * - Parameter device: The device for which this INDI property is valid.
     * - Parameter label: The name of the INDI property that should be used in a graphical user interface (GUI),
     * i.e. a human readable name. If this property is not defined (i.e. is `nil`), the `name`
     * of the INDI property should be used as the label.  This value is optional.
     * - Parameter group: A name for the group of properties containing
     * this INDI property vector. This value is optional.
     * - Parameter state: The state (idle, ok, busy, or alert) of the property.
     * - Parameter read: True when the client can read the INDI property.
     * - Parameter write: True when the client can write to the property, i.e. change the property value.
     * - Parameter timeout: The worse-case time to affect. The default value should be `0`. If the INDI property is read only, this property
     * is not relevant.
     * - Parameter timestamp: The moment when the propery was valid.
     * - Parameter message: An optional comment on the property.
     */
    init(_ name: String, of type: INDIPropertyType, device: INDIDevice, label: String?, group: String?, state: INDIPropertyState, read: Bool, write: Bool, timeout: Int, timestamp: Date?, message: String?) {
        self.name = name
        self.propertyType = type
        self.device = device
        self.label = label
        self.group = group
        self.state = state
        self.canBeRead = read
        self.canBeWritten = write
        self.timeout = timeout
        self.timestamp = timestamp
        self.message = message
    }
}


/**
 * Represents a default INDI property. This class should be overridden by more specific subclasses such as:
 * `INDINumberProperty`. 
 */
public class INDIDefaultProperty : INDIProperty {
    
    /**
     * The type of the INDI property (text, numeric, switch, light, or BLOB).
     */
    public var propertyType: INDIPropertyType
    
    /**
     * The name of the INDI property.
     */
    public let name: String
    
    /**
     * The name of the INDI property that should be used in a graphical user interface (GUI),
     * i.e. a human readable name. If this property is not defined (i.e. is `nil`), the `name`
     * of the INDI property should be used as the label.
     */
    public let label: String?
    
    /**
     * Initialises the INDI property with the supplied values. INDI properties and
     * property vectors should only be created within the SwiftINDI framework.
     *
     * - Parameter name: The name of the INDI property.
     * - Parameter type: The type of the INDI property (text, numeric, switch, light, or BLOB).
     * - Parameter label: The name of the INDI property that should be used in a graphical user interface (GUI),
     * i.e. a human readable name. If this property is not defined (i.e. is `nil`), the `name`
     * of the INDI property should be used as the label.
     * - Parameter vector: The INDI property vector to which this property will be added as a member.
     */
    init(_ name: String, of type: INDIPropertyType, label: String?, inPropertyVector vector: INDIPropertyVector) {
        self.name = name
        self.label = label
        self.propertyType = type
        self.value = nil
        if (vector as? INDIDefaultPropertyVector) != nil {
            (vector as! INDIDefaultPropertyVector)._memberProperties.append(self)
        }
    }
    
    /**
     * The current value of the property, or `nil` if the property's value has not been set.
     */
    public var value: Any? {
        willSet(newValue) {
            // TODO: Notify client and forward to INDI server.
        }
    }
}
