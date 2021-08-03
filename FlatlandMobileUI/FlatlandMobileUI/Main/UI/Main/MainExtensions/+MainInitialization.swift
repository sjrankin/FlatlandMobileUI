//
//  +MainInitialization.swift
//  Flatland
//
//  Created by Stuart Rankin on 9/18/20.
//  Copyright © 2020 - 2021 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

extension MainController
{
    /// Get initialization data from the run-time environment.
    func InitializationFromEnvironment()
    {
    }
    
    /// Initialize program data.
    func ProgramInitialization()
    {
        let UNESCO = DBIF.UNESCOSites
        NodeTables.Initialize(Unesco: UNESCO)
        //PrimaryMapList = ActualMapIO.LoadMapList()
        FontHelper.Initialize()
        Main3DView.PlotCities()
    }
 
    /// Load the current view with the initial map.
    /// - Warning: If the initial map cannot be found and the backup-standard map cannot be found, a
    ///            fatal error is thrown.
    func LoadInitialMaps()
    {
        let VType = Settings.GetEnum(ForKey: .ViewType, EnumType: ViewTypes.self, Default: .FlatSouthCenter)
        let MapValue = Settings.GetEnum(ForKey: .MapType, EnumType: MapTypes.self, Default: .Simple)
        var IsFlat = false
        
        switch VType
        {
            case .Globe3D:
                IsFlat = false
                if let Category = MapManager.CategoryFor(Map: MapValue)
                {
                    Debug.Print("Initial map: Category: \(Category.rawValue), EnableNASATiles=\(Settings.GetBool(.EnableNASATiles))")
                    #if false
                    if Category == .Satellite && Settings.GetBool(.EnableNASATiles)
                    {
                        //Start loading the map here.
                        let Earlier = Date().HoursAgo(36)
                        let Maps = EarthData.MakeSatelliteMapDefinitions()
                        let Earth = EarthData()
                        Earth.MainDelegate = self
                        Earth.Delegate = self
                        Debug.Print("Calling LoadMap in \(#function)")
                        if let SatMapData = EarthData.MapFromMaps(For: MapValue, From: Maps)
                        {
                            Earth.LoadMap(SatMapData, For: Earlier, Completed: EarthMapReceived)
                        }
                        SetFlatMode(false)
                        return
                    }
                    #endif
                }
                
            case .FlatNorthCenter, .FlatSouthCenter, .Rectangular:
                #if true
                return
                #else
                IsFlat = true
                if let InitialImage = MapManager.ImageFor(MapType: MapValue, ViewType: VType)
                {
                    Main2DView.SetEarthMap(InitialImage)
                }
                else
                {
                    if let StandardMap = MapManager.ImageFor(MapType: .Standard, ViewType: VType)
                    {
                        Main2DView.SetEarthMap(StandardMap)
                        Settings.SetEnum(.Standard, EnumType: MapTypes.self, ForKey: .MapType)
                    }
                    else
                    {
                        Debug.FatalError("Unable to get specified and standard maps for view type \(VType).")
                    }
                }
                #endif
                
            case .CubicWorld:
                IsFlat = false
                return
        }
        
        InitializeUpdateTimer()
        Started = true
        //let IsFlat = [ViewTypes.FlatNorthCenter, ViewTypes.FlatSouthCenter, ViewTypes.Rectangular].contains(VType)
        //SetFlatMode(IsFlat)
    }
    
    /// Initialized Flatland as a whole.
    func InitializeFlatland()
    {
        LoadInitialMaps()
        InitializeUpdateTimer()
    }
    
    /// Start the update timer.
    func InitializeUpdateTimer()
    {
        let _ = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true)
            {
            [weak self] _ in
            let LabelType = Settings.GetEnum(ForKey: .TimeLabel, EnumType: TimeLabels.self, Default: .None)
            let Now = self?.GetUTC()
            let Formatter = DateFormatter()
            Formatter.dateFormat = "HH:mm:ss"
            var TimeZoneAbbreviation = ""
            if LabelType == .UTC
            {
                TimeZoneAbbreviation = "UTC"
            }
            else
            {
                TimeZoneAbbreviation = self?.GetLocalTimeZoneID() ?? "UTC"
            }
            let TZ = TimeZone(abbreviation: TimeZoneAbbreviation)
            Formatter.timeZone = TZ
            var Final = Formatter.string(from: Now!)
            let Parts = Final.split(separator: ":")
            if !Settings.GetBool(.TimeLabelSeconds)
            {
                Final = "\(Parts[0]):\(Parts[1])"
            }
            let FinalText = Final + " " + TimeZoneAbbreviation
            //let IsNewHour = false
            if ((self?.PreviousHourValue.isEmpty) != nil)
            {
                self?.PreviousHourValue = String(Parts[0])
            }
            else
            {
                if self?.PreviousHourValue != String(Parts[0])
                {
                    //IsNewHour = true
                    self?.PreviousHourValue = String(Parts[0])
                }
            }
            if LabelType == .None
            {
                self?.MainTimeLabelTop.text = ""
                self?.MainTimeLabelBottom.text = ""
            }
            else
            {
                self?.MainTimeLabelTop.text = FinalText
                self?.MainTimeLabelBottom.text = FinalText
            }
            
            let CurrentSeconds = Now!.timeIntervalSince1970
            var ElapsedSeconds = 0
            if CurrentSeconds != self?.OldSeconds
            {
                self?.OldSeconds = CurrentSeconds
                var Cal = Calendar(identifier: .gregorian)
                //Use UTC time zone for rotational calculations, not the local time zone (if the user
                //is using the local zone). All calculations are based on UTC and so if local time zones
                //are used, the map wil be rotated incorrectly.
                Cal.timeZone = TimeZone(abbreviation: "UTC")!
                let Hour = Cal.component(.hour, from: Now!)
                let Minute = Cal.component(.minute, from: Now!)
                let Second = Cal.component(.second, from: Now!)
                ElapsedSeconds = Second + (Minute * 60) + (Hour * 60 * 60)
                let Percent = Double(ElapsedSeconds) / Double(24 * 60 * 60)
                let PrettyPercent = Double(Int(Percent * 1000.0)) / 1000.0
                //self?.Main2DView.RotateImageTo(PrettyPercent)
                if Settings.GetEnum(ForKey: .HourType, EnumType: HourTypes.self, Default: .WallClock) == .WallClock
                {
                    self?.Main3DView?.UpdateWallClockHours(NewTime: Now!)
                 //   self?.Main2DView?.UpdateWallClockHours(NewTime: Now!)
                }
                if Settings.GetBool(.EnableHourEvent)
                {
                    if Minute == 0 && !(self?.HourSoundTriggered)!
                    {
                        self?.Main3DView.FlashAllHours(Count: 3)
             //           self?.Main2DView.FlashAllHours(Count: 3)
                        self?.HourSoundTriggered = true
                        SoundManager.Play(ForEvent: .HourChime)
                    }
                }
                if Minute != 0
                {
                    self?.HourSoundTriggered = false
                }
            }
        }
        #if DEBUG
        StartDebugCount = Date.timeIntervalSinceReferenceDate
        let DebugTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(DebugTimerHandler), userInfo: nil, repeats: true)
        RunLoop.current.add(DebugTimer, forMode: .common)
        DebugTimerHandler()
        #endif
    }
    
    /// Initialize asynchronous data helpers.
    func AsynchronousInitialization()
    {
        Earthquakes = USGS()
        Earthquakes?.Delegate = self
        if Settings.GetBool(.EnableEarthquakes)
        {
            let FetchInterval = Settings.GetDouble(.EarthquakeFetchInterval, 60.0 * 5.0)
            Earthquakes?.GetEarthquakes(Every: FetchInterval)
            CachedQuakes = Settings.GetCachedEarthquakes()
            PlotCachedQuakes(CachedQuakes)
        }
        #if false
        if Settings.GetBool(.PreloadNASATiles) && Settings.GetBool(.EnableNASATiles)
        {
            let Earlier = Date().HoursAgo(36)
            let Maps = EarthData.MakeSatelliteMapDefinitions()
            let Earth = EarthData()
            Earth.MainDelegate = self
            Earth.Delegate = self
            Debug.Print(">>>> **** Calling LoadMap")
            let MapValue = Settings.GetEnum(ForKey: .MapType, EnumType: MapTypes.self, Default: .Simple)
            if let SatMapData = EarthData.MapFromMaps(For: MapValue, From: Maps)
            {
                Earth.LoadMap(SatMapData, For: Earlier, Completed: EarthMapReceived)
            }
        }
        #endif
    }
    
    /// Plot cached quakes from the last run. This is used to show the user something rather than
    /// nothing when Flatland first starts.
    /// - Parameter Quakes: Set of earthquakes to plot.
    func PlotCachedQuakes(_ Quakes: [Earthquake])
    {
        if Quakes.count < 1
        {
            return
        }
        Main3DView.NewEarthquakeList(Quakes, FromCache: true)
    }
    
    /// Initialize the user interface.
    func InterfaceInitialization()
    {
        Main3DView.layer.zPosition = CGFloat(LayerZLevels.InactiveLayer.rawValue)
        Main3DView.MainDelegate = self
        #if false
        let DoubleClickRecognizer = NSClickGestureRecognizer(target: self,
                                                             action: #selector(HandleDoubleClick))
        DoubleClickRecognizer.numberOfClicksRequired = 2
        self.view.addGestureRecognizer(DoubleClickRecognizer)
        #endif
        #if true
        MainTimeLabelTop.isHidden = false
        MainTimeLabelBottom.isHidden = true
        Main3DView.play(self)
        #else
        Settings.QueryEnum(.ViewType, EnumType: ViewTypes.self)
        {
            [weak self] Value in
            switch Value
            {
                case .Globe3D, .CubicWorld:
                    Main2DView.SunVisibility(IsShowing: false)
                    MainTimeLabelTop.isHidden = false
                    MainTimeLabelBottom.isHidden = true
                    Main3DView.play(self)
                    Main2DView.pause(self)
                    Rect2DView.pause(self)
                    
                case .FlatNorthCenter, .FlatSouthCenter:
                    Main2DView.SunVisibility(IsShowing: true)
                    MainTimeLabelTop.isHidden = false
                    MainTimeLabelBottom.isHidden = true
                    let MapValue = Settings.GetEnum(ForKey: .MapType, EnumType: MapTypes.self, Default: .Simple)
                    if let MapImage = MapManager.ImageFor(MapType: MapValue, ViewType: .FlatNorthCenter)
                    {
                        Main2DView.SetEarthMap(MapImage)
                    }
                    Main3DView.pause(self)
                    Main2DView.play(self)
                    Rect2DView.pause(self)
                    Main2DView.UpdateEarthView()
                    Main2DView.UpdateGrid()
                    
                case .Rectangular:
                    //Rect2DView.SunVisibility(IsShowing: true)
                    MainTimeLabelTop.isHidden = true
                    MainTimeLabelBottom.isHidden = false
                    let MapValue = Settings.GetEnum(ForKey: .MapType, EnumType: MapTypes.self, Default: .Simple)
                    if let MapImage = MapManager.ImageFor(MapType: MapValue, ViewType: .Rectangular)
                    {
                        Rect2DView.SetEarthMap(MapImage)
                    }
                    Main3DView.pause(self)
                    Main2DView.pause(self)
                    Rect2DView.play(self)
                    
                default:
                    break
            }
        }
        #endif
        
        MainTimeLabelBottom.layer.zPosition = CGFloat(LayerZLevels.TimeLabels.rawValue)
        MainTimeLabelBottom.font = UIFont.monospacedSystemFont(ofSize: 30.0, weight: .semibold)
        MainTimeLabelTop.layer.zPosition = CGFloat(LayerZLevels.TimeLabels.rawValue)
        MainTimeLabelTop.font = UIFont.monospacedSystemFont(ofSize: 30.0, weight: .semibold)

        //let Opposite = Utility.OppositeColor(From: NewBackgroundColor)
        //UpdateScreenText(With: Opposite)
    }
}
