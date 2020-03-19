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
    public private(set) var properties = [INDIPropertyVector]()
    
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
}
