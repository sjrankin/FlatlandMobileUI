//
//  +MainSettingsHandler.swift
//  Flatland
//
//  Created by Stuart Rankin on 9/18/20.
//  Copyright © 2020 - 2021 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

extension MainController: SettingChangedProtocol
{
    // MARK: - Setting changed handler
    
    func SubscriberID() -> UUID
    {
        return ClassID
    }
    
    /// Handle changes that affect Flatland overall or that need to take place at a main program level. Other
    /// changes may be handled lower in the code.
    /// - Parameter Setting: The setting that changed.
    /// - Parameter OldValue: The value of the setting before it was changed. May be nil.
    /// - Parameter NewValue: The new value of the setting. May be nil.
    func SettingChanged(Setting: SettingKeys, OldValue: Any?, NewValue: Any?)
    {
        switch Setting
        {
            case .MapType:
                let NewMap = Settings.GetEnum(ForKey: .MapType, EnumType: MapTypes.self, Default: .Simple)
                let MapViewType = Settings.GetEnum(ForKey: .ViewType, EnumType: ViewTypes.self, Default: .FlatNorthCenter)
                Main3DView.play(self)
                let (Earth, Sea) = Main3DView.MakeMaps(NewMap)
                if Sea != nil
                {
                    Main3DView.SetEarthMap()
                }
                else
                {
                    Main3DView.ChangeEarthBaseMap(To: Earth)
                }
                if Settings.GetBool(.EnableEarthquakes)
                {
                    Main3DView.ClearEarthquakes()
                    Main3DView.PlotEarthquakes()
                }
                /*
                switch MapViewType
                {
                    case .Globe3D:
                        Main3DView.play(self)
                        //Main2DView.pause(self)
                        //Rect2DView.pause(self)
                        #if false
                        if MapManager.IsSatelliteMap(NewMap)
                        {
                            let Earlier = Date().HoursAgo(36)
                            let Maps = EarthData.MakeSatelliteMapDefinitions()
                            let Earth = EarthData()
                            Earth.MainDelegate = self
                            Earth.Delegate = self
                            Debug.Print("Calling LoadMap in \(#function)")
                            if let SatMapData = EarthData.MapFromMaps(For: NewMap, From: Maps)
                            {
                                Earth.LoadMap(SatMapData, For: Earlier, Completed: EarthMapReceived)
                            }
                        }
                        else
                        {
                            let (Earth, Sea) = Main3DView.MakeMaps(NewMap)
                            if Sea != nil
                            {
                                Main3DView.SetEarthMap()
                            }
                            else
                            {
                                Main3DView.ChangeEarthBaseMap(To: Earth)
                            }
                            if Settings.GetBool(.EnableEarthquakes)
                            {
                                Main3DView.ClearEarthquakes()
                                Main3DView.PlotEarthquakes()
                            }
                        }
                        #else
                        let (Earth, Sea) = Main3DView.MakeMaps(NewMap)
                        if Sea != nil
                        {
                            Main3DView.SetEarthMap()
                        }
                        else
                        {
                            Main3DView.ChangeEarthBaseMap(To: Earth)
                        }
                        if Settings.GetBool(.EnableEarthquakes)
                        {
                            Main3DView.ClearEarthquakes()
                            Main3DView.PlotEarthquakes()
                        }
                        #endif
                        
                    case .FlatNorthCenter, .FlatSouthCenter:
                        #if true
                        break
                        #else
                        Main3DView.pause(self)
                        Main2DView.play(self)
                        Rect2DView.pause(self)
                        if let FlatImage = MapManager.ImageFor(MapType: NewMap, ViewType: MapViewType)
                        {
                            Main2DView.ApplyNewMap(FlatImage)
                            Main2DView.PlotEarthquakes(LatestEarthquakes, Replot: true)
                        }
                        else
                        {
                            Debug.Print("MapManager.ImageFor(\(NewMap), \(MapViewType)) returned nil for image in \(#function)")
                        }
                        #endif
                        
                    case .Rectangular:
                        #if true
                        Main3DView.pause(self)
                        #else
                        Main2DView.pause(self)
                        Rect2DView.play(self)
                        if let FlatImage = MapManager.ImageFor(MapType: NewMap, ViewType: MapViewType)
                        {
                            Rect2DView.ApplyNewMap(FlatImage)
                            Rect2DView.PlotEarthquakes(LatestEarthquakes, Replot: true)
                        }
                        else
                        {
                            Debug.Print("MapManager.ImageFor(\(NewMap), \(MapViewType)) returned nil for image in \(#function)")
                        }
                        #endif
                        
                    default:
                        break
                }
                 */
                
            case .ViewType:
                if let New = NewValue as? ViewTypes
                {
                    var IsFlat = false
                    switch New
                    {
                        case .FlatNorthCenter, .FlatSouthCenter:
                            IsFlat = true
                            //Main2DView.UpdateEarthView()
                            //Main2DView.UpdateGrid()
                            
                        case .Rectangular:
                            IsFlat = true
                            
                        case .CubicWorld:
                            Main3DView.SetEarthMap()
                            IsFlat = false
                            
                        case .Globe3D:
                            IsFlat = false
                            Main3DView.SetEarthMap()
                            if Settings.GetBool(.EnableEarthquakes)
                            {
                                Main3DView.PlotEarthquakes()
                            }
                            MainTimeLabelTop.isHidden = false
                            MainTimeLabelBottom.isHidden = true
                    }
                    //SetFlatMode(IsFlat)
                }
                
            case .SunType:
                UpdateSunLocations()
                
            case .EnableEarthquakes:
                if Settings.GetBool(.EnableEarthquakes)
                {
                    let FetchInterval = Settings.GetDouble(.EarthquakeFetchInterval, 60.0 * 5.0)
                    Earthquakes?.GetEarthquakes(Every: FetchInterval)
                    switch Settings.GetEnum(ForKey: .ViewType, EnumType: ViewTypes.self, Default: .Globe3D)
                    {
                        case .Globe3D:
                            Main3DView.ClearEarthquakes()
                            Main3DView.PlotEarthquakes()
                            Main3DView.ApplyAllStencils(Caller: ".EnableEarthquakes")
                            
                        case .FlatNorthCenter, .FlatSouthCenter:
                            //Main2DView.Remove2DEarthquakes()
                            //Main2DView.Plot2DEarthquakes(PreviousEarthquakes)
                            break
                            
                        case .Rectangular:
                            //Rect2DView.Remove2DEarthquakes()
                            //Rect2DView.Plot2DEarthquakes(PreviousEarthquakes)
                            break
                            
                        default:
                            break
                    }
                }
                else
                {
                    Earthquakes?.StopReceivingEarthquakes()
                    Main3DView.ClearEarthquakes()
                    Main3DView.ApplyAllStencils(Caller: ".EnableEarthquakes")
                    //Main2DView.Remove2DEarthquakes()
                    //Rect2DView.Remove2DEarthquakes()
                }
                
            case .EarthquakeFetchInterval:
                let FetchInterval = Settings.GetDouble(.EarthquakeFetchInterval, 60.0 * 5.0)
                Earthquakes?.StopReceivingEarthquakes()
                Earthquakes?.GetEarthquakes(Every: FetchInterval)
                
            case .UserHomeLongitude, .UserHomeLatitude:
//                (view.window?.windowController as? MainWindow)!.HourSegment.setEnabled(Settings.HaveLocalLocation(), forSegment: 3)
  break
            
            case .BackgroundColor3D:
                #if true
                break
                #else
                let NewBackgroundColor = Settings.GetColor(.BackgroundColor3D, UIColor.black)
                BackgroundView.layer?.backgroundColor = NewBackgroundColor.cgColor
                let Opposite = Utility.OppositeColor(From: NewBackgroundColor)
                UpdateScreenText(With: Opposite)
                #endif
                /*
            case .WorldIsLocked:
                //Just need to update user interface elements.
                //SetWorldLock(Settings.GetBool(.WorldIsLocked))
                */
            default:
                return
        }
        
        Debug.Print("Setting \(Setting) handled in MainController")
    }
}
