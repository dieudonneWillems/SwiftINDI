//
//  ContentView.swift
//  INDI Controller
//
//  Created by Don Willems on 30/04/2021.
//  Copyright © 2021 lapsedpacifist. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    
    @State private var showingAddServerSheet = false

    @EnvironmentObject var model: INDIControllerModel
    
    var body: some View {
        NavigationView {
            List() {
                ForEach(model.servers, id: \.self) { server in
                    NavigationLink(destination: ServerDetail(server: server)) {
                        ServerRow(server: server)
                    }
                    ForEach(server.devices, id: \.self) { device in
                        NavigationLink(destination: DeviceDetail(device: device)) {
                            DeviceRow(device: device)
                        }
                    }
                }
            }
            .listStyle(SidebarListStyle())
            .toolbar {
                ToolbarItem() {
                    Spacer()
                }
                ToolbarItem(placement: .automatic) {
                    Button(action: {
                        showingAddServerSheet.toggle()
                    }) {
                        Image(systemName: "plus")
                    }
                    .sheet(isPresented: $showingAddServerSheet) {
                        AddServerSheet(isPresented: $showingAddServerSheet)
                    }
                    .help("Add INDI Server")
                }
            }
            VStack {
                Text("Selected devices")
            }
        }
    }
    
    private func addServer() {
        showingAddServerSheet = true
    }
}

/*
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
 */
