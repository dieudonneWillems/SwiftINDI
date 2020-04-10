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
    
    @IBOutlet weak public var detailView : NSView?
    
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
    public private(set) var servers = [BasicINDIServer]()
    
    /**
     * Adds a client to the GUI.
     * - Parameter client: The client to be added.
     */
    public func addClient(_ client: BasicINDIServer) {
        servers.append(client)
        self.reload()
    }
    
    /**
     * Inserts a client into the GUI at the specified `index` in the list of INDI clients.
     * - Parameter client: The client to be inserted.
     * - Parameter index: The index in the list.
     */
    public func insertClient(_ client: BasicINDIServer, at index: Int) {
        servers.insert(client, at: index)
        self.reload()
    }
    
    /**
     * Removes a client from the GUI at the specified `index` in the list of INDI clients.
     * - Parameter index: The index in the list.
     */
    public func removeClient(at index: Int) {
        servers.remove(at: index)
        self.reload()
    }
    
    public func removeAllServers() {
        servers.removeAll()
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
    
    public private(set) var selectedPropertyVector : INDIPropertyVector?
    
    public private(set) var selectedProperty : INDIProperty?
    
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
            
            let nibTextPropertyItem = NSNib(nibNamed: "INDIPropertyValueView", bundle: bundle)
            propertyListView!.register(nibTextPropertyItem, forIdentifier: .propertyValueView)
            
            let nibPropertyVectorValue = NSNib(nibNamed: "INDIPropertyVectorValueView", bundle: bundle)
            propertyListView!.register(nibPropertyVectorValue, forIdentifier: .propertyVectorValueView)
            
            self.registeredViews = true
        }
    }
    
    /**
     * Returns the detail view controller used for a specific property.
     * - Parameter property: The property whose details need to be displayed.
     * - Returns: The view controller.
     */
    public func detailViewController(for property: INDIProperty) -> INDIViewController? {
        let bundle = Bundle(for: type(of: self))
        if (property as? INDITextProperty) != nil {
            let textPropertyController = INDITextPropertyViewController()
            _ = bundle.loadNibNamed("INDITextPropertyView", owner: textPropertyController, topLevelObjects: nil)
            return textPropertyController
        }
        return nil
    }
    
    /**
     * Shows the relevant views in the property detail view in which the user can change values, depending on the
     * selected `INDIPropertyVector` or `INDIProperty`.
     */
    func showPropertyDetailView() {
        var selectedViewControllers = [INDIViewController]()
        if selectedPropertyVector != nil {
            if (selectedPropertyVector as? INDITextPropertyVector) != nil {
                for property in selectedPropertyVector!.memberProperties {
                    let viewController = self.detailViewController(for: property)
                    if viewController != nil {
                        selectedViewControllers.append(viewController!)
                        viewController?.property = property
                    } else {
                        print("WARNING: No detail view found for text property.")
                    }
                }
            }
        } else if selectedProperty != nil {
            let viewController = self.detailViewController(for: selectedProperty!)
            if (selectedProperty as? INDITextProperty) != nil {
                if viewController != nil {
                    selectedViewControllers.append(viewController!)
                    viewController?.property = selectedProperty
                } else {
                    print("WARNING: No detail view found for text property.")
                }
            }
        }
        self.changePropertyDetailView(subviewControllers: selectedViewControllers)
    }
    
    /**
     * Removes the current subviews of the details view and replaces them with the views connected to the
     * specified view controllers.
     * - Parameter subviewControllers: The view controllers for the
     */
    private func changePropertyDetailView(subviewControllers: [NSViewController]) {
        // Remove subviews
        let subviews = detailView?.subviews
        if subviews != nil {
            // Itterate through subviews
            for subview in subviews! {
                subview.removeFromSuperview()
            }
        }
        
        // Add new subviews
        detailView?.translatesAutoresizingMaskIntoConstraints = false
        var previousView : NSView? = nil
        for controller in subviewControllers {
            if detailView != nil {
                detailView!.addSubview(controller.view)
                
                controller.view.translatesAutoresizingMaskIntoConstraints = false
                // Set layout constraints
                let leadingConstraint = NSLayoutConstraint(item: detailView!, attribute: NSLayoutConstraint.Attribute.leading, relatedBy: NSLayoutConstraint.Relation.equal, toItem: controller.view, attribute: NSLayoutConstraint.Attribute.leading, multiplier: 1, constant: 0)
                let trailingConstraint = NSLayoutConstraint(item: detailView!, attribute: NSLayoutConstraint.Attribute.trailing, relatedBy: NSLayoutConstraint.Relation.equal, toItem: controller.view, attribute: NSLayoutConstraint.Attribute.trailing, multiplier: 1, constant: 0)
                let widthConstraint = NSLayoutConstraint(item: controller.view, attribute: NSLayoutConstraint.Attribute.width, relatedBy: NSLayoutConstraint.Relation.greaterThanOrEqual, toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute, multiplier: 1, constant: 250.0)
                // Constraints need to be set to the common superview
                detailView!.addConstraint(leadingConstraint)
                detailView!.addConstraint(trailingConstraint)
                controller.view.addConstraint(widthConstraint)
                if previousView == nil { // If this is the first view in the detail view, connect the top to the top of the detail view
                    let topConstraint = NSLayoutConstraint(item: detailView!, attribute: NSLayoutConstraint.Attribute.top, relatedBy: NSLayoutConstraint.Relation.equal, toItem: controller.view, attribute: NSLayoutConstraint.Attribute.top, multiplier: 1, constant: 0)
                    detailView!.addConstraint(topConstraint)
                } else { // If this is NOT the first view in the detail view, connect the top to the bottom of the previous view
                    let topConstraint = NSLayoutConstraint(item: previousView!, attribute: NSLayoutConstraint.Attribute.bottom, relatedBy: NSLayoutConstraint.Relation.equal, toItem: controller.view, attribute: NSLayoutConstraint.Attribute.top, multiplier: 1, constant: 0)
                    detailView!.addConstraint(topConstraint)
                }
                previousView = controller.view
            }
        }
    }
    
    // MARK: - NSOutlineViewDataSource methods
    
    public func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any {
        if outlineView == navigationView {
            if item == nil {
                return servers[index]
            } else if (item as? BasicINDIServer) != nil {
                let client = (item as! BasicINDIServer)
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
            if (item as? BasicINDIServer) != nil {
                return (item as! BasicINDIServer).devices.count > 0
            }
        } else if outlineView == propertyListView {
            if (item as? String) != nil {
                return false //group
            } else if (item as? INDITextPropertyVector) != nil { // only text properties are presented with multiple items
                return (item as! INDITextPropertyVector).memberProperties.count > 0
            } else if (item as? INDINumberPropertyVector) != nil { // only number properties are presented with multiple items
                return (item as! INDINumberPropertyVector).memberProperties.count > 0
            } else if (item as? INDIPropertyVector) != nil { // for other properties the value is presented in the property vector view
                return false
            }
        }
        return false
    }
    
    public func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {
        if outlineView == navigationView {
            if item == nil {
                return servers.count
            } else if (item as? BasicINDIServer) != nil {
                return (item as! BasicINDIServer).devices.count
            }
        } else if outlineView == propertyListView {
            if item == nil {
                return rootLevelPropertyItems.count
            } else if (item as? String) != nil {
                return 0 // group
            } else if (item as? INDITextPropertyVector) != nil { // only text properties are presented with multiple items
                return (item as! INDITextPropertyVector).memberProperties.count
            } else if (item as? INDINumberPropertyVector) != nil { // only text properties are presented with multiple items
                return (item as! INDINumberPropertyVector).memberProperties.count
            } else if (item as? INDIPropertyVector) != nil { // for other properties the value is presented in the property vector view
                return 0
            }
        }
        return 0
    }
    
    public func outlineView(_ outlineView: NSOutlineView, objectValueFor tableColumn: NSTableColumn?, byItem item: Any?) -> Any? {
        if outlineView == navigationView {
            if (item as? BasicINDIServer) != nil {
                return (item as! BasicINDIServer)
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
     * Grouped items are only used in the navigation view, i.e. when the item is a `BasicINDIServer`. Devices, which are also shown in
     * the navigation view are not a group and are selectable.
     */
    public func outlineView(_ outlineView: NSOutlineView, isGroupItem item: Any) -> Bool {
        if outlineView == navigationView && (item as? BasicINDIServer) != nil {
            return true
        } else if outlineView == propertyListView && (item as? String) != nil {
            return true // Group of property vectors.
        }
        return false
    }
    
    public func outlineView(_ outlineView: NSOutlineView, heightOfRowByItem item: Any) -> CGFloat {
        if (item as? BasicINDIServer) != nil {
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
        } else if (notification.object as? NSOutlineView) != nil && (notification.object as? NSOutlineView) == propertyListView {
            if propertyListView?.selectedRow != nil {
                let selectedItem = propertyListView?.item(atRow: propertyListView!.selectedRow)
                if (selectedItem as? INDIPropertyVector) != nil {
                    self.selectedPropertyVector = (selectedItem as! INDIPropertyVector)
                    self.showPropertyDetailView()
                } else if (selectedItem as? INDIProperty) != nil {
                    self.selectedProperty = (selectedItem as! INDIProperty)
                    self.showPropertyDetailView()
                }
            }
        }
    }
		
    
    public func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView? {
        self.registerItemViews()
        if outlineView == navigationView {
            if (item as? BasicINDIServer) != nil {
                let cell = navigationView!.makeView(withIdentifier:.serverItemView, owner: self) as? INDIServerItemView
                var label = ""
                let server = item as! BasicINDIServer
                let address = ("\(server.host!):\(server.port)")
                if server.label != nil {
                    label = server.label!
                } else if server.host != nil {
                    label = server.host!
                }
                cell?.serverLabel?.stringValue = label
                cell?.serverAddress?.stringValue = address
                let connected = server.connected
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
                    let label = propertyVector.uiLabel
                    cell?.propertyVectorName?.stringValue = label
                    cell?.status = propertyVector.state
                    return cell
                } else if (item as? INDISwitchPropertyVector) != nil {
                    let property = item as! INDISwitchPropertyVector
                    let cell = outlineView.makeView(withIdentifier: .propertyVectorValueView, owner: self) as? INDIPropertyVectorValueView
                    var onString = ""
                    if property.memberProperties.count == 1 {
                        onString = "\((property.memberProperties[0] as! INDISwitchProperty).switchState.rawValue)"
                    } else {
                        let onProps = property.on
                        for onProp in onProps {
                            let propLabel = onProp.uiLabel
                            if onString.count > 0 {
                                onString = "\(onString); \(propLabel)"
                            } else {
                                onString = propLabel
                            }
                        }
                    }
                    cell?.textValue?.stringValue = onString
                    return cell
                } else if (item as? INDIPropertyVector)!.memberProperties.count == 1 {
                    let property = item as! INDIPropertyVector
                    let cell = outlineView.makeView(withIdentifier: .propertyVectorValueView, owner: self) as? INDIPropertyVectorValueView
                    let value = property.memberProperties[0].value
                    if value != nil {
                        cell?.textValue?.stringValue = "\(value!)"
                    } else {
                        cell?.textValue?.stringValue = ""
                    }
                    return cell
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
                        let cell = outlineView.makeView(withIdentifier: .propertyValueView, owner: self) as? INDIPropertyValueView
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
    static let propertyValueView = NSUserInterfaceItemIdentifier("propertyValueView")
    static let propertyVectorValueView = NSUserInterfaceItemIdentifier("propertyVectorValueView")
    
}
