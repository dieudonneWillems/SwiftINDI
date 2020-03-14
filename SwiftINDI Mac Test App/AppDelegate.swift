//
//  AppDelegate.swift
//  SwiftINDI Mac Test App
//
//  Created by Don Willems on 14/03/2020.
//  Copyright © 2020 lapsedpacifist. All rights reserved.
//

import Cocoa
import SwiftUI
import SwiftINDI

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate, INDIDelegate {
    
    var window: NSWindow!
    var clients = [BasicINDIClient]()


    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Create the SwiftUI view that provides the window contents.
        let contentView = ContentView()

        // Create the window and set the content view. 
        window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 480, height: 300),
            styleMask: [.titled, .closable, .miniaturizable, .resizable, .fullSizeContentView],
            backing: .buffered, defer: false)
        window.center()
        window.setFrameAutosaveName("Main Window")
        window.contentView = NSHostingView(rootView: contentView)
        window.makeKeyAndOrderFront(nil)
        
        self.addINDIServer(at: "localhost", port: 7624)
    }
    
    func addINDIServer(at host: String, port: Int) {
        let indiClient = BasicINDIClient(delegate: self)
        do {
            try indiClient.setServer(at: host, port: port)
            clients.append(indiClient)
            try indiClient.connect()
        } catch {
            print(error)
        }
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        for client in clients {
            client.disconnect()
        }
    }

    // MARK: - INDI Delegate
    
    
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
}

