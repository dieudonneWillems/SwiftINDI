//
//  DeviceDetail.swift
//  INDI Controller
//
//  Created by Don Willems on 05/05/2021.
//  Copyright © 2021 lapsedpacifist. All rights reserved.
//

import SwiftUI

struct DeviceDetail: View {
    
    @StateObject var device : Device
    
    @EnvironmentObject var model: INDIControllerModel
    
    var body: some View {
        NavigationView {
            List() {
                ForEach(device.groups, id: \.self) { group in
                    let groupObject = model.group(id: group)!
                    NavigationLink(destination: GroupDetail(device: device, group: groupObject)) {
                        GroupRow(group: groupObject)
                    }
                }
            }
        }
    }
}
/*
struct DeviceDetail_Previews: PreviewProvider {
    static var previews: some View {
        DeviceDetail()
    }
}
 */
