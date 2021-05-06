//
//  INDIControllerModel.swift
//  INDI Controller
//
//  Created by Don Willems on 04/05/2021.
//  Copyright © 2021 lapsedpacifist. All rights reserved.
//

import Foundation
import SwiftINDI

class Server : NSObject, ObservableObject {
    
    var id : String {
        get {
            return name
        }
    }
    
    let name: String
    let url: String
    let port: Int
    @Published var connected: Bool = false
    @Published var autoConnect: Bool = false
    @Published var devices = [Device]()
    
    public init(name: String, url: String, port: Int, autoConnect: Bool = false) {
        self.name = name
        self.url = url
        self.port = port
        self.autoConnect = autoConnect
    }
    
    public func add(device: Device) {
        devices.append(device)
    }
    
    static func == (lhs: Server, rhs: Server) -> Bool {
        return lhs.id == rhs.id
    }
}

class Device : NSObject, ObservableObject  {
    
    let id : String
    
    let name: String
    let server: Server
    
    @Published var groups = [Group]()
    @Published var propertyVectors = [PropertyVector]()
    
    public init(name: String, server: Server) {
        self.id = "\(server.id)/\(name)"
        self.name = name
        self.server = server
    }
    
    static func == (lhs: Device, rhs: Device) -> Bool {
        return lhs.id == rhs.id
    }
    
    public func add(group: Group) {
        self.groups.append(group)
    }
    
    public func add(propertyVector: PropertyVector) {
        self.propertyVectors.append(propertyVector)
    }
}

class Group : NSObject, ObservableObject {
    
    let id : String
    let name: String
    let device: Device
    
    @Published var propertyVectors = [PropertyVector]()
    
    public init(name: String, device: Device) {
        self.id = "\(device.id)/\(name)"
        self.name = name
        self.device = device
    }
    
    public func add(propertyVector: PropertyVector) {
        self.propertyVectors.append(propertyVector)
    }
}

class PropertyVector : NSObject, ObservableObject {
    
    let id : String
    let name: String
    let label: String
    let canBeRead: Bool
    let canBeWrittenTo: Bool
    let timeout: Int
    let group: Group
    
    @Published var state: INDIPropertyState = .ok
    @Published var timestamp: Date = Date()
    
    public init(name: String, label: String, group: Group, state: INDIPropertyState, canBeRead: Bool, canBeWrittenTo: Bool, timeout: Int, timestamp: Date) {
        self.id = "\(group.id)/\(name)"
        self.name = name
        self.label = label
        self.group = group
        self.state = state
        self.canBeRead = canBeRead
        self.canBeWrittenTo = canBeWrittenTo
        self.timestamp = timestamp
        self.timeout = timeout
    }
}


class INDIControllerModel : ObservableObject {
    
    @Published var servers = [Server]()
    @Published var devices = [Device]()
    var groups = [String: Group]()
    var propertyVectors = [String: PropertyVector]()
    
    var indiServers = [String: BasicINDIServer]()
    
    func add(server: Server) throws {
        let indiServer = BasicINDIServer(label: server.id, delegate: INDIMonitor(model: self, serverID: server.id))
        try indiServer.setServer(at: server.url, port: server.port)
        indiServers[server.id] = indiServer
        servers.append(server)
    }
    
    func server(id: String) -> Server? {
        for server in servers {
            if server.id == id {
                return server
            }
        }
        return nil
    }
    
    func add(device: Device) {
        device.server.add(device: device)
        devices.append(device)
    }
    
    func device(id: String) -> Device? {
        for device in devices {
            if device.id == id {
                return device
            }
        }
        return nil
    }
    
    func add(group: Group) -> Group {
        if self.group(id: group.id) == nil {
            let device = group.device
            objectWillChange.send()
            device.objectWillChange.send()
            device.add(group: group)
            self.groups[group.id] = group
            return group
        }
        return self.group(id: group.id)!
    }
    
    func group(id: String) -> Group? {
        return groups[id]
    }

    func add(propertyVector: PropertyVector) -> PropertyVector {
        if self.propertyVector(id: propertyVector.id) == nil {
            let group = propertyVector.group
            group.add(propertyVector: propertyVector)
            group.device.add(propertyVector: propertyVector)
            self.propertyVectors[propertyVector.id] = propertyVector
            return propertyVector
        } else {
            let vector = self.propertyVector(id: propertyVector.id)!
            vector.timestamp = propertyVector.timestamp
            vector.state = propertyVector.state
            return vector
        }
    }
    
    func propertyVector(id: String) -> PropertyVector? {
        return propertyVectors[id]
    }
    
    func connect(server: Server) {
        let indi = indiServers[server.id]
        if indi != nil {
            if !indi!.connected {
                objectWillChange.send()
                server.connected = true
                indi!.connect()
            }
        }
    }
    
    func disconnect(server: Server) {
        let indi = indiServers[server.id]
        if indi != nil {
            if indi!.connected {
                objectWillChange.send()
                server.connected = false
                indi!.disconnect()
            }
        }
    }
}

class INDIMonitor : INDIDelegate {
    
    var model : INDIControllerModel
    var serverID : String
    
    init(model: INDIControllerModel, serverID: String) {
        self.model = model
        self.serverID = serverID
    }
    
    func encounteredINDIError(_ server: BasicINDIServer, error: Error, message: String) {
        print("Encountered INDI error: \(error) with message:\n\(message)")
    }
    
    func connectionRequestIgnored(_ server: BasicINDIServer, to host: String?, port: Int, message: String) {
        print("Connection request ignored!")
        model.objectWillChange.send()
        model.server(id: serverID)?.connected = false
    }
    
    func willConnect(_ server: BasicINDIServer, to host: String, port: Int) {
        print("Will connect to server at \(host):\(port)")
    }
    
    func didConnect(_ server: BasicINDIServer, to host: String, port: Int) {
        print("Did connect to server at \(host):\(port)")
    }
    
    func willDisconnect(_ server: BasicINDIServer, from host: String, port: Int) {
        print("Will disconnect from server at \(host):\(port)")
    }
    
    func didDisconnect(_ server: BasicINDIServer, from host: String, port: Int) {
        print("Did disconnect from server at \(host):\(port)")
    }
    
    func recievedData(_ server: BasicINDIServer, size: Int, xml: String, from host: String, port: Int) {
        print("Recieved \(size) bytes of data. <- \(xml)")
    }
    
    func sendData(_ server: BasicINDIServer, size: Int, xml: String, from host: String, port: Int) {
        print("Send \(size) bytes of data. -> \(xml)")
    }
    
    func deviceDefined(_ server: BasicINDIServer, device: INDIDevice) {
        print("Device \(device.name) defined.")
        let modelServer = model.server(id: serverID)
        if modelServer != nil {
            let modelDevice = Device(name: device.name, server: modelServer!)
            model.add(device: modelDevice)
        }
    }
    
    func propertyVectorDefined(_ server: BasicINDIServer, device: INDIDevice, propertyVector: INDIPropertyVector) {
        print("Property vector \(propertyVector.name) for device \(device.name) defined.")
        let modelServer = model.server(id: serverID)
        if modelServer != nil {
            let modelDevice = Device(name: device.name, server: modelServer!)
            var group = Group(name:"\(propertyVector.group != nil ? propertyVector.group! : "Other")", device: modelDevice)
            group = model.add(group: group)
            var vector = PropertyVector(name: propertyVector.name, label: propertyVector.label ?? propertyVector.name, group: group, state: propertyVector.state, canBeRead: propertyVector.canBeRead, canBeWrittenTo: propertyVector.canBeWritten, timeout: propertyVector.timeout, timestamp: propertyVector.timestamp ?? Date())
            vector = model.add(propertyVector: vector)
        }
    }
    
    func propertyDefined(_ server: BasicINDIServer, device: INDIDevice, propertyVector: INDIPropertyVector, property: INDIProperty) {
        print("Property \(property.name) for vector \(propertyVector.name) for device \(device.name) defined.")
        if property.name == "DRIVER_INTERFACE" {
            print("     Device interface type: \(device.deviceTypes)")
        }
    }
    
    func propertyWillChange(_ server: BasicINDIServer, property: INDIProperty, device: INDIDevice) {
        print("Property \(property.name) for device \(device.name) will change. Value= \(property.value ?? "Not set")")
    }
    
    func propertyDidChange(_ server: BasicINDIServer, property: INDIProperty, device: INDIDevice) {
        print("Property \(property.name) for device \(device.name) did change. Value= \(property.value ?? "Not set")")
    }
}
