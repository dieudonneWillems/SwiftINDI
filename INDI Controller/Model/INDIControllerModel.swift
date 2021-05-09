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
    @Published var devices = [String]()
    
    public init(name: String, url: String, port: Int, autoConnect: Bool = false) {
        self.name = name
        self.url = url
        self.port = port
        self.autoConnect = autoConnect
    }
    
    public func add(device: Device) {
        devices.append(device.id)
    }
    
    static func == (lhs: Server, rhs: Server) -> Bool {
        return lhs.id == rhs.id
    }
}

class Device : NSObject, ObservableObject  {
    
    let id : String
    
    let name: String
    let server: String
    
    var groups = [String]()
    var propertyVectors = [String]()
    
    public init(name: String, server: Server) {
        self.id = "\(server.id)/\(name)"
        self.name = name
        self.server = server.id
    }
    
    static func == (lhs: Device, rhs: Device) -> Bool {
        return lhs.id == rhs.id
    }
    
    public func add(group: Group) {
        self.groups.append(group.id)
    }
    
    public func add(propertyVector: PropertyVector) {
        self.propertyVectors.append(propertyVector.id)
    }
}

class Group : NSObject, ObservableObject {
    
    let id : String
    let name: String
    let device: String
    
    @Published var propertyVectors = [String]()
    
    public init(name: String, device: Device) {
        self.id = "\(device.id)/\(name)"
        self.name = name
        self.device = device.id
    }
    
    public func add(propertyVector: PropertyVector) {
        self.propertyVectors.append(propertyVector.id)
    }
}

class PropertyVector : NSObject, ObservableObject {
    
    let id : String
    let name: String
    let label: String
    let canBeRead: Bool
    let canBeWrittenTo: Bool
    let timeout: Int
    let group: String
    
    @Published var state: INDIPropertyState = .ok
    @Published var timestamp: Date = Date()
    
    public init(name: String, label: String, group: Group, state: INDIPropertyState, canBeRead: Bool, canBeWrittenTo: Bool, timeout: Int, timestamp: Date) {
        self.id = "\(group.id)/\(name)"
        self.name = name
        self.label = label
        self.group = group.id
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
    @Published var propertyVectors = [PropertyVector]()
    @Published var groups = [Group]()
    
    var indiServers = [String: BasicINDIServer]()
    
    func add(server: Server) throws {
        let indiServer = BasicINDIServer(label: server.id, delegate: INDIMonitor(model: self, serverID: server.id))
        try indiServer.setServer(at: server.url, port: server.port)
        indiServers[server.id] = indiServer
        indiServer.connect()
        servers.append(server)
    }
    
    var connectedServers : [Server] {
        get {
            var cservers = [Server]()
            for server in servers {
                if server.connected {
                    cservers.append(server)
                }
            }
            return cservers
        }
    }
    
    func server(id: String) -> Server? {
        for server in servers {
            if server.id == id {
                return server
            }
        }
        return nil
    }
    
    func add(device: Device) -> Device {
        if self.device(id: device.id) == nil {
            let server = self.server(id: device.server)
            server?.add(device: device)
            devices.append(device)
            return device
        } else {
            return self.device(id: device.id)!
        }
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
            let device = self.device(id: group.device)!
            objectWillChange.send()
            device.objectWillChange.send()
            device.add(group: group)
            self.groups.append(group)
            return group
        }
        return self.group(id: group.id)!
    }
    
    func group(id: String) -> Group? {
        for group in groups {
            if group.id == id {
                return group
            }
        }
        return nil
    }

    func add(propertyVector: PropertyVector) -> PropertyVector {
        if self.propertyVector(id: propertyVector.id) == nil {
            let group = self.group(id: propertyVector.group)
            let device = self.device(id: group!.device)
            group!.add(propertyVector: propertyVector)
            device!.add(propertyVector: propertyVector)
            self.propertyVectors.append(propertyVector)
            return propertyVector
        } else {
            let vector = self.propertyVector(id: propertyVector.id)!
            vector.timestamp = propertyVector.timestamp
            vector.state = propertyVector.state
            return vector
        }
    }
    
    func propertyVector(id: String) -> PropertyVector? {
        for propertyVector in propertyVectors {
            if propertyVector.id == id {
                return propertyVector
            }
        }
        return nil
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
            _ = model.add(device: modelDevice)
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
