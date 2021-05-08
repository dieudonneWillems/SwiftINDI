//
//  GroupDetail.swift
//  INDI Controller
//
//  Created by Don Willems on 06/05/2021.
//  Copyright © 2021 lapsedpacifist. All rights reserved.
//

import SwiftUI

struct GroupDetail: View {
    
    @StateObject var device : Device
    @StateObject var group : Group
    
    var body: some View {
        VStack {
            Text("Hello, \(group.name)!")
        }
        .toolbar(content: {
            ToolbarItem(placement: .automatic) {
                Spacer()
            }
            ToolbarItem(placement: .automatic) {
                ParkToolbarItem()
            }
        })
    }
}

/*
struct GroupDetail_Previews: PreviewProvider {
    static var previews: some View {
        GroupDetail()
    }
}
*/
