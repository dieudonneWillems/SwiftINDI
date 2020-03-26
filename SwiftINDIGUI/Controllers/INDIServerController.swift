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
    
    /**
     * The device whose information is shown.
     */
    public var device : INDIDevice? {
        didSet {
            if device != nil {
                if (view as? NSOutlineView) != nil {
                    (view as! NSOutlineView).needsDisplay = true
                }
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
            let nib = NSNib(nibNamed: "INDIServerItemView", bundle: bundle)
            // Register view so that it can be used as a cell view.
            navigationView!.register(nib, forIdentifier: .serverItemView)
            self.registeredViews = true
        }
    }
    
    // MARK: - NSOutlineViewDataSource methods
    
    public func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any {
        if outlineView == navigationView {
            if item == nil {
                return clients[index]
            } else if (item as? BasicINDIClient) != nil {
                return (item as! BasicINDIClient).devices
            }
        } else if outlineView == propertyListView {
            if item == nil {
                return device!.groups[index]
            } else if (item as? INDIDevice) != nil {
                return (item as! INDIDevice).groups[index]
            } else if (item as? String) != nil {
                return device!.propertyVectors(in: item as! String)[index]
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
            if (item as? INDIDevice) != nil {
                let ngroups = (item as! INDIDevice).groups.count
                return ngroups > 0
            } else if (item as? String) != nil {
                return device!.propertyVectors(in: item as! String).count > 0
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
                if device != nil {
                    return device!.groups.count
                }
            } else if (item as? INDIDevice) != nil {
                return (item as! INDIDevice).groups.count
            } else if (item as? String) != nil {
                return device!.propertyVectors(in: item as! String).count
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
            if (item as? INDIDevice) != nil {
                return (item as! INDIDevice).name
            } else if (item as? String) != nil {
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
        }
        return false
    }
    
    public func outlineView(_ outlineView: NSOutlineView, heightOfRowByItem item: Any) -> CGFloat {
        if (item as? BasicINDIClient) != nil {
            return 36.0
        }
        return 24.0
    }
    
    public func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView? {
        self.registerItemViews()
        if outlineView == navigationView {
            let cell = navigationView!.makeView(withIdentifier:.serverItemView, owner: self) as? INDIServerItemView
            if (item as? BasicINDIClient) != nil {
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
                    cell!.statusView?.image = NSImage(named:"NSStatusAvailable")
                }
            } else if (item as? INDIDevice) != nil {
                let device = item as! INDIDevice
                let label = device.name
                cell?.serverLabel?.stringValue = label
            }
            return cell
        } else if outlineView == propertyListView {
            let cell = outlineView.makeView(withIdentifier: (tableColumn!.identifier), owner: self) as? NSTableCellView
            if (item as? INDIDevice) != nil {
                if tableColumn?.title == "Property" {
                    cell?.textField?.stringValue = (item as! INDIDevice).name
                } else {
                    cell?.textField?.stringValue = ""
                }
            } else if (item as? String) != nil {
                cell?.textField?.stringValue = item as! String
            } else if (item as? INDIPropertyVector) != nil {
                cell?.textField?.stringValue = (item as! INDIPropertyVector).name
            }
            return cell
        }
        return nil
    }
}

extension NSUserInterfaceItemIdentifier {
    static let serverItemView = NSUserInterfaceItemIdentifier("serverItemView")
    static let deviceItemView = NSUserInterfaceItemIdentifier("deviceItemView")
    
    static let propertyItemView = NSUserInterfaceItemIdentifier("propertyItemView")
}
