//
//  BasicINDIClient.swift
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
public class BasicINDIClient : CustomStringConvertible {
    
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
     * The server adress (host) to which the client can be connected.
     *
     * This value can be `nil` when the server has not been specified yet. To specify
     * the server and the port to be used, use the function
     * `setSetver(at host: String, port: Int = 7642)`.
     */
    public private(set) var server : String?
    
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
     * A list of devices (INDI drivers) loaded by the INDI server.
     */
    public private(set) var devices = [String : INDIDevice]()
    
    /**
     * Returns a string representation describing the client.
     */
    public var description: String {
        get {
            if connected {
                return "INDI Client connected to INDI Server at \(server!) with port \(port)"
            } else if server != nil {
                return "INDI Client disconnected from INDI Server at \(server!) with port \(port)"
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
        self.server = host
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
            delegate?.connectionRequestIgnored(self, to: server, port: port, message: "The INDI client was already connected to the INDI server.")
            return
        }
        if server == nil {
            let message = "No INDI server was defined, no connection could be made therefore."
            let error = INDIError.connectionError(message: message)
            self.delegate?.encounteredINDIError(self, error: error, message: message)
        }
        delegate?.willConnect(self, to: server!, port: port)
        self.tcpClient = TCPClient(address: self.server!, port: Int32(port))
        DispatchQueue.global(qos: .utility).async { // Start new utility thread
            switch self.tcpClient!.connect(timeout: 1) {
                case .success:
                    self.connected = true
                    DispatchQueue.main.async {
                        self.delegate?.didConnect(self, to: self.server!, port: self.port)
                        self.listen()
                        self.loadDevices()
                    }
                case .failure(let error):
                    DispatchQueue.main.async {
                        let message = "No connection to the INDI server at \(self.server!) and port \(self.port) could be established."
                        let error = INDIError.connectionError(message: message, causedBy: error)
                        self.delegate?.encounteredINDIError(self, error: error, message: message)
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
            delegate?.connectionRequestIgnored(self, to: server, port: port, message: "The INDI client was not connected to the INDI server and cannot be disconnected therefore.")
            return
        }
        delegate?.willDisconnect(self, from: server!, port: port)
        tcpClient?.close()
        tcpClient = nil
        self.connected = false
        delegate?.didDisconnect(self, from: server!, port: port)
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
            print("Started listening")
            var current = "" // Current element to be parsed where characters are added to the stream
            var nodeDepth = 0 // The depth of the element. Elements are returned (current) when the element at depth 0 is closed.
            var lastc = "" // The previous character added.
            var nodeBeingClosed = false // Is true when the element is being closed, "</" was encountered.
            while self.connected {
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
                        print("response=\n\(response)")
                        if response.count > 3 {
                            current = ""
                            lastc = ""
                            nodeBeingClosed = false
                            self.parseResponseAndCreateEvents(response: response)
                        }
                    }
                }
            }
            print("Stopped listening")
        }
    }
    
    // MARK: - Parsing XML responses from the INDI server
    
    /**
     * Parses a (part of) a response from the INDI server XML in the main thread.
     * - Parameter response: The response string.
     */
    private func parseResponseAndCreateEvents(response: String) {
        DispatchQueue.main.async {
            do {
                print("\n\n-----------------------------------------------------")
                print(response)
                print("-----------------------------------------------------")
                try self.parseResponse(response)
                self.delegate?.recievedData(self, size: response.count, xml: response, from: self.server!, port: self.port)
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
            print("\(parserDelegate.element!)")
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
                
            } else if node.name!.starts(with: "delProperty") {
                           
            } else if node.name!.starts(with: "one") {
                                      
            }
        }
    }
    
    /**
     * Interprets a property definition.
     * - Parameter node: The XML node.
     */
    private func interpretDefinition(node: INDINode) {
        let deviceName = node.attributes!["device"]
        let stateString = node.attributes!["state"]
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
        let permString = node.attributes!["perm"]
        var readFlag = false
        var writeFlag = false
        if permString != nil && permString!.contains("r") {
            readFlag = true
        }
        if permString != nil && permString!.contains("w") {
            writeFlag = true
        }
        let timeoutString = node.attributes!["timeout"]
        var timeout = 0
        if timeoutString != nil {
            let timeoutInt = Int(timeoutString!)
            if timeoutInt != nil {
                timeout = timeoutInt!
            }
        }
        let timestampString = node.attributes!["timestamp"]
        var timestamp : Date? = Date()
        if timestampString != nil {
            timestamp = BasicINDIClient.iso8601().date(from: timestampString!)
        }
        if deviceName != nil {
            var device = self.devices[deviceName!]
            if device == nil {
                device = INDIDevice(name: deviceName!)
                self.devices[deviceName!] = device
                delegate?.deviceDefined(self, device: device!)
            }
            if node.name! == "defTextVector" {
                let textVector = INDITextPropertyVector(node.attributes!["name"]!, device: device!, label: node.attributes!["label"], group: node.attributes!["group"], state: state, read: readFlag, write: writeFlag, timeout: timeout, timestamp: timestamp, message: node.attributes!["message"])
                // TODO: Parse text properties (child elements)
                device!.define(propertyVector: textVector)
                delegate?.propertyVectorDefined(self, device: device!, propertyVector: textVector)
            }
            // TODO: Parse other vector types and their members.
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
        print("Start Element:  \(elementName)")
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
        print("End Element:  \(elementName)")
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
        print("Found Characters:  \(string)")
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
    var text: String? = nil
    
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
        self.text = text.trimmingCharacters(in: .whitespacesAndNewlines)
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
            string = string + tabs + "\t[TEXT]  \(text!)\n"
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

