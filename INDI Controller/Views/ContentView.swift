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
    var server = Server(name: "Test INDI Server", url: "http://example.org", port: 0) // Temp
    @State var select: String? = "Item 1"
    
    var body: some View {
        VStack {
            NavigationView {
                List {
                    ForEach(model.servers, id: \.self) { server in
                        ServerRow(server: server)
                        ForEach(server.devices, id: \.self) { device in
                            let deviceObject = model.device(id: device)!
                            NavigationLink(destination: GroupView(device: device)) {
                                DeviceRow(device: deviceObject)
                            }
                        }
                    }
                }
                .listStyle(SidebarListStyle())
            }
            .toolbar(content: {
                ToolbarItem(placement: ToolbarItemPlacement.automatic) {
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
                ToolbarItem(placement: .automatic) {
                    Spacer()
                }
                ToolbarItem(placement: .automatic) {
                    ParkToolbarItem()
                }
            })
            .navigationTitle("INDI Controller")
            .navigationSubtitle(model.connectedServers.count == 0 ? "No connected servers" : "\(model.connectedServers.count) connected servers")
            .navigationViewStyle(DoubleColumnNavigationViewStyle())
        }
    }
    
    private func addServer() {
        showingAddServerSheet = true
    }
}

struct GroupView: View {
    
    @State var device : String
    @EnvironmentObject var model: INDIControllerModel
    @State var select: String? = "Item 1"

    var body: some View {
        NavigationView {
            List {
                let deviceObject = model.device(id: device)!
                ForEach(deviceObject.groups, id: \.self) { group in
                    let groupObject = model.group(id: group)!
                    NavigationLink(destination: GroupDetail(device: deviceObject, group: groupObject), tag: group, selection: $select)
                    {
                        GroupRow(group: groupObject)
                    }
                }
            }
        }
    }
}

/*
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
 */
