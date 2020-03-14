//
//  INDIDelegate.swift
//  SwiftINDI
//
//  Created by Don Willems on 14/03/2020.
//  Copyright © 2020 lapsedpacifist. All rights reserved.
//

import Foundation

public protocol INDIDelegate {
    
    func willConnect(_: BasicINDIClient, to server: String, port: Int)
    func didConnect(_: BasicINDIClient, to server: String, port: Int)
    
    func willDisconnect(_: BasicINDIClient, from server: String, port: Int)
    func didDisconnect(_: BasicINDIClient, from server: String, port: Int)
    
}
