//
//  AppDelegate.swift
//  INDI Client
//
//  Created by Don Willems on 20/03/2020.
//  Copyright © 2020 lapsedpacifist. All rights reserved.
//

import Cocoa
import SwiftINDI

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet weak var window: NSWindow!
    
    @IBOutlet weak var clientController : INDIClientController!


    func applicationDidFinishLaunching(_ aNotification: Notification) {
        clientController.addINDIServer(at: "revisionist.local", port: 7624)
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        clientController.disconnectAllClients()
    }


}

