//
//  ServerRow.swift
//  INDI Controller
//
//  Created by Don Willems on 02/05/2021.
//  Copyright © 2021 lapsedpacifist. All rights reserved.
//

import SwiftUI

struct ServerRow: View {
    
    @StateObject var server : Server
    
    @EnvironmentObject var model: INDIControllerModel
    
    var body: some View {
        VStack(alignment: .leading){
            HStack{
                Image(systemName: "server.rack")
                    .controlSize(.large)
                    .frame(width: 20.0)
                Text(server.name)
                    .font(.title3)
                Spacer()
                Image(systemName: server.connected ? "circle.fill" : "circle")
                    .controlSize(.small)
                    .foregroundColor(server.connected ? .green : .white)
            }
            Text(server.url)
                .controlSize(.mini)
                .padding(.leading, 28.0)
                .multilineTextAlignment(.leading)
        }
    }
}

/*

struct ServerRow_Previews: PreviewProvider {
    
    @State static var server = Server(name: "Test Server", url: "http://example.org" ,port: 1234)
    
    static var previews: some View {
        ServerRow(server: server)
    }
}
*/
