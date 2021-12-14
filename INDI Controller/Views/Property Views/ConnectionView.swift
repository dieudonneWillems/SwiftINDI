//
//  ConnectionView.swift
//  INDI Controller
//
//  Created by Don Willems on 06/05/2021.
//  Copyright © 2021 lapsedpacifist. All rights reserved.
//

import SwiftUI

struct ConnectionView: View {
    
    @StateObject var propertyVector : ConnectionPropertyVector
    
    var body: some View {
        HStack {
            Image(systemName: "bolt.fill")
            Toggle("\(propertyVector.label)", isOn: $propertyVector.connected)
                .toggleStyle(.switch)
                .font(.headline)
        }
    }
}

/*
struct ConnectionView_Previews: PreviewProvider {
    static var previews: some View {
        ConnectionView()
    }
}
 */
