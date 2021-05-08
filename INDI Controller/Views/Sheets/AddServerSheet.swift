//
//  AddServerSheet.swift
//  INDI Controller
//
//  Created by Don Willems on 02/05/2021.
//  Copyright © 2021 lapsedpacifist. All rights reserved.
//

import SwiftUI

struct AddServerSheet: View {
    
    @State var name: String = "Astroberry"
    @State var url: String = "astroberry.local"
    @State var port: Int = 7624
    @State var autoConnect: Bool = true
    
    @Binding var isPresented: Bool
    
    @EnvironmentObject var model: INDIControllerModel
    
    let formatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .none
        return formatter
    }()
    
    var body: some View {
        VStack() {
            Image(nsImage: NSImage(named: "AppIcon") ?? NSImage())
                .scaleEffect(0.6)
                .frame(width: 100, height: 100, alignment: .center)
            Text("Provide the Name, Host and Port number for the INDI server.")
                .font(.title3)
                .frame(width: 250, height: 50, alignment: .center)
                .padding(.bottom, 10)
                .multilineTextAlignment(.center)
            HStack {
                Text("Name:")
                    .frame(width: 50, height: nil, alignment: .trailing)
                TextField("Name", text: $name)
            }
            HStack {
                Text("Host:")
                    .frame(width: 50, height: nil, alignment: .trailing)
                TextField("URL", text: $url)
                Text(":")
                    .frame(width: 5, height: nil, alignment: .center)
                TextField("", value: $port, formatter: formatter)
                    .frame(width: 40, height: nil, alignment: .leading)
            }
            HStack {
                Text("")
                    .frame(width: 50, height: nil, alignment: .trailing)
                    .frame(width: 50, height: nil)
                Toggle("Automatically Connect all Devices", isOn: $autoConnect)
                    .help("Automatically connect all devices connected to the server when a connection is established with the server.")
                    .frame(maxWidth: .infinity, minHeight: 40.0, alignment: .leading)
                    .multilineTextAlignment(.leading)
            }
            .frame(maxWidth: .infinity ,alignment: .leading)
            HStack {
                Button("Cancel",action: {
                    isPresented.toggle()
                })
                .frame(minWidth: 0, maxWidth: .infinity)
                .padding()
                .keyboardShortcut(.cancelAction)
                Button("OK", action: {
                    isPresented.toggle()
                    let newServer = Server(name: name, url: url, port: port, autoConnect: autoConnect)
                    do {
                        try model.add(server: newServer)
                    } catch {
                        print("Could not add server.")
                    }
                })
                .frame(minWidth: 0, maxWidth: .infinity)
                .padding()
                .keyboardShortcut(.defaultAction)
            }
            .frame(maxWidth: .infinity)
            .padding(.top, 20)
        }
        .padding()
        .frame(minWidth: 300, maxWidth: 300)
    }
}

struct AddServerSheet_Previews: PreviewProvider {
    
    @State private static var showingAddServerSheet = true
    
    static var previews: some View {
        AddServerSheet(isPresented: $showingAddServerSheet)
    }
}
   
