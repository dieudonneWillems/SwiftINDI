//
//  INDIDevice.swift
//  SwiftINDI
//
//  Created by Don Willems on 14/03/2020.
//  Copyright © 2020 lapsedpacifist. All rights reserved.
//

import Foundation

/**
 * This structure represents a device connected to  an INDI server.
 */
public struct INDIDevice {
    
    /**
     * A set of property vectors relevant to this device.
     */
    public private(set) var propertyVectors = [INDIPropertyVector]()
    
    /**
     * The name of the device.
     */
    public let name : String
    
    /**
     * Initialises a device with the specified name.
     *
     * - Parameter name: The name of the device.
     */
    public init(name: String) {
        self.name = name
    }
    
    /**
     * Defines a new set of values for an INDI property vector and adds it to the property set.
     * - Parameter propertyVector: The property vector to be defined.
     */
    public func define(propertyVector: INDIPropertyVector) {
        
    }
    
    /**
     * Returns the current value(s) of the property specified by the name.
     *  - Parameter name: The name of the property.
     *  - Returns: The property vector containing the value.
     */
    public func getPropertyVector(name : String) -> INDIPropertyVector? {
        return nil
    }
    
    /**
     * Sends a new set of values for an INDI property vector.
     * - Parameter propertyVector: The property vector to be set.
     */
    public func set(propertyVector: INDIPropertyVector) {
        
    }
    
    /**
     * Deletes an INDI property vector from the device.
     * - Parameter propertyVector: The property vector to be deleted.
     */
    public func delete(propertyVector: INDIPropertyVector) {
        
    }
    
    /**
     * Deletes an INDI property from the device.
     * - Parameter property: The property to be deleted.
     */
    public func delete(property: INDIProperty) {
        
    }
}
