//
//  SelectableRowObject.swift
//  INDIUIModel
//
//  Created by Don Willems on 02/05/2021.
//  Copyright © 2021 lapsedpacifist. All rights reserved.
//

import Foundation

open class SelectableObject: Hashable, ObservableObject {
    
    private let id: UUID = UUID()
    
    public init() {
        
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    public static func == (lhs: SelectableObject, rhs: SelectableObject) -> Bool {
        return lhs.id == rhs.id
    }
}
