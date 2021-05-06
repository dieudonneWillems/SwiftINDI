//
//  INDIDevice.swift
//  SwiftINDI
//
//  Created by Don Willems on 14/03/2020.
//  Copyright © 2020 lapsedpacifist. All rights reserved.
//

import Foundation

/**
 * The different types of interfaces that are supported by the devices driver.
 *
 * A driver can support multiple interfaces, e.g. a telescope and a guider.
 * The driver interface is specified in the `DRIVER_INTERFACE` property of the `DRIVER_INFO`
 * property vector. The driver interface value is a bitwise AND combination of the cases in this
 * enumeration.
 *
 * The enumeration was originally defined in C++ in https://indilib.org/api/basedevice_8h_source.html
 */
public enum INDIInterfaceType : UInt16, CaseIterable {
    case general        = 0
    case telescope      = 1
    case CCD            = 2
    case guider         = 4
    case focuser        = 8
    case filter         = 16
    case dome           = 32
    case GPS            = 64
    case weather        = 128
    case adaptiveOptics = 256
    case dustcap        = 512
    case lightBox       = 1024
    case detector       = 2048
    case rotator        = 4096
    case spectograph    = 8192
    case correlator     = 16384
    case auxiliary      = 32768
 //   case sensor         = (1 << 13) | (1 << 11) | (1 << 14)[0,1,2,4,8,16,32,64,128,256,512,1024,2048,4096,8192,16384]
}

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
     * The INDI server to which this device is connected
     */
    public let server : BasicINDIServer
    
    /**
     * All the device types that are supported by this device.
     * A device can have multiple device types as it supports multiple interfaces, e.g. a device might
     * function both as a telescope and a guider.
     */
    public var deviceTypes: [INDIInterfaceType] {
        get {
            var types = [INDIInterfaceType]()
            for type in INDIInterfaceType.allCases {
                if self.supportsDeviceType(type) {
                    types.append(type)
                }
            }
            return types
        }
    }
    
    private var driverInterface: UInt16 {
        get {
            let interfacePropValue = self.propertyVector(name: "DRIVER_INFO")?.property(name: "DRIVER_INTERFACE")?.value
            if interfacePropValue != nil {
                let intValue = UInt16(String("\(interfacePropValue!)"))
                if intValue != nil {
                    return intValue!
                }
            }
            return 0
        }
    }
    
    /**
     * Initialises a device with the specified name.
     *
     * - Parameter name: The name of the device.
     */
    public init(name: String, server: BasicINDIServer) {
        self.name = name
        self.server = server
    }
    
    /**
     * Determines whether the device  supports the specific device interface  type.
     *
     * - Parameter type: The interface type being queried.
     * - Returns: True when the interface is supported by the device, false otherwise.
     */
    public func supportsDeviceType(_ type: INDIInterfaceType) -> Bool {
        let andOpp = (driverInterface & type.rawValue)
        return andOpp > 0
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
    public func propertyVector(name : String) -> INDIPropertyVector? {
        for vector in self.propertyVectors {
            if vector.name == name {
                return vector
            }
        }
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
    
    
    /**
     * This method chould be called when a property's value will change. The device will be
     * notified by the property vector whose property will change.
     *
     * - Parameter property: The property that has will change.
     * - Parameter propertyVector: The property vector whose property will change.
     * - Parameter newValue: The new value of the property.
     */
    func property(_ property: INDIProperty, in propertyVector: INDIPropertyVector, willChangeTo newValue: Any?) {
        server.property(property, for: self, willChangeTo: newValue)
    }
    
    /**
     * This method chould be called when a property's value has changed. The device will be
     * notified by the property vector whose property has changed.
     *
     * - Parameter property: The property that has been changed.
     * - Parameter propertyVector: The property vector whose property has changed.
     * - Parameter newValue: The new value of the property.
     */
    func property(_ property: INDIProperty, in propertyVector: INDIPropertyVector, hasChangedTo newValue: Any?) {
        server.property(property, for: self, hasChangedTo: newValue)
    }
}
