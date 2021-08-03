//
//  +Rotations.swift
//  Flatland
//
//  Created by Stuart Rankin on 12/26/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit
import SceneKit

// MARK: - Code related to rotation of the globe.

extension GlobeView
{
    /// Returns the local time zone abbreviation (a three-letter indicator, not a set of words).
    /// - Returns: The local time zone identifier if found, nil if not found.
    func GetLocalTimeZoneID() -> String?
    {
        let TZID = TimeZone.current.identifier
        for (Abbreviation, Wordy) in TimeZone.abbreviationDictionary
        {
            if Wordy == TZID
            {
                return Abbreviation
            }
        }
        return nil
    }
    
    /// Called periodically to update the rotation of the Earth. Regardless of the frequency of
    /// being called, the Earth will always be updated to the correct position when called. However,
    /// if this function is called too infrequently, the Earth will show jerky motion as it rotates.
    /// - Note: When compiled in #DEBUG mode, code is included for debugging time functionality but
    ///         only when the proper settings are enabled.
    @objc func UpdateEarthView()
    {
        let Now = Date()
        let TZ = TimeZone(abbreviation: "UTC")
        var Cal = Calendar(identifier: .gregorian)
        Cal.timeZone = TZ!
        let Hour = Cal.component(.hour, from: Now)
        let Minute = Cal.component(.minute, from: Now)
        let Second = Cal.component(.second, from: Now)
        let ElapsedSeconds = Second + (Minute * 60) + (Hour * 60 * 60)
        let Percent = Double(ElapsedSeconds) / Double(Date.SecondsIn(.Day))
        
        if PreviousPrettyPercent == nil
        {
            PreviousPrettyPercent = 0.0
        }
        else
        {
            PreviousPrettyPercent = PrettyPercent
        }
        PrettyPercent = Double(Int(Percent * 1000.0)) / 1000.0
        
        #if DEBUG
        if Settings.GetBool(.Debug_EnableClockControl)
        {
            if Settings.EnumIs(.Globe, .Debug_ClockDebugMap, EnumType: Debug_MapTypes.self)
            {
                if Settings.GetBool(.Debug_ClockActionFreeze)
                {
                    if let Previous = PreviousPrettyPercent
                    {
                        PrettyPercent = Previous
                    }
                    else
                    {
                        PrettyPercent = 0.0
                    }
                }
                if Settings.GetBool(.Debug_ClockActionFreezeAtTime)
                {
                    let FreezeTime = Settings.GetDate(.Debug_ClockActionFreezeTime, Date())
                    if FreezeTime.IsOnOrLater(Than: Date())
                    {
                        if let Previous = PreviousPrettyPercent
                        {
                            PrettyPercent = Previous
                        }
                        else
                        {
                            PrettyPercent = 0.0
                        }
                    }
                }
                if Settings.GetBool(.Debug_ClockActionSetClockAngle)
                {
                    let Angle = Settings.GetDouble(.Debug_ClockActionClockAngle)
                    PrettyPercent = Angle / 360.0
                }
                if Settings.GetBool(.Debug_ClockUseTimeMultiplier)
                {
                    
                }
            }
        }
        #endif
        
        if !DecoupleClock
        {
            UpdateEarth(With: PrettyPercent)
        }
    }
    
    /// Rotate the Earth by one second (time) worth of ratation.
    @objc func RotateEarthOneSecond()
    {
        //let OneSecondRotationDegrees: Double = 360.0 / 86400.0
    }
    
    /// Rotate the Earth such that the passed latitude, longitude point is closest to the viewer.
    /// - Note: Calling this function will rotate the Earth (and all ancillary nodes) as appropriate and also
    ///         decouple the view timer so the Earth will not rotate. To resume normal rotation, call
    ///         `ResetEarthRotation`.
    /// - Parameter Latitude: The latitude to rotate the earth to.
    /// - Parameter Longitude: The longitude to rotate the earth to.
    /// - Parameter ChangeNodeOpacity: If true, the opacity of Earth nodes is reduced. If true, opacity is
    ///                                reset.
    func RotateEarthTo(Latitude: Double, Longitude: Double, ChangeNodeOpacity: Bool = false)
    {
        ResetCamera()
        if ChangeNodeOpacity
        {
            PushNodeOpacities(To: 0.5)
        }
        DecoupleClock = true
        let LongitudeRadians = Longitude.Radians
        let LatitudeRadians = Latitude.Radians
        let Rotate = SCNAction.rotateTo(x: 0.0,
                                        y: CGFloat(-LongitudeRadians),
                                        z: 0.0,
                                        duration: Defaults.EarthRotationDuration.rawValue,
                                        usesShortestUnitArc: true)
        EarthNode?.runAction(Rotate)
        SeaNode?.runAction(Rotate)
        for (_, Layer) in StencilLayers
        {
            Layer.runAction(Rotate)
        }
        
        let SysRotate = SCNAction.rotateTo(x: CGFloat(LatitudeRadians),
                                           y: 0.0,
                                           z: 0.0,
                                           duration: Defaults.EarthRotationDuration.rawValue,
                                           usesShortestUnitArc: true)
        HourNode?.runAction(SysRotate)
        SystemNode?.runAction(SysRotate)
    }
    
    /// Reset Earth rotation. Re-engages the clock with the Earth. Rotates the Earth to the position indicated
    /// by the current time and solar inclination.
    func ResetEarthRotation()
    {
        PopNodeOpacities()
        DecoupleClock = false
        let Declination = Sun.Declination(For: Date())
        let RotateSystem = SCNAction.rotateTo(x: CGFloat(Declination.Radians),
                                              y: 0.0,
                                              z: 0.0,
                                              duration: Defaults.EarthRotationDuration.rawValue,
                                              usesShortestUnitArc: true)
        HourNode?.runAction(RotateSystem)
        UpdateEarth(With: PrettyPercent)
    }
    
    /// Update the rotation of the Earth.
    /// - Note: The rotation must be called with `usesShortestUnitArc` set to `true` or every midnight
    ///         UTC, the Earth will spin backwards by 360°.
    /// - Parameter With: The percent time of day it is. Determines the rotation position of the Earth
    ///                   and supporting 3D nodes.
    func UpdateEarth(With Percent: Double)
    {
        let Degrees = 180.0 - (360.0 * Percent)
        let Radians = Degrees.Radians
        let Rotate = SCNAction.rotateTo(x: 0.0,
                                        y: CGFloat(-Radians),
                                        z: 0.0,
                                        duration: Defaults.EarthRotationDuration.rawValue,
                                        usesShortestUnitArc: true)
        EarthNode?.runAction(Rotate)
        SeaNode?.runAction(Rotate)
        let CurrentHourType = Settings.GetEnum(ForKey: .HourType, EnumType: HourTypes.self,
                                               Default: .None)
        switch CurrentHourType
        {
            case .RelativeToLocation:
                HourNode?.runAction(Rotate)
                UpdateHourLongitudes(Percent)
                
            case .WallClock:
                HourNode?.runAction(Rotate)

            default:
                break
        }
        let Declination = Sun.Declination(For: Date())
        let DeclRotate = SCNAction.rotateTo(x: CGFloat(Declination.Radians),
                                           y: 0.0,
                                           z: 0.0,
                                           duration: Defaults.EarthRotationDuration.rawValue,
                                           usesShortestUnitArc: true)
        SystemNode?.runAction(DeclRotate)
    }
    
    /// Push current node opacities and assign the new value.
    /// - Parameter To: The new opacity for nodes.
    func PushNodeOpacities(To NewValue: Double)
    {
        if let Children = EarthNode?.childNodes
        {
            for Child in Children
            {
                if let ActualChild = Child as? SCNNode2
                {
                    if let ChildName = ActualChild.name
                    {
                        let SkipList = [GlobeNodeNames.HomeNode.rawValue, GlobeNodeNames.MouseIndicator.rawValue]
                        if SkipList.contains(ChildName)
                        {
                            continue
                        }
                    }
                    ActualChild.PushOpacity(0.5, Animate: true)
                }
            }
        }
        if let HourChildren = HourNode?.childNodes
        {
            for HChild in HourChildren
            {
                if let ActualHChild = HChild as? SCNNode2
                {
                    ActualHChild.PushOpacity(0.5, Animate: true)
                }
            }
        }
    }
    
    /// Pop the old node opacity and restore it to the associated node.
    /// - Parameter IfEmpty: If the node's opacity stack is empty, this is the value that will be used for
    ///                      the opacity. Defaults to `1.0`.
    func PopNodeOpacities(_ IfEmpty: Double = 1.0)
    {
        if let Children = EarthNode?.childNodes
        {
            for Child in Children
            {
                if let ActualChild = Child as? SCNNode2
                {
                    ActualChild.PopOpacity(1.0, Animate: true)
                }
            }
        }
        if let HourChildren = HourNode?.childNodes
        {
            for HChild in HourChildren
            {
                if let ActualHChild = HChild as? SCNNode2
                {
                    ActualHChild.PopOpacity(1.0, Animate: true)
                }
            }
        }
    }
    
    /// Move the globe to the specified location.
    /// - Parameter Latitude: The latitude of the location to view.
    /// - Parameter Longitude: The longitude of the location to view.
    /// - Parameter UpdateOpacity: Determines how opacity of Earth nodes is calculated.
    func MoveMapTo(Latitude: Double, Longitude: Double, UpdateOpacity: Bool)
    {
        RotateEarthTo(Latitude: Latitude, Longitude: Longitude, ChangeNodeOpacity: UpdateOpacity)
    }
    
    /// Move the globe back to the normal location.
    func LockMapToTimer()
    {
        ResetEarthRotation()
    }
}
