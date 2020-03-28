//
//  INDIPropertyListViewController.swift
//  SwiftINDIGUI
//
//  Created by Don Willems on 21/03/2020.
//  Copyright © 2020 lapsedpacifist. All rights reserved.
//

import Cocoa
import SwiftINDI

public class INDIServerController: NSViewController, NSOutlineViewDataSource, NSOutlineViewDelegate {
    
    @IBOutlet weak public var propertyListView : NSOutlineView?
    @IBOutlet weak public var navigationView : NSOutlineView?
    
    public static var instance : INDIServerController? {
        get {
            let bundle = Bundle(for: INDIServerController.self)
            let nib = NSNib(nibNamed: "INDIPropertyListViewController", bundle: bundle)
            let controller = INDIServerController()
            guard (nib?.instantiate(withOwner: controller, topLevelObjects: nil))! else {
                return nil
            }
            return controller
        }
    }
    
    /**
     * The list of INDI clients (each connected to one server).
     */
    public private(set) var clients = [BasicINDIClient]()
    
    /**
     * Adds a client to the GUI.
     * - Parameter client: The client to be added.
     */
    public func addClient(_ client: BasicINDIClient) {
        clients.append(client)
        self.reload()
    }
    
    /**
     * Inserts a client into the GUI at the specified `index` in the list of INDI clients.
     * - Parameter client: The client to be inserted.
     * - Parameter index: The index in the list.
     */
    public func insertClient(_ client: BasicINDIClient, at index: Int) {
        clients.insert(client, at: index)
        self.reload()
    }
    
    /**
     * Removes a client from the GUI at the specified `index` in the list of INDI clients.
     * - Parameter index: The index in the list.
     */
    public func removeClient(at index: Int) {
        clients.remove(at: index)
        self.reload()
    }
    
    public func removeAllClients() {
        clients.removeAll()
        self.reload()
    }
    
    private var rootLevelPropertyItems = [Any]()
    
    /**
     * The device whose information is shown.
     */
    public var device : INDIDevice? {
        didSet {
            if device != nil {
                rootLevelPropertyItems.removeAll()
                for group in device!.groups {
                    rootLevelPropertyItems.append(group)
                    let propertyVectors = device!.propertyVectors(in: group)
                    for propertyVector in propertyVectors {
                        rootLevelPropertyItems.append(propertyVector)
                    }
                }
                propertyListView?.reloadData()
                propertyListView?.needsDisplay = true
            }
        }
    }
    
    public func reload() {
        navigationView?.reloadData()
        navigationView?.needsDisplay = true
        propertyListView?.reloadData()
        propertyListView?.needsDisplay = true
    }

    public override func viewDidLoad() {
        self.registerItemViews()
        super.viewDidLoad()
    }
    
    private var registeredViews = false
    
    /**
     * Load all cell views that can be used in the outline views and registers them.
     */
    func registerItemViews() {
        if !registeredViews {
            // Load nib files for table view cells used in both navigation and content outline views.
            let bundle = Bundle(for: type(of: self))
            let nibServerItem = NSNib(nibNamed: "INDIServerItemView", bundle: bundle)
            // Register view so that it can be used as a cell view.
            navigationView!.register(nibServerItem, forIdentifier: .serverItemView)
            
            let nibDeviceItem = NSNib(nibNamed: "INDIDeviceItemView", bundle: bundle)
            navigationView!.register(nibDeviceItem, forIdentifier: .deviceItemView)
            
            let nibGroupItem = NSNib(nibNamed: "INDIGroupItemView", bundle: bundle)
            propertyListView!.register(nibGroupItem, forIdentifier: .groupItemView)
            
            let nibPropertyVectorItem = NSNib(nibNamed: "INDIPropertyVectorItemView", bundle: bundle)
            propertyListView!.register(nibPropertyVectorItem, forIdentifier: .propertyVectorItemView)
            
            let nibPropertyItem = NSNib(nibNamed: "INDIPropertyItemView", bundle: bundle)
            propertyListView!.register(nibPropertyItem, forIdentifier: .propertyItemView)
            
            let nibTextPropertyItem = NSNib(nibNamed: "INDITextPropertyValueView", bundle: bundle)
            propertyListView!.register(nibTextPropertyItem, forIdentifier: .textPropertyItemView)
            
            self.registeredViews = true
        }
    }
    
    // MARK: - NSOutlineViewDataSource methods
    
    public func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any {
        if outlineView == navigationView {
            if item == nil {
                return clients[index]
            } else if (item as? BasicINDIClient) != nil {
                let client = (item as! BasicINDIClient)
                let deviceNames = client.deviceNames
                let device = client.devices[deviceNames[index]]
                if device != nil {
                    return device!
                }
            }
        } else if outlineView == propertyListView {
            if item == nil {
                return rootLevelPropertyItems[index]
            } else if (item as? INDIPropertyVector) != nil {
                return (item as! INDIPropertyVector).memberProperties[index]
            }
        }
        return ""
    }
    
    public func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool {
        if outlineView == navigationView {
            if (item as? BasicINDIClient) != nil {
                return (item as! BasicINDIClient).devices.count > 0
            }
        } else if outlineView == propertyListView {
            if (item as? String) != nil {
                return false //group
            } else if (item as? INDIPropertyVector) != nil {
                return (item as! INDIPropertyVector).memberProperties.count > 0
            }
        }
        return false
    }
    
    public func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {
        if outlineView == navigationView {
            if item == nil {
                return clients.count
            } else if (item as? BasicINDIClient) != nil {
                return (item as! BasicINDIClient).devices.count
            }
        } else if outlineView == propertyListView {
            if item == nil {
                return rootLevelPropertyItems.count
            } else if (item as? String) != nil {
                return 0 // group
            } else if (item as? INDIPropertyVector) != nil {
                return (item as! INDIPropertyVector).memberProperties.count
            }
        }
        return 0
    }
    
    public func outlineView(_ outlineView: NSOutlineView, objectValueFor tableColumn: NSTableColumn?, byItem item: Any?) -> Any? {
        if outlineView == navigationView {
            if (item as? BasicINDIClient) != nil {
                return (item as! BasicINDIClient)
            } else if (item as? INDIDevice) != nil {
                return (item as! INDIDevice)
            }
        } else if outlineView == propertyListView {
            if (item as? String) != nil {
                return item
            } else if (item as? INDIPropertyVector) != nil {
                return (item as! INDIPropertyVector).name
            }
        }
        return "Outline Test"
    }
    
    // MARK:- NSOutlineView Delegate methods
    
    /**
     * Grouped items are only used in the navigation view, i.e. when the item is a `BasicINDIClient`. Devices, which are also shown in
     * the navigation view are not a group and are selectable.
     */
    public func outlineView(_ outlineView: NSOutlineView, isGroupItem item: Any) -> Bool {
        if outlineView == navigationView && (item as? BasicINDIClient) != nil {
            return true
        } else if outlineView == propertyListView && (item as? String) != nil {
            return true // Group of property vectors.
        }
        return false
    }
    
    public func outlineView(_ outlineView: NSOutlineView, heightOfRowByItem item: Any) -> CGFloat {
        if (item as? BasicINDIClient) != nil {
            return 38.0
        } else if (item as? INDIDevice) != nil {
            return 22.0
        } else if (item as? INDIProperty) != nil {
            return 16.0
        }
        return 24.0
    }
    
    public func outlineViewSelectionDidChange(_ notification: Notification) {
        if (notification.object as? NSOutlineView) != nil && (notification.object as? NSOutlineView) == navigationView {
            if navigationView?.selectedRow != nil {
                let selectedItem = navigationView?.item(atRow: navigationView!.selectedRow)
                if (selectedItem as? INDIDevice) != nil {
                    self.device = (selectedItem as! INDIDevice)
                }
            }
        }
    }
		
    
    public func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView? {
        self.registerItemViews()
        if outlineView == navigationView {
            if (item as? BasicINDIClient) != nil {
                let cell = navigationView!.makeView(withIdentifier:.serverItemView, owner: self) as? INDIServerItemView
                var label = ""
                let client = item as! BasicINDIClient
                let address = ("\(client.server!):\(client.port)")
                if client.label != nil {
                    label = client.label!
                } else if client.server != nil {
                    label = client.server!
                }
                cell?.serverLabel?.stringValue = label
                cell?.serverAddress?.stringValue = address
                let connected = client.connected
                if connected {
                    cell!.status = .ok
                } else {
                    cell!.status = .idle
                }
                return cell
            } else if (item as? INDIDevice) != nil {
                let cell = navigationView!.makeView(withIdentifier:.deviceItemView, owner: self) as? INDIDeviceItemView
                let device = item as! INDIDevice
                let label = device.name
                cell?.deviceName?.stringValue = label
                return cell
            }
        } else if outlineView == propertyListView {
            if tableColumn == nil {
                let cell = outlineView.makeView(withIdentifier: .groupItemView, owner: self) as? INDIGroupItemView
                cell?.groupName?.stringValue = item as! String
                return cell
            } else if (item as? INDIPropertyVector) != nil {
                if tableColumn?.identifier.rawValue == "PropertyName" {
                    let cell = outlineView.makeView(withIdentifier: .propertyVectorItemView, owner: self) as? INDIPropertyVectorItemView
                    let propertyVector = item as! INDIPropertyVector
                    var label = propertyVector.label
                    if label == nil {
                        label = propertyVector.name
                    }
                    cell?.propertyVectorName?.stringValue = label!
                    cell?.status = propertyVector.state
                    return cell
                } else {
                }
            } else if (item as? INDIProperty) != nil {
                if tableColumn?.identifier.rawValue == "PropertyName" {
                    let cell = outlineView.makeView(withIdentifier: .propertyItemView, owner: self) as? INDIPropertyItemVIew
                    let property = item as! INDIProperty
                    var label = property.label
                    if label == nil {
                        label = property.name
                    }
                    cell?.propertyName?.stringValue = label!
                    return cell
                } else {
                    if (item as? INDIProperty) != nil {
                        let cell = outlineView.makeView(withIdentifier: .textPropertyItemView, owner: self) as? INDITextPropertyValueView
                        let property = item as! INDIProperty
                        let value = property.value
                        if value != nil {
                            cell?.textValue?.stringValue = "\(value!)"
                            return cell
                        }
                    }
                }
           }
        }
        return nil
    }
}

extension NSUserInterfaceItemIdentifier {
    static let serverItemView = NSUserInterfaceItemIdentifier("serverItemView")
    static let deviceItemView = NSUserInterfaceItemIdentifier("deviceItemView")
    
    static let groupItemView = NSUserInterfaceItemIdentifier("groupItemView")
    static let propertyItemView = NSUserInterfaceItemIdentifier("propertyItemView")
    static let propertyVectorItemView = NSUserInterfaceItemIdentifier("propertyVectorItemView")
    static let textPropertyItemView = NSUserInterfaceItemIdentifier("textPropertyItemView")
    static let numberPropertyItemView = NSUserInterfaceItemIdentifier("numberPropertyItemView")
    static let switchPropertyItemView = NSUserInterfaceItemIdentifier("switchPropertyItemView")
    static let lightPropertyItemView = NSUserInterfaceItemIdentifier("lightPropertyItemView")
    static let BLOBPropertyItemView = NSUserInterfaceItemIdentifier("BLOBPropertyItemView")
}
