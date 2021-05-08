//
//  TitleToolbarItem.swift
//  INDI Controller
//
//  Created by Don Willems on 08/05/2021.
//  Copyright © 2021 lapsedpacifist. All rights reserved.
//

import SwiftUI

struct TitleToolbarItem: View {
    
    @State var title = "INDI Controller"
    @State var subtitle = "No Connected Servers"
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(title).font(.title3).bold()
            Text(subtitle).font(.subheadline).foregroundColor(.secondary)
        }
        .padding(.leading, 0)
        .padding(.trailing, 10)
    }
}

struct TitleToolbarItem_Previews: PreviewProvider {
    static var previews: some View {
        TitleToolbarItem()
    }
}
