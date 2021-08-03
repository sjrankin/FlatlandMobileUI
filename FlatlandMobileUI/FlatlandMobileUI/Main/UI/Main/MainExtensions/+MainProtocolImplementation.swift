//
//  +MainProtocolImplementation.swift
//  Flatland
//
//  Created by Stuart Rankin on 9/18/20.
//  Copyright © 2020 - 2021 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit
import SceneKit

extension MainController: MainProtocol
{
    // MARK: - Main protocol functions
    
    /// Refresh called from someone who changed something. Provides alternative method for setting
    /// changes.
    /// - Parameter From: The caller's label.
    func Refresh(_ From: String)
    {
    }
    
    /*
    /// Handle auxiliary window closing events.
    /// - Parameter WhatClosed: Indicates which window closed.
    func DidClose(_ WhatClosed: String)
    {
        switch WhatClosed
        {
            case "MainSettings":
                MainSettingsDelegate = nil
                SettingsWindowOpen = false
                
            default:
                break
        }
    }
     */
    
    /// Insert debug earthquake at the specified location.
    func InsertEarthquake(Latitude: Double, Longitude: Double, Magnitude: Double)
    {
        #if DEBUG
        Earthquakes?.InsertDebugEarthquake(Latitude: Latitude, Longitude: Longitude, Magnitude: Magnitude)
        #endif
    }
    
    /// Insert debug earthquake at a random location.
    func InsertEarthquake(Magnitude: Double)
    {
        #if DEBUG
        let Latitude = Double.random(in: -90.0 ... 90.0)
        let Longitude = Double.random(in: -180.0 ... 180.0)
        Earthquakes?.InsertDebugEarthquake(Latitude: Latitude, Longitude: Longitude, Magnitude: Magnitude)
        #endif
    }
    
    /// Force fetch earthquakes.
    func ForceFetchEarthquakes()
    {
        #if DEBUG
        Earthquakes?.ForceFetch()
        #endif
    }
    
    /// Insert a cluster of earthquakes for debugging.
    /// - Parameter Count: Number of earthquakes to insert.
    func InsertEarthquakeCluster(_ Count: Int)
    {
        #if DEBUG
        Earthquakes?.InsertEarthquakeCluster(Count)
        #endif
    }
    
    /// Update the view type in the controls.
    func UpdateViewType()
    {
    }
    
    /// Obsolete.
    func ItemViewerClosed()
    {
    }
    
    /*
    /// Returns the main program's app delegate.
    /// - Returns: Main program app delegate.
    func GetAppDelegate() -> AppDelegate
    {
        return MainApp
    }
    
    /// Called when a child window is closed.
    /// - Parameter ChildWindow: The child window that was closed.
    func ChildWindowClosed(_ ChildWindow: ChildWindows)
    {
        switch ChildWindow
        {
            case .DebuggerWindow:
                DebuggerOpen = false
                
            case .PreferenceWindow:
                PreferencesWindowOpen = false
                
            case .SettingsWindow:
                SettingsWindowOpen = false
                
            case .LiveStatusWindow:
                LiveStatusWindowOpen = false
        }
    }
    
    /// Display the geographic location under the mouse.
    func MouseAtLocation(Latitude: Double, Longitude: Double, Caller: String)
    {
        #if false
        ShowMouseLocation(Latitude: Latitude, Longitude: Longitude, Caller: Caller)
        #endif
    }
    
    /// Show or hide the mouse location.
    /// - Parameter Show: Determines whether the mouse location view is visible or hidden.
    func ShowMouseLocationView(_ Show: Bool)
    {
        #if false
        SetMouseLocationVisibility(Visible: Show)
        #endif
    }
    */
    /// Returns the current earthquake class.
    func GetEarthquakeController() -> USGS?
    {
        return Earthquakes
    }
    
    /// Returns the current set of earthquakes. If no earthquakes have yet been read from the USGS,
    /// the set of cached quakes are returned.
    /// - Returns: The most recent set of downloaded earthquakes from the USGS in the instantiation, or
    ///            if nothing has yet been downloaded, the set of cached earthquakes.
    func GetEarthquakes() -> [Earthquake]
    {
        if LatestEarthquakes.isEmpty
        {
            return CachedQuakes
        }
        else
        {
            return LatestEarthquakes
        }
    }
    
    /// Returns the set of most recently read earthquakes.
    /// - Returns: Array of the most recently read set of earthquakes in the current instantiation. If
    ///            no quakes have been received, an empty array is returned.
    func GetCurrentEarthquakes() -> [Earthquake]
    {
        return LatestEarthquakes
    }
    /*
    /// Sends the passed text to the simple status display.
    /// - Parameter Text: The text to display.
    func SetStatusText(_ Text: String)
    {
        StatusBar.ShowStatusText(Text)
    }
    
    /// Sends the passed text to the simple status display.
    /// - Parameter Text: The text to display.
    /// - Parameter HideAfter: The duration in seconds for the amount of time to hide the text after
    ///                        it is displayed.
    func SetDisappearingStatusText(_ Text: String, HideAfter: Double)
    {
        StatusBar.ShowStatusText(Text, For: HideAfter)
    }
    
    /// Clears the status display of text.
    func ClearStatusText()
    {
        StatusBar.ShowStatusText("")
    }
    
    /// Push a message to the status bar. It will show up for `PeristFor` seconds when no other
    /// messages are being shown.
    /// - Parameter Text: The text to show.
    /// - Parameter PersistFor: How long to persist the message.
    func PushStatusMessage(_ Text: String, PersistFor: Double)
    {
        StatusBar.PushMessage(Text, Duration: PersistFor, ID: UUID())
    }
    
    /// Remove any pushed messages.
    func RemovePushStatusMessage()
    {
        StatusBar.RemovePushedMessage()
    }
    */
    /// Force an exit of Flatland.
    /// - Notes: [Terminal application](https://developer.apple.com/forums/thread/106825)
    func ExitProgram()
    {
        /*
        for Running in NSWorkspace.shared.runningApplications
        {
            if Running.localizedName == "Flatland"
            {
                Running.terminate()
            }
        }
         */
    }
    
    /// Reset settings here.
    func ResetSettings()
    {
        
    }
    
    /// Returns the connected-to-internet status.
    /// - Returns: True if the system is connected to the internet, false if not.
    func ConnectedToInternet() -> Bool
    {
        return CurrentlyConnected
    }
    
    func GetWorldHeritageSites() -> [WorldHeritageSite]
    {
        return GetAllWorldHeritageSites()
    }
    
    /// Move the 3D globe (only valid for 3D globes) to the specified location.
    /// - Parameter Latitude: The latitude of the location.
    /// - Parameter Longiutde: The longitude of the location.
    /// - Parameter UdpateOpacity: If true, opacity is updated. If false, no changes are made.
    func MoveMapTo(Latitude: Double, Longitude: Double, UpdateOpacity: Bool)
    {
        if Settings.GetEnum(ForKey: .ViewType, EnumType: ViewTypes.self, Default: .Globe3D) == .Globe3D
        {
            Main3DView.MoveMapTo(Latitude: Latitude, Longitude: Longitude, UpdateOpacity: UpdateOpacity)
        }
    }
    
    /// Lock the 3D globe to the time and reset its position.
    func LockMapToTimer()
    {
        if Settings.GetEnum(ForKey: .ViewType, EnumType: ViewTypes.self, Default: .Globe3D) == .Globe3D
        {
            Main3DView.LockMapToTimer()
        }
    }
    
    /// Set the euler angles for the node whose edit ID is passed.
    /// - Parameter EditID: The edit ID of the node to change.
    /// - Parameter Angles: New euler angles.
    func SetNodeEulerAngles(EditID: UUID, _ Angles: SCNVector3)
    {
        Main3DView.SetNodeEulerAngles(EditID: EditID, Angles)
    }
    
    /// Get the euler angles for the node whose edit ID is passed.
    /// - Parameter EditID: The edit ID of the node whose euler angles are returned.
    /// - Returns: Euler angles for the node whose edit ID is `EditID`, nil if not found.
    func GetNodeEulerAngles(EditID: UUID) -> SCNVector3?
    {
        return Main3DView.GetNodeEulerAngles(EditID: EditID)
    }
    
    /// Set the location of the node whose edit ID is passed. The node is moved by this call.
    /// - Parameter EditID: The edit ID of the node to change.
    /// - Parameter Latitude: The new latitude value for the node.
    /// - Parameter Longitude: The new longitude value for the node.
    func SetNodeLocation(EditID: UUID, _ Latitude: Double, _ Longitude: Double)
    {
        Main3DView.SetNodeLocation(EditID: EditID, Latitude, Longitude)
    }
    
    /// Get the location of the node whose edit ID is passed.
    /// - Parameter EditID: The edit ID of the node whose location is returned.
    /// - Returns: Tuple of the latitude and longitude of the node. Nil if not found.
    func GetNodeLocation(EditID: UUID) -> (Latitude: Double, Longitude: Double)?
    {
        return Main3DView.GetNodeLocation(EditID: EditID)
    }
    
    /// Given the main window the focus.
    func FocusWindow()
    {
        self.view.window?.makeKey()
    }
    
    func PointCamera(At Point: GeoPoint, Duration: Double)
    {
        Main3DView.PointCamera(At: Point, Duration: Duration)
    }
    
    func ResetCameraPosition()
    {
        Main3DView.ResetCameraPosition() 
    }
    
    func SetCameraOrientation(Pitch: Double, Yaw: Double, Roll: Double, ValuesAreRadians: Bool,
                              Duration: Double)
    {
        Main3DView.SetCameraOrientation(Pitch: Pitch, Yaw: Yaw, Roll: Roll,
                                        ValuesAreRadians: ValuesAreRadians,
                                        Duration: Duration)
    }
    
    func Get3DPointOfView() -> SCNNode?
    {
        return Main3DView.pointOfView
    }
    
    func GetUserPOIData() -> [POI2]?
    {
        return MainController.UserPOIs
    }
    
    func SetUserPOIData(_ POIData: [POI2])
    {
        
    }
    
    func GetAdditionalCityData() -> [City2]?
    {
        return CityManager.OtherCities
    }
    
    func SetAdditionalCityData(_ OtherCities: [City2])
    {
        
    }
    
    /*
    /// Unconditionally make the mouse visible.
    func MakeMouseVisible()
    {
        if Settings.GetBool(.HideMouseOverEarth)
        {
            #if false
            if !self.Main3DView.MouseIsVisible
            {
                self.Main3DView.MouseIsVisible = true
                NSCursor.unhide()
            }
            #endif
        }
    }
     */
    
    /// Rotate the camera without moving it.
    /// - Parameter Pitch: New pitch of the camera.
    /// - Parameter Yaw: New yaw of the camera.
    /// - Parameter Roll: New roll of the camera.
    /// - Parameter ValuesAreRadians: If true, the passed values are radians. If false, they are degrees.
    /// - Parameter Duration: Duration of the animation in seconds.
    func RotateCameraInPlace(Pitch X: Double, Yaw Y: Double, Roll Z: Double, ValuesAreRadians: Bool,
                             Duration: Double)
    {
        Main3DView.RotateCameraInPlace(Pitch: X, Yaw: Y, Roll: Z, ValuesAreRadians: ValuesAreRadians,
                                       Duration: Duration)
    }
    
    /// Move the camera to look at a specified point on the globe.
    /// - Parameter Location: Defines where to look.
    /// - Parameter Duration: Duration of the animation in seconds.
    func MoveCameraTo(_ Location: CameraLocations, Duration: Double)
    {
        var Where: GeoPoint!
        switch Location
        {
            case .Home:
                guard let HomeLat = Settings.GetSecureString(.UserHomeLatitude) else
                {
                    return
                }
                guard let HomeLon = Settings.GetSecureString(.UserHomeLongitude) else
                {
                    return
                }
                guard let ActualLat = Double(HomeLat) else
                {
                    return
                }
                guard let ActualLon = Double(HomeLon) else
                {
                    return
                }
                Where = GeoPoint(ActualLat, ActualLon)
                
            case .Noon:
                let Declination = Sun.Declination(For: Date()) * -1.0
                let Now = Date()
                let TZ = TimeZone(abbreviation: "UTC")
                var Cal = Calendar(identifier: .gregorian)
                Cal.timeZone = TZ!
                let Hour = Cal.component(.hour, from: Now)
                let Minute = Cal.component(.minute, from: Now)
                let Second = Cal.component(.second, from: Now)
                let ElapsedSeconds = Second + (Minute * 60) + (Hour * 60 * 60)
                let Percent = Double(ElapsedSeconds) / Double(Date.SecondsIn(.Day))
                let Degrees = 180.0 - (360.0 * Percent)
                Where = GeoPoint(Declination, Degrees)
                
            case .NorthPole:
                Where = GeoPoint(90.0, 0.0)
                
            case .SouthPole:
                Where = GeoPoint(-90.0, 0.0)
                
            case .L00:
                Where = GeoPoint(0.0, 0.0)
                
            case .L090:
                Where = GeoPoint(0.0, 90.0)
                
            case .L0180:
                Where = GeoPoint(0.0, 180.0)
                
            case .L0270:
                Where = GeoPoint(0.0, -90.0)
        }
        PointCamera(At: Where!, Duration: Duration)
    }
    
    /// Returns the time-stamp of the most recent earthquake download.
    /// - Returns: Date-time of the most recent earthquake download. If nil, no downloads have occurred
    ///            for the current instantiation.
    func GetLastEarthquakeDownload() -> Date?
    {
        return LastQuakeDownloadTime
    }
    
    /// Returns memory measurements.
    /// - Parameter Measurements: Pointer to array of memory measurements.
    func GetMemoryStatistics(Measurements: inout [Int64])
    {
        #if DEBUG
        objc_sync_enter(MemoryLock)
        defer{objc_sync_exit(MemoryLock)}
        Measurements = MemoryOverTime
        #else
        Measurements = [Int64]()
        #endif
    }
    
    /// Returns memory measurements.
    /// - Returns: Array of memory data.
    func GetMemoryStatistics() -> [Int64]
    {
        #if DEBUG
        objc_sync_enter(MemoryLock)
        defer{objc_sync_exit(MemoryLock)}
        return MemoryOverTime
        #else
        return [Int64]()
        #endif
    }
    
    /// Show the debug grid.
    func ShowDebugGrid()
    {
        //DebugTextGrid.isHidden = false
    }
    
    /// Hide the debug grid.
    func HideDebugGrid()
    {
        //DebugTextGrid.isHidden = true
    }
}
