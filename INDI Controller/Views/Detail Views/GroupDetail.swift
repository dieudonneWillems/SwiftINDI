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
    @EnvironmentObject var model: INDIControllerModel
    
    var body: some View {
        VStack {
            ForEach(group.propertyVectors, id: \.self) { propertyVectorID in
                let propertyVector = model.propertyVector(id: propertyVectorID)
                model.viewForPropertyVector(propertyVector: propertyVector!)
                Text("\(propertyVector!.id)")
                    .font(.footnote)
                    .padding(.bottom)
            }
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
