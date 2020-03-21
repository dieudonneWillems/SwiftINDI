//
//  INDIPropertyListViewController.swift
//  SwiftINDIGUI
//
//  Created by Don Willems on 21/03/2020.
//  Copyright © 2020 lapsedpacifist. All rights reserved.
//

import Cocoa
import SwiftINDI

public class INDIPropertyListViewController: NSViewController, NSOutlineViewDataSource, NSOutlineViewDelegate {
    
    @IBOutlet weak public var outlineView : NSOutlineView?
    
    public static var instance : INDIPropertyListViewController? {
        get {
            let bundle = Bundle(for: INDIPropertyListViewController.self)
            let nib = NSNib(nibNamed: "INDIPropertyListViewController", bundle: bundle)
            let controller = INDIPropertyListViewController()
            guard (nib?.instantiate(withOwner: controller, topLevelObjects: nil))! else {
                return nil
            }
            return controller
        }
    }
    
    public var client : BasicINDIClient? {
        willSet(newValue) {
            if newValue != nil {
                device = nil
            }
        }
        didSet {
            if client != nil {
                if (view as? NSOutlineView) != nil {
                    (view as! NSOutlineView).needsDisplay = true
                }
            }
        }
    }
    
    public var device : INDIDevice? {
        willSet(newValue) {
            if newValue != nil {
                client = nil
            }
        }
        didSet {
            if device != nil {
                if (view as? NSOutlineView) != nil {
                    (view as! NSOutlineView).needsDisplay = true
                }
            }
        }
    }
    
    public func reload() {
        outlineView?.reloadData()
        outlineView?.needsDisplay = true
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // MARK: - NSOutlineViewDataSource methods
    
    public func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any {
        if item == nil {
            if client != nil {
                let deviceNames = Array(client!.devices.keys)
                return client!.devices[deviceNames[index]]!
            } else if device != nil {
                return device!.groups[index]
            }
        } else if (item as? INDIDevice) != nil {
            return (item as! INDIDevice).groups[index]
        } else if (item as? String) != nil {
            return device!.propertyVectors(in: item as! String)[index]
        } else if (item as? INDIPropertyVector) != nil {
            return (item as! INDIPropertyVector).memberProperties[index]
        }
        return ""
    }
    
    public func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool {
        if (item as? INDIDevice) != nil {
            let ngroups = (item as! INDIDevice).groups.count
            return ngroups > 0
        } else if (item as? String) != nil {
            return device!.propertyVectors(in: item as! String).count > 0
        } else if (item as? INDIPropertyVector) != nil {
            return (item as! INDIPropertyVector).memberProperties.count > 0
        }
        return false
    }
    
    public func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {
        if item == nil {
            if client != nil {
                return client!.devices.count
            } else if device != nil {
                return device!.groups.count
            }
        } else if (item as? INDIDevice) != nil {
            return (item as! INDIDevice).groups.count
        } else if (item as? String) != nil {
            return device!.propertyVectors(in: item as! String).count
        } else if (item as? INDIPropertyVector) != nil {
            return (item as! INDIPropertyVector).memberProperties.count
        }
        return 0
    }
    
    public func outlineView(_ outlineView: NSOutlineView, objectValueFor tableColumn: NSTableColumn?, byItem item: Any?) -> Any? {
        if (item as? INDIDevice) != nil {
            return (item as! INDIDevice).name
        } else if (item as? String) != nil {
            return item
        } else if (item as? INDIPropertyVector) != nil {
            return (item as! INDIPropertyVector).name
        }
        return "Outline Test"
    }
    
    // MARK:- NSOutlineView Delegate methods
    
    public func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView? {
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
}
