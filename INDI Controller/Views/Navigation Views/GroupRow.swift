//
//  GroupRow.swift
//  INDI Controller
//
//  Created by Don Willems on 06/05/2021.
//  Copyright © 2021 lapsedpacifist. All rights reserved.
//

import SwiftUI

struct GroupRow: View {
    
    @StateObject var group : Group
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text(group.name)
            }
            HStack {
                Image(systemName: "circle.fill")
                    .foregroundColor(.blue)
                    .font(.footnote)
                Text("3 minutes ago")
                    .font(.footnote)
            }
        }
    }
}

/*
struct GroupRow_Previews: PreviewProvider {
    static var previews: some View {
        GroupRow()
    }
}
*/
