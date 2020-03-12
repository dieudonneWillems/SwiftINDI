//
//  BasicClient.swift
//  SwiftINDI
//
//  Created by Don Willems on 12/03/2020.
//  Copyright © 2020 Don Willems. All rights reserved.
//

import Foundation

public class BasicClient {
    
    public let host: String
    public let port: Int
    
    private var inputStream: InputStream!
    private var outputStream: OutputStream!
    
    public init(host: String, port: Int = 7624) {
        self.host = host
        self.port = port
    }
    
    public func connect() {
        openSocket()
    }
    
    private func openSocket() {
        var readStream: Unmanaged<CFReadStream>?
        var writeStream: Unmanaged<CFWriteStream>?
        CFStreamCreatePairWithSocketToHost(kCFAllocatorDefault, self.host as CFString, UInt32(self.port), &readStream, &writeStream)
        inputStream = readStream!.takeRetainedValue()
        outputStream = writeStream!.takeRetainedValue()
        inputStream.schedule(in: .current, forMode: .common)
        outputStream.schedule(in: .current, forMode: .common)
        inputStream.open()
        outputStream.open()
    }
}
