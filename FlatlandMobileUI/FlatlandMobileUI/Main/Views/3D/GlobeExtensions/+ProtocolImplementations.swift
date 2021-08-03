//
//  +ProtocolImplementations.swift
//  Flatland
//
//  Created by Stuart Rankin on 4/6/21.
//  Copyright © 2021 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

#if false
// MARK: - Point entry code (for POIs).
extension GlobeView: PointEntryProtocol 
{
    /// Point entry is complete.
    /// - Parameter Name: Name of the point.
    /// - Parameter Color: Color of the pointer.
    /// - Parameter Point: Location of the point.
    /// - Parameter ID: ID of the edited point. If nil, a new point was created.
    func PointEntryComplete(Name: String, Color: UIColor, Point: GeoPoint, ID: UUID?)
    {
        ResetFromPointEntry()
        if let ExistingID = ID
        {
            DBIF.EditUserPOI(ID: ExistingID, Name: Name, Color: Color, Point: Point)
            DBIF.ReloadTables()
            SettingChanged(Setting: .ShowUserLocations, OldValue: nil, NewValue: nil)
        }
        else
        {
            DBIF.AddUserPOI(Name: Name, Color: Color, Point: Point)
            DBIF.ReloadTables()
            SettingChanged(Setting: .ShowUserLocations, OldValue: nil, NewValue: nil)
        }
    }
    
    /// Point entry is complete. Not currently used.
    /// - Parameter Name: Name of the point.
    /// - Parameter Color: Color of the pointer.
    /// - Parameter Point: Location of the point.
    func PointEntrySessionComplete(Name: String, Color: UIColor, Point: GeoPoint)
    {
        ResetFromPointEntry()
    }
    
    /// Point entry canceled by user.
    func PointEntryCanceled()
    {
        ResetFromPointEntry()
    }
    
    /// Plot a point on the surface of the globe.
    /// - Parameter Latitude: Latitude of the point to plot.
    /// - Parameter Longitude: Longitude of the point to plot.
    func PlotPoint(Latitude: Double, Longitude: Double)
    {
        MousePointerType = .StartPin
        UpperLeftNode = MakePlottedPin(Latitude, Longitude, Color: UIColor.green)
        EarthNode?.addChildNode(UpperLeftNode!)
    }
    
    /// Move a previously plotted point on the surface of the globe.
    /// - Parameter Latitude: Latitude of the point to plot.
    /// - Parameter Longitude: Longitude of the point to plot.
    func MovePlottedPoint(Latitude: Double, Longitude: Double)
    {
        RemovePins()
        PlotPoint(Latitude: Latitude, Longitude: Longitude)
    }
    
    /// Remove the pin from the globe. (Pins are used to mark the point on the globe.)
    func RemovePin()
    {
        RemovePins()
    }
    
    /// Delete the point.
    /// - Parameter ID: ID of the user POI to delete.
    func DeletePOI(ID: UUID)
    {
        EarthNode?.ForEachChild2()
        {
            Node in
            if Node.NodeID == ID
            {
                Debug.Print("Deleting user POI node \(ID.uuidString)")
                DBIF.DeleteUserPOI(ID: ID)
                DBIF.ReloadTables()
                Node.HideBoundingShape()
                Node.Clear()
                return
            }
        }
    }
    
    /// Reset the globe state from point entry.
    func ResetFromPointEntry()
    {
        Settings.SetBool(.WorldIsLocked, OldLockState)
        POIEditorOpen = false
        InPointCreationMode = false
        MouseClickReceiver = nil
        RemoveUpperLeftCorner()
    }
}

// MARK: - Pop over dialog code.
extension GlobeView: PopOverParent
{
    /// Run the edit home dialog.
    func EditHome()
    {
    }
    
    /// Run the edit user POI dialog.
    /// - Note: If the editor is already open, this function returns without taking action.
    /// - Parameter ID: ID of the point-of-interest to edit.
    func EditUserPOI(_ ID: UUID)
    {
        #if false
        guard !POIEditorOpen else
        {
            return
        }
        var EditMe: POI2? = nil
        for SomePOI in DBIF.UserPOIs
        {
            if SomePOI.ID == ID
            {
                EditMe = SomePOI
                break
            }
        }
        guard EditMe != nil else
        {
            Debug.Print("Did not find POI with ID \(ID.uuidString)")
            return
        }

        POIEditorOpen = true
        let Storyboard = NSStoryboard(name: "POIEntryUI", bundle: nil)
        if let WindowController = Storyboard.instantiateController(withIdentifier: "POIEntryWindow") as? POIEntryWindow
        {
            let Window = WindowController.window
            if let Controller = Window?.contentViewController as? POIEntryController
            {
                InPointCreationMode = true
                Settings.SetBool(.WorldIsLocked, true)
                Controller.ParentDelegate = self
                Controller.MainDelegate = MainDelegate
                MouseClickReceiver = Controller
                Controller.EditExistingPoint(EditMe!)
                WindowController.showWindow(nil)
            }
        }
        else
        {
            POIEditorOpen = false
        }
        #endif
    }
}
#endif
