//
//  BasicINDIServer.swift
//  SwiftINDI
//
//  Created by Don Willems on 10/03/2020.
//  Copyright © 2020 lapsedpacifist. All rights reserved.
//

import Foundation
import SwiftSocket

/**
 * This class represents the basic INDI client providing low level (INDI) communication with an INDI server instance.
 *
 * Before connecting a client to a server, the server needs first to be specified using the function `setServer(at host: String, port: Int = 7642)`.
 * The client can then establish a TCP connection using the function `connect()`. To disconnect use the function `disconnect()`.
 */
public class BasicINDIServer : CustomStringConvertible {
    
    /**
     * The ISO 8601 Date formatter to parse timestamps.
     */
    private static func iso8601() -> DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        return formatter
    }
    
    /**
     * An optional label (name) to be used when displaying information about the client-server connection.
     */
    public var label: String?
    
    /**
     * The server adress (host) to which the client can be connected.
     *
     * This value can be `nil` when the server has not been specified yet. To specify
     * the server and the port to be used, use the function
     * `setServer(at host: String, port: Int = 7642)`.
     */
    public private(set) var host : String?
    
    /**
     * The server port to which the client is connected (default is 7642).
     *
     * To specify the server and the port to be used, use the function
     * `setServer(at host: String, port: Int = 7642)`.
     */
    public private(set) var port : Int = 7624
    
    /**
     * The `INDIDelegate` instance that will recieve events such as when a device is connected or disconnected,
     * when device parameters change, or when data is recieved.
     */
    public var delegate : INDIDelegate?
    
    /**
     * This flag indicates whether the client is connected to the server (i.e. when an active TCP connection between
     * client and server exists.
     */
    public private(set) var connected : Bool = false
    
    /**
     * The TCP connection socket to the server.
     */
    private var tcpClient : TCPClient? = nil
    
    /**
     * The names of the devices connected to the INDI server.
     */
    public var deviceNames : [String] {
        get {
            return Array(devices.keys)
        }
    }
    
    /**
     * A dictionary of devices (INDI drivers) loaded by the INDI server.
     */
    public private(set) var devices = [String : INDIDevice]()
    
    /**
     * Returns a string representation describing the client.
     */
    public var description: String {
        get {
            if connected {
                return "INDI Client connected to INDI Server at \(host!) with port \(port)"
            } else if host != nil {
                return "INDI Client disconnected from INDI Server at \(host!) with port \(port)"
            }
            return "INDI Client not associated with an INDI Server."
        }
    }
    
    /**
     * Initialises the client.
     *
     * No delegate is specified for the client (use the property`delegate: INDIDelegate`) to set the delegate.
     * After initialisation no server has been defined with which the client should connect. Use
     * `setServer(at host: String, port: Int = 7642)` to specify the server and port.
     */
    public init() {
    }
    
    /**
     * Initialises the client with the specified label to be used in a GUI.
     *
     * No delegate is specified for the client (use the property`delegate: INDIDelegate`) to set the delegate.
     * After initialisation no server has been defined with which the client should connect. Use
     * `setServer(at host: String, port: Int = 7642)` to specify the server and port.
     *
     * - Parameter label: The label presented to the user.
     */
    public init(label: String?) {
        self.label = label
    }
    
    /**
     * Initialises the client with the specified delegate that will recieve events. The delegate will recieve events such
     * as when a device is connected or disconnected, when device parameters change, or when data is recieved.
     *
     * After initialisation no server has been defined with which the client should connect. Use
     * `setSetver(at host: String, port: Int = 7642)` to specify the server and port.
     *
     * - Parameter delegate: The `INDIDelegate` that will recieve events.
     */
    public init(delegate: INDIDelegate) {
        self.delegate = delegate
    }
    
    /**
     * Initialises the client with the specified delegate that will recieve events. The delegate will recieve events such
     * as when a device is connected or disconnected, when device parameters change, or when data is recieved.
     * The user can also specify a label to represent the client to the user in a GUI.
     *
     * After initialisation no server has been defined with which the client should connect. Use
     * `setSetver(at host: String, port: Int = 7642)` to specify the server and port.
     *
     * - Parameter label: The label presented to the user.
     * - Parameter delegate: The `INDIDelegate` that will recieve events.
     */
    public init(label: String?, delegate: INDIDelegate) {
        self.delegate = delegate
        self.label = label
    }
    
    // MARK: - Connecting to the INDI server
    
    /**
     * Sets the server (host) and port to which the client can connect. You will need to use this function to
     * specify the server before a connection can be established and the client can be used.
     *
     * This function will throw an error when the client is already connected. If the client is not connected,
     * the server and port can be changed.
     *
     * - Parameter host: The server host address.
     * - Parameter port: The port to which the client will connect. Default is the default INDI port `7624`.
     * - Throws: When the client has an active connection to an INDI server.
     */
    public func setServer(at host: String, port: Int = 7642) throws {
        if connected {
            throw INDIError.connectionError(message: "The server cannot be changed when a connection to (another) INDI server already exists. The server should first be disconnected.")
        }
        self.host = host
        self.port = port
    }
    
    /**
     * Connects the client to the INDI server (establishes a TCP connection with the server).
     *
     * To be able to connect to a server, the server first needs to be specified using the function
     * `setServer(at host: String, port: Int = 7642)`.
     * When the server has not yet been specified
     * or when the connection cannot be established, an error will be thrown.
     */
    public func connect() {
        if connected {
            delegate?.connectionRequestIgnored(self, to: host, port: port, message: "The INDI client was already connected to the INDI server.")
            return
        }
        if host == nil {
            let message = "No INDI server was defined, no connection could be made therefore."
            let error = INDIError.connectionError(message: message)
            self.delegate?.encounteredINDIError(self, error: error, message: message)
        }
        delegate?.willConnect(self, to: host!, port: port)
        self.tcpClient = TCPClient(address: self.host!, port: Int32(port))
        DispatchQueue.global(qos: .utility).async { // Start new utility thread
            switch self.tcpClient!.connect(timeout: 1) {
                case .success:
                    self.connected = true
                    DispatchQueue.main.async {
                        self.delegate?.didConnect(self, to: self.host!, port: self.port)
                        self.listen()
                        self.loadDevices()
                    }
                case .failure(let error):
                    DispatchQueue.main.async {
                        let message = "No connection to the INDI server at \(self.host!) and port \(self.port) could be established."
                        let error = INDIError.connectionError(message: message, causedBy: error)
                        self.delegate?.encounteredINDIError(self, error: error, message: message)
                        self.delegate?.connectionRequestIgnored(self, to: self.host, port: self.port, message: "The INDI could not connect to the INDI server.")
                    }
            }
        }
    }
    
    /**
     * Disconnects the client from the INDI server.
     *
     * The TCP connection will be closed.
     */
    public func disconnect() {
        if !connected {
            delegate?.connectionRequestIgnored(self, to: host, port: port, message: "The INDI client was not connected to the INDI server and cannot be disconnected therefore.")
            return
        }
        delegate?.willDisconnect(self, from: host!, port: port)
        self.connected = false
        tcpClient?.close()
        tcpClient = nil
        delegate?.didDisconnect(self, from: host!, port: port)
    }
    
    /**
     * Requests the list of devices and properties from the INDI server. When devices or properties are found,
     * events will be forwarded to the delegate.
     */
    private func loadDevices() {
        if !connected || tcpClient == nil {
            let message = "The INDI server is not connected."
            let error = INDIError.connectionError(message: message)
            self.delegate?.encounteredINDIError(self, error: error, message: message)
        }
        send(message: "<getProperties version=\"1.7\"/>")
        return
    }
    
    /**
     * Sends a string message to the INDI server.
     * - Parameter message: The message to be send.
     */
    private func send(message: String) {
        switch tcpClient!.send(string: message) {
            case .success:
                DispatchQueue.main.async {
                    let size = message.utf8.count
                    self.delegate?.sendData(self, size: size, xml: message, from: self.host!, port: self.port)
                }
                sleep(1)
            case .failure(let error):
                let message = "An error occurred when data was send to the INDI server."
                let indierror = INDIError.connectionError(message: message, causedBy: error)
                self.delegate?.encounteredINDIError(self, error: indierror, message: message)
        }
    }
    
    /**
     * Listen for incomming trafic.
     */
    private func listen() {
        DispatchQueue.global(qos: .background).async { // Start new background thread
            var current = "" // Current element to be parsed where characters are added to the stream
            var nodeDepth = 0 // The depth of the element. Elements are returned (current) when the element at depth 0 is closed.
            var lastc = "" // The previous character added.
            var nodeBeingClosed = false // Is true when the element is being closed, "</" was encountered.
            while self.connected && self.tcpClient != nil {
                //print("-- \(Date())")
                guard let d = self.tcpClient!.read(1, timeout: 1) else { continue }
                let c = String(bytes: d, encoding: .utf8) // Current character.
                if c != nil {
                    current += c!
                    if lastc == "<" && c != "/" {  // Start new element
                        nodeDepth = nodeDepth + 1
                    } else if lastc == "/" && c == ">" {  // End current element
                        nodeDepth = nodeDepth - 1
                    } else if lastc == "<" && c == "/" { // Element starts with </, when this is closed with ">", the element will be closed.
                        nodeBeingClosed = true
                    } else if c == ">" && nodeBeingClosed { // Element line started with </ means that ">" closed the node.
                        nodeBeingClosed = false
                        nodeDepth = nodeDepth - 1
                    }
                    
                    lastc = c!
                    if nodeDepth == 0 {  // Root element has been found
                        let response = current.trimmingCharacters(in: .whitespacesAndNewlines)
                        //print("response=\n\(response)")
                        if response.count > 3 {
                            current = ""
                            lastc = ""
                            nodeBeingClosed = false
                            self.parseResponseAndCreateEvents(response: response)
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - Changing INDI property values
    
    /**
     * This method chould be called when a property's value has changed. The device will be
     * notified by the property vector whose property has changed.
     *
     * - Parameter property: The property that has been changed.
     * - Parameter propertyVector: The property vector whose property has changed.
     * - Parameter newValue: The new value of the property.
     */
    func property(_ property: INDIProperty, for device: INDIDevice, willChangeTo newValue: Any?) {
        self.delegate?.propertyWillChange(self, property: property, device: device)
    }
    
    /**
     * This method chould be called when a property's value has changed. The device will be
     * notified by the property vector whose property has changed.
     *
     * - Parameter property: The property that has been changed.
     * - Parameter propertyVector: The property vector whose property has changed.
     * - Parameter newValue: The new value of the property.
     */
    func property(_ property: INDIProperty, for device: INDIDevice, hasChangedTo newValue: Any?) {
        self.delegate?.propertyDidChange(self, property: property, device: device)
    }
    
    // MARK: - Parsing XML responses from the INDI server
    
    /**
     * Parses a (part of) a response from the INDI server XML in the main thread.
     * - Parameter response: The response string.
     */
    private func parseResponseAndCreateEvents(response: String) {
        DispatchQueue.main.async {
            do {
                self.delegate?.recievedData(self, size: response.count, xml: response, from: self.host!, port: self.port)
                try self.parseResponse(response)
            } catch {
                let message = "An error occurred when parsing the data to XML.\n\(response)"
                let indierror = INDIError.connectionError(message: message, causedBy: error)
                self.delegate?.encounteredINDIError(self, error: indierror, message: message)
            }
        }
    }
    
    /**
     * Parses the response into an XML DOM structure.
     *
     * - Parameter response: The response string recieved from the INDI server.
     * - Returns: The root element of the XML.
     */
    private func parseResponse(_ response : String) throws {
        let xmlParser = XMLParser(data: response.trimmingCharacters(in: .whitespacesAndNewlines).data(using: .utf8)!)
        let parserDelegate = INDIXMLParserDelegate()
        xmlParser.delegate = parserDelegate
        xmlParser.parse()
        if parserDelegate.element != nil {
            self.interpret(node: parserDelegate.element!)
        }
    }
    
    /**
     * Interprets the XML element and create, change, or delete devices and properties.
     * - Parameter node: The XML node.
     */
    private func interpret(node: INDINode) {
        if node.name != nil {
            if node.name!.starts(with: "def") {
                self.interpretDefinition(node: node)
            } else if node.name!.starts(with: "set") {
                self.interpretSet(node: node)
            } else if node.name!.starts(with: "delProperty") {
                           
            } else if node.name!.starts(with: "one") {
                                      
            }
        }
    }
    
    private func parseState(from stateString: String?) -> INDIPropertyState {
        var state : INDIPropertyState = .idle
        switch stateString?.lowercased() {
        case "idle":
            state = .idle
        case "ok":
            state = .ok
        case "busy":
            state = .busy
        case "alert":
            state = .alert
        default:
            state = .idle
        }
        return state
    }
    
    private func parsePermissions(from permString: String?) -> (read: Bool, write: Bool) {
        var readFlag = false
        var writeFlag = false
        if permString != nil && permString!.contains("r") {
            readFlag = true
        }
        if permString != nil && permString!.contains("w") {
            writeFlag = true
        }
        return (read: readFlag, write: writeFlag)
    }
    
    private func parseTimeOut(from timeoutString: String?) -> Int {
        var timeout = 0
        if timeoutString != nil {
            let timeoutInt = Int(timeoutString!)
            if timeoutInt != nil {
                timeout = timeoutInt!
            }
        }
        return timeout
    }
    
    private func parseTimestamp(from timestampString: String?) -> Date? {
        var timestamp : Date? = Date()
        if timestampString != nil {
            timestamp = BasicINDIServer.iso8601().date(from: timestampString!)
        }
        return timestamp
    }
    
    private func parseSwitchRule(from rule: String?) -> INDISwitchRule {
        var switchRule : INDISwitchRule = .oneOfMany
        switch rule {
        case "OneOfMany":
            switchRule = .oneOfMany
        case "AtMostOne":
            switchRule = .atMostOne
        case "AnyOfMany":
            switchRule = .anyOfMany
        default:
            switchRule = .oneOfMany
        }
        return switchRule
    }
    
    /**
     * Interprets a property set.
     * - Parameter node: The XML node.
     */
    private func interpretSet(node: INDINode) {
        let deviceName = node.attributes!["device"]
        let stateString = node.attributes!["state"]
        let state = self.parseState(from: stateString)
        let timeoutString = node.attributes!["timeout"]
        let timeout = self.parseTimeOut(from: timeoutString)
        let timestampString = node.attributes!["timestamp"]
        let timestamp : Date? = self.parseTimestamp(from: timestampString)
        if deviceName != nil {
            let device = self.devices[deviceName!]
            if device != nil {
                let propertyVectorName = node.attributes!["name"]!
                var propertyVector = device!.propertyVector(name: propertyVectorName)
                let message = node.attributes!["message"]
                propertyVector?.timestamp = timestamp
                propertyVector?.timeout = timeout
                propertyVector?.state = state
                propertyVector?.message = message
                if node.name! == "setTextVector" {
                    let textVector = propertyVector as? INDITextPropertyVector
                    if textVector != nil {
                        self.interpretTextPropertyChanges(from: node, inPropertyVector: textVector!)
                    } else {
                        // TODO: Call Error message
                    }
                } else if node.name! == "setNumberVector" {
                    let numberVector = propertyVector as? INDINumberPropertyVector
                    if numberVector != nil {
                        self.interpretNumberPropertyChanges(from: node, inPropertyVector: numberVector!)
                    } else {
                        // TODO: Call Error message
                    }
                } else if node.name! == "setSwitchVector" {
                    let switchVector = propertyVector as? INDISwitchPropertyVector
                    if switchVector != nil {
                        self.interpretSwitchPropertyChanges(from: node, inPropertyVector: switchVector!)
                    } else {
                        // TODO: Call Error message
                    }
                } else if node.name! == "setBLOBVector" {
                    // TODO: Remember to switch accepting BLOBs on!!!!
                }
            } else {
                // TODO: Call Error message
            }
        } else {
            // TODO: Call Error message
        }
    }
    
    /**
     * Interprets a property definition.
     * - Parameter node: The XML node.
     */
    private func interpretDefinition(node: INDINode) {
        let deviceName = node.attributes!["device"]
        let stateString = node.attributes!["state"]
        let state = self.parseState(from: stateString)
        let permString = node.attributes!["perm"]
        let perm = self.parsePermissions(from: permString)
        let timeoutString = node.attributes!["timeout"]
        let timeout = self.parseTimeOut(from: timeoutString)
        let timestampString = node.attributes!["timestamp"]
        let timestamp : Date? = self.parseTimestamp(from: timestampString)
        if deviceName != nil {
            var device = self.devices[deviceName!]
            if device == nil {
                device = INDIDevice(name: deviceName!, server: self)
                self.devices[deviceName!] = device
                delegate?.deviceDefined(self, device: device!)
            }
            if node.name! == "defTextVector" {
                let textVector = INDITextPropertyVector(node.attributes!["name"]!, device: device!, label: node.attributes!["label"], group: node.attributes!["group"], state: state, read: perm.read, write: perm.write, timeout: timeout, timestamp: timestamp, message: node.attributes!["message"])
                device!.define(propertyVector: textVector)
                delegate?.propertyVectorDefined(self, device: device!, propertyVector: textVector)
                self.interpretTextPropertyDefinitions(from: node, toIncludeIn: textVector)
            } else if node.name! == "defNumberVector" {
                let numberVector = INDINumberPropertyVector(node.attributes!["name"]!, device: device!, label: node.attributes!["label"], group: node.attributes!["group"], state: state, read: perm.read, write: perm.write, timeout: timeout, timestamp: timestamp, message: node.attributes!["message"])
                device!.define(propertyVector: numberVector)
                delegate?.propertyVectorDefined(self, device: device!, propertyVector: numberVector)
                self.interpretNumberPropertyDefinitions(from: node, toIncludeIn: numberVector)
            } else if node.name! == "defSwitchVector" {
                let switchRule = parseSwitchRule(from: node.attributes!["rule"])
                let switchVector = INDISwitchPropertyVector(node.attributes!["name"]!, device: device!, label: node.attributes!["label"], group: node.attributes!["group"], state: state, rule: switchRule, read: perm.read, write: perm.write, timeout: timeout, timestamp: timestamp, message: node.attributes!["message"])
                device!.define(propertyVector: switchVector)
                delegate?.propertyVectorDefined(self, device: device!, propertyVector: switchVector)
                self.interpretSwitchPropertyDefinitions(from: node, toIncludeIn: switchVector)
            } else if node.name! == "defLightVector" {
                let lightVector = INDILightPropertyVector(node.attributes!["name"]!, device: device!, label: node.attributes!["label"], group: node.attributes!["group"], state: state, timeout: timeout, timestamp: timestamp, message: node.attributes!["message"]!)
                device!.define(propertyVector: lightVector)
                delegate?.propertyVectorDefined(self, device: device!, propertyVector: lightVector)
                self.interpretLightPropertyDefinitions(from: node, toIncludeIn: lightVector)
            } else if node.name! == "defBLOBVector" {
                let blobVector = INDIBLOBPropertyVector(node.attributes!["name"]!, device: device!, label: node.attributes!["label"], group: node.attributes!["group"], state: state, read: perm.read, write: perm.write, timeout: timeout, timestamp: timestamp, message: node.attributes!["message"])
                device!.define(propertyVector: blobVector)
                delegate?.propertyVectorDefined(self, device: device!, propertyVector: blobVector)
                self.interpretBLOBPropertyDefinitions(from: node, toIncludeIn: blobVector)
            }
        }
    }
    
    /**
     * Interpret all child text property member definitions of a text property vector.
     * - Parameter parent: The parent (property vector) node.
     * - Parameter vector: The property vector to which the properties are a member.
     */
    private func interpretTextPropertyDefinitions(from parent: INDINode, toIncludeIn vector: INDITextPropertyVector) {
        for propertyNode in parent.childNodes! {
            if propertyNode.name != nil && propertyNode.name! == "defText" {
                let property = INDITextProperty(propertyNode.attributes!["name"]!, label: propertyNode.attributes!["label"], inPropertyVector: vector)
                property.textValue = propertyNode.text
                delegate?.propertyDefined(self, device: vector.device, propertyVector: vector, property: property)
            }
        }
    }
    
    private func interpretTextPropertyChanges(from parent: INDINode, inPropertyVector vector: INDITextPropertyVector) {
        for propertyNode in parent.childNodes! {
            if propertyNode.name != nil && propertyNode.name! == "oneText" {
                let propertyName = propertyNode.attributes!["name"]!
                var property = vector.property(name: propertyName)
                if property != nil {
                    let valueString = propertyNode.text
                    if valueString != nil {
                        property!.value = valueString!
                    } else {
                        // TODO Error with no value
                    }
                } else {
                    // TODO Error Unkown property
                }
            }
        }
    }
    
    /**
     * Interpret all child number property member definitions of a number property vector.
     * - Parameter parent: The parent (property vector) node.
     * - Parameter vector: The property vector to which the properties are a member.
     */
    private func interpretNumberPropertyDefinitions(from parent: INDINode, toIncludeIn vector: INDINumberPropertyVector) {
        for propertyNode in parent.childNodes! {
            if propertyNode.name != nil && propertyNode.name! == "defNumber" {
                let minimum = Double(propertyNode.attributes!["min"]!)
                let maximum = Double(propertyNode.attributes!["max"]!)
                let stepsize = Double(propertyNode.attributes!["step"]!)
                if minimum != nil && maximum != nil && stepsize != nil {
                    let property = INDINumberProperty(propertyNode.attributes!["name"]!, label: propertyNode.attributes!["label"], format: propertyNode.attributes!["format"]!, minimumValue: minimum!, maximumValue: maximum!, stepSize: stepsize!, inPropertyVector: vector)
                    let valueText = propertyNode.text
                    if valueText != nil {
                        let value = Double(valueText!)
                        property.numberValue = value
                    }
                    delegate?.propertyDefined(self, device: vector.device, propertyVector: vector, property: property)
                }
            }
        }
    }
    
    private func interpretNumberPropertyChanges(from parent: INDINode, inPropertyVector vector: INDINumberPropertyVector) {
        for propertyNode in parent.childNodes! {
            if propertyNode.name != nil && propertyNode.name! == "oneNumber" {
                let propertyName = propertyNode.attributes!["name"]!
                var property = vector.property(name: propertyName)
                if property != nil {
                    let valueString = propertyNode.text
                    if valueString != nil {
                        let value = Double(valueString!)
                        if value != nil {
                            property!.value = value
                        } else {
                            // TODO Error with non-valid value
                        }
                    } else {
                        // TODO Error with no value
                    }
                } else {
                    // TODO Error Unkown property
                }
            }
        }
    }
    
    /**
     * Interpret all child switch property member definitions of a switch property vector.
     * - Parameter parent: The parent (property vector) node.
     * - Parameter vector: The property vector to which the properties are a member.
     */
    private func interpretSwitchPropertyDefinitions(from parent: INDINode, toIncludeIn vector: INDISwitchPropertyVector) {
        for propertyNode in parent.childNodes! {
            if propertyNode.name != nil && propertyNode.name! == "defSwitch" {
                let property = INDISwitchProperty(propertyNode.attributes!["name"]!, label: propertyNode.attributes!["label"], inPropertyVector: vector)
                property.switchValue = propertyNode.text
                delegate?.propertyDefined(self, device: vector.device, propertyVector: vector, property: property)
            }
        }
    }
    
    private func interpretSwitchPropertyChanges(from parent: INDINode, inPropertyVector vector: INDISwitchPropertyVector) {
        for propertyNode in parent.childNodes! {
            if propertyNode.name != nil && propertyNode.name! == "oneSwitch" {
                let propertyName = propertyNode.attributes!["name"]!
                var property = vector.property(name: propertyName)
                if property != nil {
                    let valueString = propertyNode.text
                    if valueString != nil {
                        property!.value = valueString!
                    } else {
                        // TODO Error with no value
                    }
                } else {
                    // TODO Error Unkown property
                }
            }
        }
    }
    
    /**
     * Interpret all child light property member definitions of a light property vector.
     * - Parameter parent: The parent (property vector) node.
     * - Parameter vector: The property vector to which the properties are a member.
     */
    private func interpretLightPropertyDefinitions(from parent: INDINode, toIncludeIn vector: INDILightPropertyVector) {
        for propertyNode in parent.childNodes! {
            if propertyNode.name != nil && propertyNode.name! == "defLight" {
                let property = INDILightProperty(propertyNode.attributes!["name"]!, label: propertyNode.attributes!["label"], inPropertyVector: vector)
                switch propertyNode.text?.lowercased() {
                case "idle":
                    property.lightValue = .idle
                case "ok":
                    property.lightValue = .ok
                case "busy":
                    property.lightValue = .busy
                case "alert":
                    property.lightValue = .alert
                default:
                    property.lightValue = nil
                }
                delegate?.propertyDefined(self, device: vector.device, propertyVector: vector, property: property)
            }
        }
    }
    
    /**
     * Interpret all child BLOB property member definitions of a BLOB property vector.
     * - Parameter parent: The parent (property vector) node.
     * - Parameter vector: The property vector to which the properties are a member.
     */
    private func interpretBLOBPropertyDefinitions(from parent: INDINode, toIncludeIn vector: INDIBLOBPropertyVector) {
        for propertyNode in parent.childNodes! {
            if propertyNode.name != nil && propertyNode.name! == "defBLOB" {
                let property = INDIBLOBProperty(propertyNode.attributes!["name"]!, label: propertyNode.attributes!["label"], inPropertyVector: vector)
                delegate?.propertyDefined(self, device: vector.device, propertyVector: vector, property: property)
            }
        }
    }
}


// MARK: - XML parsing


/**
 * Defines the different node types in our DOM model.
 */
fileprivate enum NodeType {
    
    /**
     * An element node with possible attributes and sub-nodes.
     */
    case elementNode
    
    /**
     * A text node containing a string.
     */
    case textNode
    
    /**
     * A CData node containing binary data.
     */
    case CDATANode
}

/**
 * The SAX parser delegate that recieves the SAX events and creates a DOM mode.
 */
fileprivate class INDIXMLParserDelegate : NSObject, XMLParserDelegate {
    
    /**
     * The root element.
     */
    var element : INDINode? = nil
    
    /**
     * The current element being processed.
     */
    var currentElement : INDINode? = nil
    
    /**
     * Called when a new element is started in the XML SAX stream.
     *  - Parameter parser: The XML SAX parser.
     *  - Parameter elementName: The name of the element.
     *  - Parameter namespaceURI: The URI of the namespace.
     *  - Parameter qName: The qualified name of the element.
     *  - Parameter attributeDict: The attributes in a dictionary containing the name as the key, and the value as the value.
     */
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        currentElement = INDINode(elementName: elementName, attributes: attributeDict, parentElement: currentElement)
        if currentElement?.parentElement == nil {
            element = currentElement
        }
    }

    /**
     * Called when an element is done in the XML SAX stream.
     *  - Parameter parser: The XML SAX parser.
     *  - Parameter elementName: The name of the element.
     *  - Parameter namespaceURI: The URI of the namespace.
     *  - Parameter qName: The qualified name of the element.
     */
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        currentElement = currentElement?.parentElement
    }
    
    /**
     * Called when a parser error occurred.
     *  - Parameter parser: The XML SAX parser.
     *  - Parameter parseError: The error.
     */
    func parser(_ parser: XMLParser, parseErrorOccurred parseError: Error) {
        print("XML Parse Error:  \(parseError)")
    }
    
    /**
     * Called when a validation error occurred.
     *  - Parameter parser: The XML SAX parser.
     *  - Parameter validationError: The error.
     */
    func parser(_ parser: XMLParser, validationErrorOccurred validationError: Error) {
        print("XML Validation Error:  \(validationError)")
    }
    
    /**
     * Called when characters are found in the XML SAX stream.
     *  - Parameter parser: The XML SAX parser.
     *  - Parameter string: The characters.
     */
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        let _ = INDINode(text: string, parentElement: currentElement)
    }
    
    /**
     * Called when data are found in the XML SAX stream.
     *  - Parameter parser: The XML SAX parser.
     *  - Parameter CDATABlock: The binary data.
     */
    func parser(_ parser: XMLParser, foundCDATA CDATABlock: Data) {
        print("Found CDATA:  \(CDATABlock)")
        let _ = INDINode(cdata: CDATABlock, parentElement: currentElement)
    }
}

/**
 * Represents an XML node (DOM).
 */
fileprivate class INDINode : CustomStringConvertible {
    
    /**
     * The name of the element, or `nil` if the node is a text or data node.
     */
    var name: String? = nil
    
    /**
     * The type of the node.
     */
    let nodeType : NodeType
    
    /**
     * The text in a text node, or `nil` if the node is not a text node.
     */
    var nodeText: String? = nil
    
    /**
     * The text of all child nodes concatenated.
     */
    var text: String? {
        get {
            if nodeType == .textNode {
                return nodeText
            }
            if childNodes != nil {
                var string = ""
                for child in childNodes! {
                    if child.text != nil {
                        string += child.text!
                    }
                }
                if string.count > 0 {
                    return string
                }
            }
            return nil
        }
    }
    
    /**
     * The data in a data node, or `nil` if the node is not a data node.
     */
    var cdata: Data? = nil
    
    /**
     * The attributes of the element node, or `nil` if the node is not an element node.
     */
    var attributes: [String: String]? = nil
    
    /**
     * The child nodes of the element in the order they occurred in the SAX stream.
     * These nodes can be other element nodes or text or data nodes.
     */
    var childNodes: [INDINode]? = nil
    
    /**
     * The parent element node of the current node.
     */
    var parentElement: INDINode? = nil
    
    /**
     * Creates a new element node with the specified name and attributes as a child element of the specified parent element.
     * - Parameter elementName: The name of the element.
     * - Parameter attributes: The attributes of the element node.
     * - Parameter parentElement: The parent element.
     */
    init(elementName: String, attributes: [String: String], parentElement: INDINode?) {
        self.name = elementName
        self.attributes = attributes
        self.nodeType = .elementNode
        self.childNodes = [INDINode]()
        self.parentElement = parentElement
        self.parentElement?.childNodes?.append(self)
    }
    
    /**
     * Creates a new text node as a child node of the specified parent element node.
     * - Parameter text: The text contained in the text node.
     * - Parameter parentElement: The parent element.
     */
    init(text: String, parentElement: INDINode?) {
        self.nodeText = text.trimmingCharacters(in: .whitespacesAndNewlines)
        self.nodeType = .textNode
        self.parentElement = parentElement
        self.parentElement?.childNodes?.append(self)
    }
    
    /**
     * Creates a new data node as a child node of the specified parent element node.
     * - Parameter cdata: The data contained in the date node.
     * - Parameter parentElement: The parent element.
     */
    init(cdata: Data, parentElement: INDINode?) {
        self.cdata = cdata
        self.nodeType = .CDATANode
        self.parentElement = parentElement
        self.parentElement?.childNodes?.append(self)
    }
    
    /**
     * Creates a string describing this node indented with `depth` tab characters.
     * - Parameter depth: The depth of the element from the root element determines the indentation.
     * - Returns: The description string.
     */
    private func descriptionString(depth: Int) -> String {
        var tabs : String = ""
        for _ in 0...depth {
            tabs = tabs + "\t"
        }
        var string = ""
        switch nodeType {
        case .elementNode:
            string = string + tabs + "[ELEMENT] \(name!)\n"
            for key in self.attributes!.keys {
                string = string + tabs + "\t\t\(key) = \(self.attributes![key]!)\n"
            }
        case .textNode:
            string = string + tabs + "\t[TEXT]  \(nodeText!)\n"
        case .CDATANode:
            string = string + tabs + "\t[CDATA] \n"
        }
        if self.childNodes != nil {
            for child in self.childNodes! {
                string += child.descriptionString(depth: depth + 1)
            }
        }
        return string
    }
    
    /**
     * Returns a string describing the node.
     */
    var description: String {
        return self.descriptionString(depth: 0)
    }
}

