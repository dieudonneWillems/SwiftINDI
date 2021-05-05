//
//  AppDelegate.swift
//  INDI Client
//
//  Created by Don Willems on 20/03/2020.
//  Copyright © 2020 lapsedpacifist. All rights reserved.
//

import Cocoa
import SwiftINDI
import SwiftINDIGUI

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet weak var window: NSWindow!
    
    @IBOutlet weak var clientController : INDIClientController!

    var serverController : INDIServerController? = nil

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        clientController.addINDIServer(at: "astroberry.local", port: 7624, with: "Revisionist")
        serverController = INDIServerController.instance
        clientController.serverController = serverController
        let newView = serverController!.view
        let view = window.contentView!
        view.addSubview(newView)
        newView.translatesAutoresizingMaskIntoConstraints = false
        let leadingConstraint = NSLayoutConstraint(item: newView, attribute: NSLayoutConstraint.Attribute.leading, relatedBy: NSLayoutConstraint.Relation.equal, toItem: view, attribute: NSLayoutConstraint.Attribute.leading, multiplier: 1, constant: 0)
        let trailingConstraint = NSLayoutConstraint(item: newView, attribute: NSLayoutConstraint.Attribute.trailing, relatedBy: NSLayoutConstraint.Relation.equal, toItem: view, attribute: NSLayoutConstraint.Attribute.trailing, multiplier: 1, constant: 0)
        let topConstraint = NSLayoutConstraint(item: newView, attribute: NSLayoutConstraint.Attribute.top, relatedBy: NSLayoutConstraint.Relation.equal, toItem: view, attribute: NSLayoutConstraint.Attribute.top, multiplier: 1, constant: 0)
        let bottomConstraint = NSLayoutConstraint(item: newView, attribute: NSLayoutConstraint.Attribute.bottom, relatedBy: NSLayoutConstraint.Relation.equal, toItem: view, attribute: NSLayoutConstraint.Attribute.bottom, multiplier: 1, constant: 0)
        view.addConstraints([leadingConstraint, trailingConstraint, topConstraint, bottomConstraint])
        
        //propertyListController?.client = clientController.clients[0]
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        clientController.disconnectAllClients()
    }


}

