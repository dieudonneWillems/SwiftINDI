//
//  ConnectToolbarItem.swift
//  INDI Controller
//
//  Created by Don Willems on 02/05/2021.
//  Copyright © 2021 lapsedpacifist. All rights reserved.
//

import SwiftUI

struct ConnectToolbarItem: View {
    
  //  @EnvironmentObject var selection : SelectedObjects
    @ObservedObject var server : Server
    
    @EnvironmentObject var model: INDIControllerModel
    
    var body: some View {
        Button(action: {
            if !server.connected {
                model.connect(server: server)
            } else {
                model.disconnect(server: server)
            }
        }) {
            HStack{
                Image(systemName: server.connected ? "bolt.slash.fill" : "bolt.circle")
                Text(server.connected ? "Disconnect" : "Connect")
            }
        }
        .help(server.connected ? "Disconnect from server" : "Connect to server")
    }
}

/*

struct ConnectToolbarItem_Previews: PreviewProvider {
    
    @State static var selection = SelectableRowObject?.none
    
    static var previews: some View {
        ConnectToolbarItem(selection: $selection)
    }
}
*/
