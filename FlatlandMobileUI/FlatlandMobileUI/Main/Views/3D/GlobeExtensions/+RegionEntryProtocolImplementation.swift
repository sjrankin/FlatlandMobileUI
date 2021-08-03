//
//  +RegionEntryProtocolImplementation.swift
//  Flatland
//
//  Created by Stuart Rankin on 1/15/21.
//  Copyright © 2021 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit
import SceneKit

#if false
// - MARK: Region entry protocol functions.
extension GlobeView: RegionEntryProtocol
{
    /// Called when region entry was completed by the user.
    /// - Note: This function assigns the following defaults:
    ///    - `Region.Age = 30`
    ///    - `Region.MinimumMagnitude = 5.0`
    ///    - `Region.MaximumMagnitude = 9.9`
    ///    - `Region.IsFallback = false`
    ///    - `Region.IsEnabled = true`
    ///    - `Region.IsRectangular = true`
    ///    - `Region.Notification = .None`
    ///    - `Region.NotifyOnNewEarthquakes = false`
    /// - Note: The newly created region will be immediately assigned in the settings, which will trigger an
    ///         event that will cause regions on the globe to be redrawn.
    /// - Parameter Name: The name of the region.
    /// - Parameter Color: The color of the region.
    /// - Parameter Corner1: The upper-left (northwest) corner of the region.
    /// - Parameter Corner2: The lower-right (southeast) corner of the region.
    func RegionEntryCompleted(Name: String, Color: UIColor, Corner1: GeoPoint, Corner2: GeoPoint)
    {
        ResetFromRegionEntry()
        let NewRegion = UserRegion()
        NewRegion.Age = 30
        NewRegion.MinimumMagnitude = 5.0
        NewRegion.MaximumMagnitude = 9.9
        NewRegion.RegionName = Name
        NewRegion.IsFallback = false
        NewRegion.IsEnabled = true
        NewRegion.IsRectangular = true
        NewRegion.Notification = .None
        NewRegion.NotifyOnNewEarthquakes = false
        NewRegion.RegionColor = Color
        NewRegion.UpperLeft = Corner1
        NewRegion.LowerRight = Corner2
        var OldRegions = Settings.GetEarthquakeRegions()
        OldRegions.append(NewRegion)
        //This will trigger an event that will cause the regions to be redrawn.
        Settings.SetEarthquakeRegions(OldRegions)
    }
    
    /// Handle completion of radial region creation.
    /// - Note: This function assigns the following defaults:
    ///    - `Region.Age = 30`
    ///    - `Region.MinimumMagnitude = 5.0`
    ///    - `Region.MaximumMagnitude = 9.9`
    ///    - `Region.IsFallback = false`
    ///    - `Region.IsEnabled = true`
    ///    - `Region.IsRectangular = false`
    ///    - `Region.Notification = .None`
    ///    - `Region.NotifyOnNewEarthquakes = false`
    /// - Note: The newly created region will be immediately assigned in the settings, which will trigger an
    ///         event that will cause regions on the globe to be redrawn.
    /// - Parameter Name: The name of the polar region.
    /// - Parameter Color: The color of the polar region.
    /// - Parameter Center: The center of the radial region.
    /// - Parameter Radius: The radial size of the polar region.
    func RadialRegionEntryCompleted(Name: String, Color: UIColor, Center: GeoPoint, Radius: Double)
    {
        ResetFromRegionEntry()
        let NewRegion = UserRegion()
        NewRegion.Age = 30
        NewRegion.MinimumMagnitude = 5.0
        NewRegion.MaximumMagnitude = 9.9
        NewRegion.RegionName = Name
        NewRegion.IsFallback = false
        NewRegion.IsEnabled = true
        NewRegion.IsRectangular = false
        NewRegion.Notification = .None
        NewRegion.NotifyOnNewEarthquakes = false
        NewRegion.RegionColor = Color
        NewRegion.Radius = Radius
        NewRegion.Center = Center
        var OldRegions = Settings.GetEarthquakeRegions()
        OldRegions.append(NewRegion)
        Settings.SetEarthquakeRegions(OldRegions)
    }
    
    /// Call when the user cancels region entry.
    func RegionEntryCanceled()
    {
        ResetFromRegionEntry()
    }
    
    /// Called once the user is done (either accepting a region or canceling entry) with region entry. Resets
    /// state to normal usage.
    func ResetFromRegionEntry()
    {
        Settings.SetBool(.WorldIsLocked, OldLockState)
        RegionEditorOpen = false
        InRegionCreationMode = false
        MouseClickReceiver = nil
        RemoveUpperLeftCorner()
        RemoveLowerRightCorner()
    }
    
    /// Create and return a 3D pin shape to mark a corner of a region.
    /// - Parameter Latitude: The latitude of the pin.
    /// - Parameter Longitude: The longitude of the pin.
    /// - Parameter Color: The color of the pin.
    /// - Returns: `SCNNode2` shape of a pin.
    func MakePlottedPin(_ Latitude: Double, _ Longitude: Double, Color: UIColor) -> SCNNode2
    {
        let (X, Y, Z) = Geometry.ToECEF(Latitude, Longitude, Radius: Double(GlobeRadius.Primary.rawValue) + 0.9)
        let PinNode = SCNPin(KnobHeight: 2.0, KnobRadius: 1.0, PinHeight: 1.4, PinRadius: 0.15,
                             KnobColor: Color, PinColor: UIColor.gray)
        PinNode.scale = SCNVector3(NodeScales3D.PinScale.rawValue,
                                   NodeScales3D.PinScale.rawValue,
                                   NodeScales3D.PinScale.rawValue)
        PinNode.LightMask = LightMasks3D.Sun.rawValue | LightMasks3D.Moon.rawValue
        
        PinNode.name = GlobeNodeNames.PinnedLocationNode.rawValue
        PinNode.castsShadow = true
        PinNode.SetLocation(Latitude, Longitude)
        PinNode.position = SCNVector3(X, Y, Z)
        
        let Day: EventAttributes =
            {
                let D = EventAttributes()
                D.ForEvent = .SwitchToDay
                D.Diffuse = Color
                D.Specular = UIColor.white
                D.Emission = nil
                return D
            }()
        let Night: EventAttributes =
            {
                let N = EventAttributes()
                N.ForEvent = .SwitchToNight
                N.Diffuse = Color
                N.Specular = UIColor.white
                N.Emission = Color
                return N
            }()
        PinNode.AddEventAttributes(Event: .SwitchToDay, Attributes: Day)
        PinNode.AddEventAttributes(Event: .SwitchToNight, Attributes: Night)
        PinNode.CanSwitchState = true
        if let InDay = Solar.IsInDaylight(Latitude, Longitude)
        {
            PinNode.IsInDaylight = InDay
        }
        
        let YRotation = Latitude + 90.0
        let XRotation = Longitude + 180.0
        PinNode.eulerAngles = SCNVector3(YRotation.Radians, XRotation.Radians, 0.0)
        
        return PinNode
    }
    
    /// Remove pins plotted on the globe when defining a region.
    func RemovePins()
    {
        for Node in EarthNode!.childNodes
        {
            if Node.name == GlobeNodeNames.PinnedLocationNode.rawValue
            {
                Node.removeAllActions()
                Node.removeAllAnimations()
                Node.removeFromParentNode()
                Node.geometry = nil
            }
        }
        UpperLeftNode = nil
        LowerRightNode = nil
    }
    
    /// Called by the region creation dialog to plot the upper-left (northwest) corner of a region.
    /// - Parameter Latitude: The latitude of the corner.
    /// - Parameter Longitude: The longitude of the corner.
    func PlotUpperLeftCorner(Latitude: Double, Longitude: Double)
    {
        UpperLeftNode = MakePlottedPin(Latitude, Longitude, Color: UIColor.green)
        EarthNode?.addChildNode(UpperLeftNode!)
    }
    
    /// Called by the region creation dialog to plot the lower-right (southeast) corner of a region.
    /// - Parameter Latitude: The latitude of the corner.
    /// - Parameter Longitude: The longitude of the corner.
    func PlotLowerRightCorner(Latitude: Double, Longitude: Double)
    {
        LowerRightNode = MakePlottedPin(Latitude, Longitude, Color: UIColor.red)
        EarthNode?.addChildNode(LowerRightNode!)
    }
    
    /// Removes the upper-left corner pin.
    func RemoveUpperLeftCorner()
    {
        UpperLeftNode?.removeFromParentNode()
        UpperLeftNode = nil
    }
    
    /// Removes the lower-right corner pin.
    func RemoveLowerRightCorner()
    {
        LowerRightNode?.removeFromParentNode()
        LowerRightNode = nil
    }
    
    /// Turn the mouse pointer into the start pin.
    func SetStartPin()
    {
        MouseIndicator = nil
        MousePointerType = .StartPin
        PlotMouseIndicator()
    }
    
    /// Turn the mouse pointer into the end pin.
    func SetEndPin()
    {
        MouseIndicator = nil
        MousePointerType = .EndPin
        PlotMouseIndicator()
    }
    
    /// Reset the mouse pointer to its normal state.
    func ResetMousePointer()
    {
        MouseIndicator = nil
        MousePointerType = .Normal
        PlotMouseIndicator()
    }
    
    /// Removes the mouse pointer (regardless of shape).
    func ClearMousePointer()
    {
        RemoveMousePointer()
    }
    
    /// Plot a transient region.
    func PlotTransient(ID: UUID, Point1: GeoPoint, Point2: GeoPoint, Color: UIColor)
    {
        PlotTransientRegion(Point1: Point1, Point2: Point2, Color: Color, ID: ID)
    }
    
    /// Plot a polar transient region.
    func PlotTransient(ID: UUID, NorthPole: Bool, Radius: Double, Color: UIColor)
    {
        PlotTransientRegion(NorthPole: NorthPole, Radius: Radius, Color: Color, ID: ID)
    }
    
    /// Plot a radial transient region.
    func PlotTransient(ID: UUID, Center: GeoPoint, Radius: Double, Color: UIColor)
    {
        let TRegion = UserRegion()
        TRegion.RegionColor = Color
        TRegion.ID = ID
        TRegion.Center = Center
        TRegion.Radius = Radius
        AddRadialRegion(TRegion)
    }
    
    /// Update a transient region.
    func UpdateTransient(ID: UUID, Point1: GeoPoint, Point2: GeoPoint, Color: UIColor)
    {
        UpdateTransientRegion(ID: ID, Point1: Point1, Point2: Point2, Color: Color)
    }
    
    /// Update a polar transient region.
    func UpdateTransient(ID: UUID, NorthPole: Bool, Radius: Double, Color: UIColor)
    {
        UpdateTransientRegion(ID: ID, NorthPole: NorthPole, Radius: Radius, Color: Color)
    }
    
    /// Update a radial transient region.
    func UpdateTransient(ID: UUID, Center: GeoPoint, Radius: Double, Color: UIColor)
    {
        RemoveRadialRegion(ID: ID)
        let TRegion = UserRegion()
        TRegion.RegionColor = Color
        TRegion.ID = ID
        TRegion.Center = Center
        TRegion.Radius = Radius
        UpdateRadialRegion(With: TRegion)
    }
    
    /// Remove transient regions.
    func RemoveTransientRegions()
    {
        ClearTransientRegions()
    }
    
    /// Remove the specified transient region.
    /// Parameter ID: The ID of the transient region to remove.
    func RemoveTransientRegion(ID: UUID)
    {
        ClearTransientRegion(ID: ID)
    }
    
    /// Remove the specified transient radial region.
    /// - Parameter ID: The ID of the transient region to remove.
    func RemoveRadialTransientRegion(ID: UUID)
    {
        RemoveRadialRegion(ID: ID)
    }
}
#endif
