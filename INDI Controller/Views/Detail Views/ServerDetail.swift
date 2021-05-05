//
//  ServerDetail.swift
//  INDI Controller
//
//  Created by Don Willems on 02/05/2021.
//  Copyright © 2021 lapsedpacifist. All rights reserved.
//

import SwiftUI

struct ServerDetail: View {
    
    @StateObject var server : Server
    
    @EnvironmentObject var model: INDIControllerModel
    
    var body: some View {
        Text("Hello, \(server.name)!")
            .toolbar(content: {
                ToolbarItem(placement: .automatic) {
                    ConnectToolbarItem(server:server)
                }
                ToolbarItem() {
                    Spacer()
                }
            })
    }
}

/*

struct ServerDetail_Previews: PreviewProvider {
    
    @State private static var server : SelectableRowObject? = INDIServerObject(name: "Test INDI Server", at: URL(string: "http://example.org")!)
    
    static var previews: some View {
        ServerDetail(server: $server)
    }
}
*/
