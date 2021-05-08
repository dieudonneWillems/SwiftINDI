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
                Image(systemName: "circle.fill")
                    .foregroundColor(.blue)
                    .font(.footnote)
                    .frame(minWidth: 12, maxWidth: 12)
                Text(group.name)
                    .font(.headline)
            }
            HStack {
                Text("")
                    .font(.footnote)
                    .frame(minWidth: 12, maxWidth: 12)
                Text("3 minutes ago")
                    .font(.subheadline)
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
