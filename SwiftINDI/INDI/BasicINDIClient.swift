//
//  BasicINDIClient.swift
//  SwiftINDI
//
//  Created by Don Willems on 10/03/2020.
//  Copyright © 2020 lapsedpacifist. All rights reserved.
//

import Foundation
import SwiftSocket

public class BasicINDIClient {
    
    public private(set) var server : String?
    public private(set) var port : Int = 7624
    
    public var delegate : INDIDelegate?
    
    public private(set) var connected : Bool = false
    
    private var tcpClient : TCPClient? = nil
    
    public init() {
    }
    
    public init(delegate: INDIDelegate) {
        self.delegate = delegate
    }
    
    public func setServer(at host: String, port: Int = 7642) {
        self.server = host
        self.port = port
    }
    
    public func connect() throws {
        if connected {
            // TODO: Send message to delegate
            return
        }
        if server == nil {
            // TODO --> throw error
        }
        delegate?.willConnect(self, to: server!, port: port)
        self.tcpClient = TCPClient(address: self.server!, port: Int32(port))
        switch tcpClient!.connect(timeout: 1) {
            case .success:
                break
            case .failure(let error):
                // TODO --> throw error
                break
        }
        self.connected = true
        delegate?.didConnect(self, to: server!, port: port)
    }
    
    public func disconnect() {
        if !connected {
            // TODO: Send message to delegate
            return
        }
        tcpClient?.close()
        tcpClient = nil
        delegate?.willDisconnect(self, from: server!, port: port)
        self.connected = false
    }
    
    private func getDevices() throws -> [INDIDevice]? {
        if !connected || tcpClient == nil {
            return nil
        }
        switch tcpClient!.send(string: "<getProperties version=\"1.7\"/>" ) {
          case .success:
            sleep(1)
            guard let data = tcpClient!.read(1024*10) else {
                print("Did not recieve data")
                return [INDIDevice]()
            }
            print("received data")
            if let response = String(bytes: data, encoding: .utf8) {
              print("******** RESPONSE ********\n\(response)")
            }
          case .failure(let error):
            print(error)
        }
        return nil
    }
}
