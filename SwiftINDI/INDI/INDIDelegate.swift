//
//  INDIDelegate.swift
//  SwiftINDI
//
//  Created by Don Willems on 14/03/2020.
//  Copyright © 2020 lapsedpacifist. All rights reserved.
//

import Foundation


/**
 * This protocol defines the interface for creating an `INDIDelegate`. Instances will recieve events such as connecting or disconnecting devices,
 * changes to the state of a device (changes of INDI properties), or when data is recieved.
 */
public protocol INDIDelegate {
    
    // MARK: - Errors and warnings
    
    /**
     * This function is called when an error occurred in the INDI client.
     * - Parameter server: The `BasicINDIServer`.
     * - Parameter error: The error that ocurred.
     * - Parameter message: A human readable message explaining the error that ocurred.
     */
    func encounteredINDIError(_ server: BasicINDIServer, error: Error, message: String)
    
    /**
     * This function is called when a connection request was ignored. This may happen when a connection attempt i
     * is made while the client is already connected to the INDI server.
     * - Parameter server: The `BasicINDIServer`.
     * - Parameter host: The server address (host) .
     * - Parameter port: The port.
     * - Parameter message: A human readable message explaining while the request was ignored.
     */
    func connectionRequestIgnored(_ server: BasicINDIServer, to host: String?, port: Int, message: String)
    
    
    // MARK: - Connecting and Disconnecting from an INDI server
    
    /**
     * This function is called when an INDI client is about to be connected to the specified server.
     * - Parameter server: The `BasicINDIServer` which is to be connected to the server.
     * - Parameter host: The server address (host) .
     * - Parameter port: The port at which the client is to be connected to the server.
     */
    func willConnect(_ server: BasicINDIServer, to host: String, port: Int)
    
    /**
     * This function is called when an INDI client has been connected to the specified server.
     * - Parameter server: The `BasicINDIServer` which was connected to the server.
     * - Parameter host: The server address (host) .
     * - Parameter port: The port at which the client is connected to the server.
     */
    func didConnect(_ server: BasicINDIServer, to host: String, port: Int)
    
    /**
     * This function is called when an INDI client is about to be disconnected from the specified server.
     * - Parameter server: The `BasicINDIServer` which is to be disconnected from its server.
     * - Parameter host: The server address (host) .
     * - Parameter port: The port at which the client is connected to the server.
     */
    func willDisconnect(_ server: BasicINDIServer, from host: String, port: Int)
    
    /**
     * This function is called when an INDI client has been disconnected from the specified server.
     * - Parameter server: The `BasicINDIServer` which was disconnected from the server.
     * - Parameter host: The server address (host) .
     * - Parameter port: The port at which the client was connected to the server.
     */
    func didDisconnect(_ server: BasicINDIServer, from host: String, port: Int)
    
    
    // MARK: - Recieving data from the INDI server
    
    /**
     * This function is called when an INDI client recieves data from the INDI server. The recieved data is
     * in XML form. It provides access to raw INDI XML data.
     * - Parameter server: The `BasicINDIServer` which was disconnected from the server.
     * - Parameter size: The number of bytes recieved.
     * - Parameter xml: The XML string that was recieved.
     * - Parameter server: The server address (host) .
     * - Parameter port: The port at which the client was connected to the server.
     */
    func recievedData(_ server: BasicINDIServer, size: Int, xml: String, from server: String, port: Int)
    
    
    // MARK: - Defining devices, property vectors and properties
    
    /**
     * Called when a new device was defined (created) in the client as a result of a response from the INDI server.
     * - Parameter server: The `BasicINDIServer` which was disconnected from the server.
     * - Parameter device: The device that was defined.
     */
    func deviceDefined(_ server: BasicINDIServer, device: INDIDevice)
    
    /**
     * Called when a new property vector was defined (created) in the client as a result of a response from the INDI server.
     * - Parameter server: The `BasicINDIServer` which was disconnected from the server.
     * - Parameter device: The device for which a property vector was defined.
     * - Parameter propertyVector: The property vector that was defined.
     */
    func propertyVectorDefined(_ server: BasicINDIServer, device: INDIDevice, propertyVector: INDIPropertyVector)
    
    /**
     * Called when a new property was defined (created) in the client as a result of a response from the INDI server.
     * - Parameter server: The `BasicINDIServer` which was disconnected from the server.
     * - Parameter device: The device for which a property vector was defined.
     * - Parameter propertyVector: The property vector of which the newly defined property is a member.
     * - Parameter property: The property that was defined.
     */
    func propertyDefined(_ server: BasicINDIServer, device: INDIDevice, propertyVector: INDIPropertyVector, property: INDIProperty)
}
