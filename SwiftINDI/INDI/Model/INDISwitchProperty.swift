//
//  INDISwitchProperty.swift
//  SwiftINDI
//
//  Created by Don Willems on 19/03/2020.
//  Copyright © 2020 lapsedpacifist. All rights reserved.
//

import Foundation

/**
 * The state of the switch property (`.on` or  `.off`).
 */
public enum INDISwitchState {
    
    /**
     * Specifies that the switch is ON.
     */
    case on
    
    /**
     * Specifies that the switch is OFF.
     */
    case off
}

/**
 * The switch rule defines the behavior of the possible values of a switch. It defines whether
 * only one of the possible values is allowed to be `.on`, whether exactly one the values need to
 * be `.on`, or whether any of the values can be `.on`.
 */
public enum INDISwitchRule {
    
    /**
     * Exactly one of the member properties need to have a switch state that is `.on`. All other
     * member properties need to be `.off`.
     */
    case oneOfMany
    
    /**
     * At most one of the member properties may have a switch state that is `.on`.  It is also
     * allowed that none of the member properties are `.on`.
     */
    case atMostOne
    
    /**
     * All member properties may have a switch state that is either `.on`, or  `.off`. This means
     * that any number of properties can be `.on`.
     */
    case anyOfMany
}

/**
 * Instances of this class represent an INDI switch property vector, which is a vector of
 * text properties that holds one or more switch properties.
 */
public class INDISwitchPropertyVector : INDIDefaultPropertyVector {
    
    /**
     * The switch rule used for the switch.
     */
    public let rule: INDISwitchRule
    
    /**
     * Initialises the INDI switch property vector with the supplied values. INDI properties and
     * property vectors should only be created within the SwiftINDI framework.
     *
     * - Parameter name: The name of the INDI switch property vector.
     * - Parameter device: The device for which this INDI switch property is valid.
     * - Parameter label: The name of the INDI switch property that should be used in a graphical user interface (GUI),
     * i.e. a human readable name. If this property is not defined (i.e. is `nil`), the `name`
     * of the INDI property should be used as the label.  This value is optional.
     * - Parameter group: A name for the group of properties containing
     * this INDI switch property vector. This value is optional.
     * - Parameter state: The state (idle, ok, busy, or alert) of the property.
     * - Parameter rule: The switch rule `oneOfMany`, `atMostOne`, or `anyOfMany`.
     * - Parameter read: True when the client can read the INDI switch property.
     * - Parameter write: True when the client can write to the property, i.e. change the property value.
     * - Parameter timeout: The worse-case time to affect. The default value should be `0`. If the INDI switch property is read only, this property
     * is not relevant.
     * - Parameter timestamp: The moment when the propery was valid.
     * - Parameter message: An optional comment on the property.
     */
    init(_ name: String, device: INDIDevice, label: String?, group: String?, state: INDIPropertyState, rule: INDISwitchRule, read: Bool, write: Bool, timeout: Int, timestamp: Date?, message: String?) {
        self.rule = rule
        super.init(name, of: .switchProperty, device: device, label: label, group: group, state: state, read: read, write: write, timeout: timeout, timestamp: timestamp, message: message)
    }
    
    /**
     * This function returns all the member properties that are in the specified state.
     * - Parameter state: The state in which the returned properties need to be in.
     * - Returns: The properties that are in the specified state.
     */
    public func properties(inState state: INDISwitchState) -> [INDISwitchProperty] {
        var stateProps = [INDISwitchProperty]()
        for property in self.memberProperties {
            if (property as? INDISwitchProperty) != nil {
                let switchProperty = property as! INDISwitchProperty
                if switchProperty.switchState == state {
                    stateProps.append(switchProperty)
                }
            }
        }
        return stateProps
    }
    
    /**
     * The properties that are `.on`.
     */
    public var on : [INDISwitchProperty] {
        get {
            return self.properties(inState: .on)
        }
    }
    
    /**
     * The properties that are `.off`.
     */
    public var off : [INDISwitchProperty] {
        get {
            return self.properties(inState: .off)
        }
    }
    
    /**
     * This property is `true` when the switch vector is in a valid state depending on the `rule` specified
     * during initialisation.
     */
    public var inValidState : Bool {
        get {
            let onProps = self.on
            switch rule {
            case .oneOfMany:
                return onProps.count == 1
            case .atMostOne:
                return onProps.count <= 1
            case .anyOfMany:
                return true
            }
        }
    }
}

/**
 * Instances of this class represent an INDI switch property.
 */
public class INDISwitchProperty : INDIDefaultProperty {
    
    /**
     * Initialises the INDI switch property with the supplied values. INDI properties and
     * property vectors should only be created within the SwiftINDI framework.
     *
     * - Parameter name: The name of the INDI switch property.
     * - Parameter label: The name of the INDI switch property that should be used in a graphical user interface (GUI),
     * i.e. a human readable name. If this property is not defined (i.e. is `nil`), the `name`
     * of the INDI property should be used as the label.
     * - Parameter vector: The INDI switch property vector to which this property will be added as a member.
     */
    init(_ name: String, label: String?, inPropertyVector vector: INDISwitchPropertyVector) {
        super.init(name, of: .switchProperty, label: label, inPropertyVector: vector)
    }
    
    /**
     * The current value of the switch property, or `nil` if the property's value has not been set.
     */
    public var switchValue : String? {
        get {
            return value as? String
        } set {
            value = newValue
        }
    }
    
    /**
     * The current state of the switch property, either `.on` or  `.off`.
     *
     * If the string value of the switch is neither `on` or `off`, or if the value is not defined (`nil`),
     * the computed property will have the`.off` state.
     */
    public var switchState : INDISwitchState {
        get {
            let value = switchValue
            if value == nil {
                return .off
            }
            if value!.lowercased() == "on" {
                return .on
            }
            return .off
        }
    }
}
