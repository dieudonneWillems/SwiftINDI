//
//  INDIError.swift
//  SwiftINDI
//
//  Created by Don Willems on 14/03/2020.
//  Copyright © 2020 lapsedpacifist. All rights reserved.
//

import Foundation

/**
 * This enumeration encapsulates different errors that may be thrown by an INDI client.
 */
public enum INDIError : Error {
    
    /**
     * A error while connecting to the INDI server.
     *
     * - Parameter message: A human readable message explaining the error.
     * - Parameter causedBy: An optional error that caused the present error. This may
     * for instance be an TCP error.
     */
    case connectionError(message: String, causedBy: Error? = nil)
    
    /**
     * A error while parsing the XML repsonse of  the INDI server.
     *
     * - Parameter message: A human readable message explaining the error.
     * - Parameter causedBy: An optional error that caused the present error. This may
     * for instance be an XML parsing error.
     */
    case parseError(message: String, causedBy: Error? = nil)
    
    /**
     * A error thrown when the parameter set has an illegal value.
     *
     * - Parameter message: A human readable message explaining the error.
     * - Parameter causedBy: An optional error that caused the present error. 
     */
    case illegalValueError(message: String, causedBy: Error? = nil)
}
