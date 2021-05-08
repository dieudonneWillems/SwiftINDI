//
//  ParkToolbarItem.swift
//  INDI Controller
//
//  Created by Don Willems on 08/05/2021.
//  Copyright © 2021 lapsedpacifist. All rights reserved.
//

import SwiftUI

struct ParkToolbarItem: View {
    var body: some View {
        Button(action: {
            // TODO Park or unpark telescope
        }) {
            Image(systemName: "p.square")
        }
        .help("Park the telescope in its parking position.")
    }
}

struct ParkToolbarItem_Previews: PreviewProvider {
    static var previews: some View {
        ParkToolbarItem()
    }
}
