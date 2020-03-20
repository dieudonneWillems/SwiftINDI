//
//  INDIClientController.swift
//  INDI Client
//
//  Created by Don Willems on 20/03/2020.
//  Copyright © 2020 lapsedpacifist. All rights reserved.
//

import Cocoa
import SwiftINDI

class INDIClientController : NSObject, INDIDelegate {
    
    var clients = [BasicINDIClient]()
    
    func addINDIServer(at host: String, port: Int) {
        let indiClient = BasicINDIClient(delegate: self)
        do {
            try indiClient.setServer(at: host, port: port)
            clients.append(indiClient)
            indiClient.connect()
        } catch {
            print(error)
        }
    }
    
    func disconnect(client: BasicINDIClient) {
        client.disconnect()
    }
    
    func disconnectAllClients() {
        for client in clients {
            client.disconnect()
        }
    }
    
    
    // MARK: - INDI Delegate
     
     func recievedData(_ client: BasicINDIClient, size: Int, xml: String, from server: String, port: Int) {
         print("Recieved data from the INDI server of size \(size):\n\(xml)")
     }
     
     func encounteredINDIError(_ client: BasicINDIClient, error: Error, message: String) {
         print("Error encountered: \(message) => \(error)")
     }
     
     func connectionRequestIgnored(_ client: BasicINDIClient, to server: String?, port: Int, message: String) {
         print("Connection request ignored: \(message)")
     }
     
     func willConnect(_ client: BasicINDIClient, to server: String, port: Int) {
         print("Will connect \(client)")
     }
     
     func didConnect(_ client: BasicINDIClient, to server: String, port: Int) {
         print("Did connect \(client)")
     }
     
     func willDisconnect(_ client: BasicINDIClient, from server: String, port: Int) {
         print("Will disconnect \(client)")
     }
     
     func didDisconnect(_ client: BasicINDIClient, from server: String, port: Int) {
         print("Did disconnect \(client)")
     }
     
     /**
      * Called when a new device was defined (created) in the client as a result of a response from the INDI server.
      * - Parameter client: The `BasicINDIClient` which was disconnected from the server.
      * - Parameter device: The device that was defined.
      */
     func deviceDefined(_ client: BasicINDIClient, device: INDIDevice) {
         print("A device with name '\(device.name)' was defined")
     }
     
     /**
      * Called when a new property vector was defined (created) in the client as a result of a response from the INDI server.
      * - Parameter client: The `BasicINDIClient` which was disconnected from the server.
      * - Parameter device: The device for which a property vector was defined.
      * - Parameter propertyVector: The property vector that was defined.
      */
     func propertyVectorDefined(_ client: BasicINDIClient, device: INDIDevice, propertyVector: INDIPropertyVector) {
         print("A property vector with name '\(propertyVector.name)' was defined for device '\(device.name)'")
     }
     
     /**
      * Called when a new property was defined (created) in the client as a result of a response from the INDI server.
      * - Parameter client: The `BasicINDIClient` which was disconnected from the server.
      * - Parameter device: The device for which a property vector was defined.
      * - Parameter propertyVector: The property vector of which the newly defined property is a member.
      * - Parameter property: The property that was defined.
      */
     func propertyDefined(_ client: BasicINDIClient, device: INDIDevice, propertyVector: INDIPropertyVector, property: INDIProperty) {
         print("A property with name '\(property.name)' as a member of vector '\(propertyVector.name)' was defined for device '\(device.name)'")
     }
}
