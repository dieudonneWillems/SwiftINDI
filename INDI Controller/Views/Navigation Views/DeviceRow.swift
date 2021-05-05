//
//  DeviceRow.swift
//  INDI Controller
//
//  Created by Don Willems on 03/05/2021.
//  Copyright © 2021 lapsedpacifist. All rights reserved.
//

import SwiftUI

struct DeviceRow: View {
    
    @State var device: Device
    
    @EnvironmentObject var model: INDIControllerModel
    
    var body: some View {
        VStack(alignment: .leading){
            HStack{
                Spacer()
                    .frame(width: 20.0)
                Image(systemName: "sparkles.rectangle.stack")
                    .font(.body)
                    .frame(width: 20.0)
                Text(device.name)
                    .font(.body)
            }
        }
    }
}

/*

struct DeviceRow_Previews: PreviewProvider {
    static var previews: some View {
        DeviceRow()
    }
}
*/
