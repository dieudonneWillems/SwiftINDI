//
//  INDIClientController.swift
//  INDI Client
//
//  Created by Don Willems on 20/03/2020.
//  Copyright © 2020 lapsedpacifist. All rights reserved.
//

import Cocoa
import SwiftINDI
import SwiftINDIGUI

class INDIClientController : NSObject, INDIDelegate {
    
    var servers = [BasicINDIServer]()
    
    var serverController : INDIServerController? = nil {
        didSet {
            oldValue?.removeAllServers()
            serverController?.removeAllServers()
            for server in servers {
                serverController?.addClient(server)
            }
        }
    }
    
    func addINDIServer(at host: String, port: Int, with label: String? = nil) {
        let indiClient = BasicINDIServer(label: label, delegate: self)
        do {
            try indiClient.setServer(at: host, port: port)
            servers.append(indiClient)
            serverController?.addClient(indiClient)
            indiClient.connect()
        } catch {
            print(error)
        }
    }
    
    func disconnect(client: BasicINDIServer) {
        client.disconnect()
    }
    
    func disconnectAllClients() {
        for server in servers {
            server.disconnect()
        }
    }
    
    
    // MARK: - INDI Delegate
     
    func recievedData(_ server: BasicINDIServer, size: Int, xml: String, from host: String, port: Int) {
        print("Recieved data from the INDI server of size \(size):\n\(xml)")
    }
     
    func encounteredINDIError(_ server: BasicINDIServer, error: Error, message: String) {
        print("Error encountered: \(message) => \(error)")
    }

    func connectionRequestIgnored(_ server: BasicINDIServer, to host: String?, port: Int, message: String) {
        print("Connection request ignored: \(message)")
    }

    func willConnect(_ server: BasicINDIServer, to host: String, port: Int) {
        print("Will connect \(server)")
    }

    func didConnect(_ server: BasicINDIServer, to host: String, port: Int) {
        print("Did connect \(server)")
    }

    func willDisconnect(_ server: BasicINDIServer, from host: String, port: Int) {
        print("Will disconnect \(server)")
    }

    func didDisconnect(_ server: BasicINDIServer, from host: String, port: Int) {
        print("Did disconnect \(server)")
    }
     
    /**
     * Called when a new device was defined (created) in the client as a result of a response from the INDI server.
     * - Parameter server: The `BasicINDIServer` which was disconnected from the server.
     * - Parameter device: The device that was defined.
    */
    func deviceDefined(_ server: BasicINDIServer, device: INDIDevice) {
        print("A device with name '\(device.name)' was defined")
        let appDelegate = (NSApplication.shared.delegate as! AppDelegate)
        appDelegate.serverController?.reload()
    }
     
    /**
     * Called when a new property vector was defined (created) in the client as a result of a response from the INDI server.
     * - Parameter server: The `BasicINDIServer` which was disconnected from the server.
     * - Parameter device: The device for which a property vector was defined.
     * - Parameter propertyVector: The property vector that was defined.
     */
    func propertyVectorDefined(_ server: BasicINDIServer, device: INDIDevice, propertyVector: INDIPropertyVector) {
        print("A property vector with name '\(propertyVector.name)' was defined for device '\(device.name)'")
        let appDelegate = (NSApplication.shared.delegate as! AppDelegate)
        appDelegate.serverController?.reload()
    }
     
    /**
     * Called when a new property was defined (created) in the client as a result of a response from the INDI server.
     * - Parameter server: The `BasicINDIServer` which was disconnected from the server.
     * - Parameter device: The device for which a property vector was defined.
     * - Parameter propertyVector: The property vector of which the newly defined property is a member.
     * - Parameter property: The property that was defined.
     */
     func propertyDefined(_ server: BasicINDIServer, device: INDIDevice, propertyVector: INDIPropertyVector, property: INDIProperty) {
        print("A property with name '\(property.name)' as a member of vector '\(propertyVector.name)' was defined for device '\(device.name)'")
        let appDelegate = (NSApplication.shared.delegate as! AppDelegate)
        appDelegate.serverController?.reload()
     }
     
     /**
      * Called when a property's value will change.
      * - Parameter server: The `BasicINDIServer`.
      * - Parameter property: The property whose value will be changed.
      * - Parameter device: The device for which the property was defined.
      */
    func propertyWillChange(_ server: BasicINDIServer, property: INDIProperty, device: INDIDevice) {
        print("The value of the property \(property.name) will change.")
    }
     
     /**
      * Called when a property's value did change.
      * - Parameter server: The `BasicINDIServer`.
      * - Parameter property: The property whose value was changed.
      * - Parameter device: The device for which the property was defined.
      */
    func propertyDidChange(_ server: BasicINDIServer, property: INDIProperty, device: INDIDevice) {
        print("The value of the property \(property.name) did change.")
    }
}
