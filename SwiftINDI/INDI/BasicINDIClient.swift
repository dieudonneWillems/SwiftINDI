//
//  BasicINDIClient.swift
//  SwiftINDI
//
//  Created by Don Willems on 10/03/2020.
//  Copyright © 2020 lapsedpacifist. All rights reserved.
//

import Foundation
import SwiftSocket
import SwiftyXMLParser

/**
 * This class represents the basic INDI client providing low level (INDI) communication with an INDI server instance.
 *
 * Before connecting a client to a server, the server needs first to be specified using the function `setSetver(at host: String, port: Int = 7642)`.
 * The client can then establish a TCP connection using the function `connect()`. To disconnect use the function `disconnect()`.
 */
public class BasicINDIClient : CustomStringConvertible {
    
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
     * `setSetver(at host: String, port: Int = 7642)`.
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
     * `setSetver(at host: String, port: Int = 7642)` to specify the server and port.
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
     * `setSetver(at host: String, port: Int = 7642)`.
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
                        self.getDevices()
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
     * Requests the list of devices from the INDI server. When devices are found,
     * events will be forwarded to the delegate.
     */
    private func getDevices() {
        if !connected || tcpClient == nil {
            let message = "The INDI server is not connected."
            let error = INDIError.connectionError(message: message)
            self.delegate?.encounteredINDIError(self, error: error, message: message)
        }
        send(message: "<getProperties version=\"1.7\"/>")
        return
    }
    
    private func send(message: String) {
        switch tcpClient!.send(string: message) {
            case .success:
                sleep(1)
                /*
                guard let data = tcpClient!.read(1024*10) else {
                    print("Did not recieve data")
                    let message = "No data was recieved from the INDI server."
                    let error = INDIError.connectionError(message: message)
                    self.delegate?.encounteredINDIError(self, error: error, message: message)
                    return
                }
                print("received data")
                if let response = String(bytes: data, encoding: .utf8) {
                  print("******** RESPONSE ********\n\(response)")
                } */
            case .failure(let error):
                let message = "An error occurred when data was send to the INDI server."
                let indierror = INDIError.connectionError(message: message, causedBy: error)
                self.delegate?.encounteredINDIError(self, error: indierror, message: message)
        }
    }
    
    private func listen() {
        DispatchQueue.global(qos: .background).async { // Start new background thread
            print("Started listening")
            while self.connected {
                guard let d = self.tcpClient!.read(1, timeout: 1) else { continue }
                
                let c = String(bytes: d, encoding: .utf8)
                print("\(c)")
                // TODO: Create XML from characters
            }
            print("Stopped listening")
        }
    }
    
    /**
     * Parses the response into an XML DOM structure.
     *
     * - Parameter response: The response string recieved from the INDI server.
     * - Returns: The root element of the XML.
     */
    private func parseResponse(_ response : String) throws -> XML.Accessor {
        let xml = try XML.parse(response)
        return xml
    }
}
