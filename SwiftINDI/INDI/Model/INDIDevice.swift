//
//  INDIDevice.swift
//  SwiftINDI
//
//  Created by Don Willems on 14/03/2020.
//  Copyright © 2020 lapsedpacifist. All rights reserved.
//

import Foundation

/**
 * This class represents a device connected to  an INDI server.
 */
public class INDIDevice {
    
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
        if !self.propertyVectors.contains(where: { $0 == propertyVector }) {
            self.propertyVectors.append(propertyVector)
        } else {
            let index = self.propertyVectors.firstIndex(where: { $0 == propertyVector })
            if index != nil {
                self.propertyVectors.remove(at: index!)
            }
            self.propertyVectors.append(propertyVector)
        }
    }
    
    /**
     * Returns the current value(s) of the property specified by the name.
     *  - Parameter name: The name of the property.
     *  - Returns: The property vector containing the value.
     */
    public func getPropertyVector(name : String) -> INDIPropertyVector? {
        // TODO: Implement function
        return nil
    }
    
    /**
     * Sends a new set of values for an INDI property vector.
     * - Parameter propertyVector: The property vector to be set.
     */
    public func set(propertyVector: INDIPropertyVector) {
        // TODO: Implement function
    }
    
    /**
     * Deletes an INDI property vector from the device.
     * - Parameter propertyVector: The property vector to be deleted.
     */
    public func delete(propertyVector: INDIPropertyVector) {
        // TODO: Implement function
    }
    
    /**
     * Deletes an INDI property from the device.
     * - Parameter property: The property to be deleted.
     */
    public func delete(property: INDIProperty) {
        // TODO: Implement function
    }
    
    // MARK: - Access to property vectors and properties
    
    /**
     * The list of groups that were defined in the properties for this device.
     */
    public var groups : [String] {
        get {
            var groups = [String]()
            for propertyVector in self.propertyVectors {
                var pvgroup = propertyVector.group
                if pvgroup == nil {
                    pvgroup = "Other"
                }
                if !groups.contains(pvgroup!) {
                    groups.append(pvgroup!)
                }
            }
            return groups
        }
    }
    
    /**
     * Returns the property vectors for this device that are part of a named group.
     * - Parameter group: The name of the group.
     * - Returns: The set of property vectors in a specific group.
     */
    public func propertyVectors(in group: String) -> [INDIPropertyVector]{
        var grouped = [INDIPropertyVector]()
        for propertyVector in self.propertyVectors {
            if group == propertyVector.group {
                grouped.append(propertyVector)
            } else if group == "Other" && propertyVector.group == nil {
                grouped.append(propertyVector)
            }
        }
        return grouped
    }
}
