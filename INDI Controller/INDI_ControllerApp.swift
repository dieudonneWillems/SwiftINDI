//
//  INDI_ControllerApp.swift
//  INDI Controller
//
//  Created by Don Willems on 30/04/2021.
//  Copyright © 2021 lapsedpacifist. All rights reserved.
//

import SwiftUI

@main
struct INDI_ControllerApp: App {
    
    @StateObject public var model = INDIControllerModel()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(model)
        }
        .windowStyle(HiddenTitleBarWindowStyle())
        .commands {
            SidebarCommands()
        }
    }
}
