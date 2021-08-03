//
//  +ChangedSettingsHandler.swift
//  Flatland
//
//  Created by Stuart Rankin on 9/21/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit
import SceneKit

extension GlobeView: SettingChangedProtocol
{
    // MARK: - Changed setting handling
    
    /// Required by the `SettingChangedProtocol`.
    /// - Returns: ID of the class.
    func SubscriberID() -> UUID
    {
        return ClassID
    }
    
    /// Handle changed setting notifications.
    /// - Parameter Setting: The setting that was changed.
    /// - Parameter OldValue: The previous value of the setting (may be nil).
    /// - Parameter NewValue: The new value of the setting (may be nil).
    func SettingChanged(Setting: SettingKeys, OldValue: Any?, NewValue: Any?)
    {
        switch Setting
        {
            case .HourType:
                let NewHourType = Settings.GetEnum(ForKey: .HourType, EnumType: HourTypes.self, Default: .None)
                if NewHourType == .WallClock && PreviousHourType != .WallClock
                {
                    ApplyAllStencils(Caller: "SettingChanged(.HourType) Wall Clock = true")
                }
                if NewHourType != .WallClock && PreviousHourType == .WallClock
                {
                    ApplyAllStencils(Caller: "SettingChanged(.HourType) Wall Clock = false")
                }
                UpdateHourLabels(With: NewHourType)
                
            case .UseHDRCamera:
                SetHDR()
                
            case .CityShapes:
                PlotCities()
                ApplyAllStencils(Caller: "SettingChanged(.CityShapes)")
                
            case .PopulationType:
                PlotCities()
                
            case .ShowHomeLocation:
                PlotCities()
                
            case .HomeColor:
                PlotCities()
                
            case .UserLocations:
                PlotCities()
                
            case .ShowUserLocations:
                PlotCities()
                
            case .HomeShape:
                PlotHomeLocation()
                
            case .PolarShape:
                PlotPolarShape()
                
            case .ShowWorldHeritageSites:
                ApplyAllStencils(Caller: "SettingChanged(.ShowWorldHeritageSites)")
                PlotWorldHeritageSites()
                
            case .WorldHeritageSiteType:
                ApplyAllStencils(Caller: "SettingChanged(.WorldHeritageSiteType)")
                PlotWorldHeritageSites()
                
            case .Show3DEquator, .Show3DTropics, .Show3DMinorGrid, .Show3DPolarCircles, .Show3DPrimeMeridians,
                 .MinorGrid3DGap, .Show3DGridLines:
                ApplyAllStencils(Caller: "SettingChanged(.{Multiple})")
                
            case .ShowMagnitudeBarCode:
                ApplyAllStencils(Caller: "SettingChanged(.ShowMagnitudeBarCode)")
                
            case .Script:
                PlotPolarShape()
                UpdateHours()
                
            case .HourColor:
                UpdateHours()
                
            case .ShowMoonLight:
                SetMoonlight(Show: Settings.GetBool(.ShowMoonLight))
                
            case .ShowPOIEmission:
                if Settings.GetEnum(ForKey: .ViewType, EnumType: ViewTypes.self, Default: .Globe3D) == .Globe3D
                {
                    PlotCities()
                }
                
            case .ShowBuiltInPOIs:
                if Settings.GetEnum(ForKey: .ViewType, EnumType: ViewTypes.self, Default: .Globe3D) == .Globe3D
                {
                    PlotCities()
                }
                
            case .EarthquakeStyles:
                ClearEarthquakes()
                PlotEarthquakes()
                
            case .RecentEarthquakeDefinition:
                ClearEarthquakes()
                PlotEarthquakes()
                
            case .EarthquakeTextures:
                ClearEarthquakes()
                PlotEarthquakes()
                
            case .EarthquakeColor:
                ClearEarthquakes()
                PlotEarthquakes()
                
            case .BaseEarthquakeColor:
                if Settings.GetBool(.EnableEarthquakes)
                {
                    if Settings.GetEnum(ForKey: .ViewType, EnumType: ViewTypes.self, Default: .Globe3D) == .Globe3D
                    {
                        ClearEarthquakes()
                        PlotEarthquakes()
                    }
                }
                
            case .HighlightRecentEarthquakes:
                if Settings.GetBool(.EnableEarthquakes)
                {
                    if Settings.GetEnum(ForKey: .ViewType, EnumType: ViewTypes.self, Default: .Globe3D) == .Globe3D
                    {
                        ClearEarthquakes()
                        PlotEarthquakes()
                    }
                }
                
            case .ColorDetermination:
                if Settings.GetBool(.EnableEarthquakes)
                {
                    if Settings.GetEnum(ForKey: .ViewType, EnumType: ViewTypes.self, Default: .Globe3D) == .Globe3D
                    {
                        ClearEarthquakes()
                        PlotEarthquakes()
                        if let InitialMap = InitialStenciledMap
                        {
                            ApplyEarthquakeStencils(InitialMap: InitialMap)
                        }
                        else
                        {
                            ApplyAllStencils(Caller: "SettingChanged(.ColorDetermination)")
                        }
                    }
                }
                
            case .EarthquakeShapes:
                if Settings.GetBool(.EnableEarthquakes)
                {
                    if Settings.GetEnum(ForKey: .ViewType, EnumType: ViewTypes.self, Default: .Globe3D) == .Globe3D
                    {
                        ClearEarthquakes()
                        PlotEarthquakes()
                    }
                }
                
            case .EarthquakeMagnitudeColors:
                if Settings.GetBool(.EnableEarthquakes)
                {
                    if Settings.GetEnum(ForKey: .ViewType, EnumType: ViewTypes.self, Default: .Globe3D) == .Globe3D
                    {
                        ClearEarthquakes()
                        PlotEarthquakes()
                        if let InitialMap = InitialStenciledMap
                        {
                            ApplyEarthquakeStencils(InitialMap: InitialMap)
                        }
                        else
                        {
                            ApplyAllStencils(Caller: "SettingChanged(.EarthquakeMagnitudeColors)")
                        }
                    }
                }
                
            case .UseAmbientLight:
                SetupLights()
                
            case .EarthquakeFontName:
                if Settings.GetBool(.EnableEarthquakes)
                {
                    if Settings.GetEnum(ForKey: .ViewType, EnumType: ViewTypes.self, Default: .Globe3D) == .Globe3D
                    {
                        ClearEarthquakes()
                        PlotEarthquakes()
                        if let InitialMap = InitialStenciledMap
                        {
                            ApplyEarthquakeStencils(InitialMap: InitialMap)
                        }
                        else
                        {
                            ApplyAllStencils(Caller: ".EarthquakeFontName")
                        }
                    }
                }
                
            case .EarthquakeMagnitudeViews:
                if Settings.GetBool(.EnableEarthquakes)
                {
                    if Settings.GetEnum(ForKey: .ViewType, EnumType: ViewTypes.self, Default: .Globe3D) == .Globe3D
                    {
                        ClearEarthquakes()
                        PlotEarthquakes()
                    }
                }
                
            case .CombinedEarthquakeColor:
                if Settings.GetBool(.EnableEarthquakes)
                {
                    if Settings.GetEnum(ForKey: .ViewType, EnumType: ViewTypes.self, Default: .Globe3D) == .Globe3D
                    {
                        ClearEarthquakes()
                        PlotEarthquakes()
                    }
                }
                
            case .CityFontName, .CityFontRelativeSize, .MagnitudeRelativeFontSize:
                PlotCities()
                ApplyAllStencils(Caller: "{.Multiple}")
                
            case .WorldCityColor, .AfricanCityColor, .AsianCityColor, .EuropeanCityColor,
                 .NorthAmericanCityColor, .SouthAmericanCityColor, .CapitalCityColor,
                 .CustomCityListColor, .CityNodesGlow, .PopulationColor:
                PlotCities()
                ApplyAllStencils(Caller: "City color changed")
                
            case .ShowCustomCities, .ShowAfricanCities, .ShowAsianCities,
                 .ShowEuropeanCities, .ShowNorthAmericanCities, .ShowSouthAmericanCities,
                 .ShowCapitalCities, .ShowWorldCities, .ShowCitiesByPopulation,
                 .PopulationRank, .PopulationRankIsMetro, .PopulationFilterValue,
                 .PopulationFilterGreater, .PopulationFilterType:
                PlotCities()
                ApplyAllStencils(Caller: "Show cities changed")
                
            case .CustomCityList:
                if Settings.GetBool(.ShowCustomCities)
                {
                    PlotCities()
                    ApplyAllStencils(Caller: "Custom city list changed")
                }
                
            case .HourFontName:
                UpdateHours()
                
            case .ExtrudedCitiesCastShadows:
                if Settings.GetEnum(ForKey: .CityShapes, EnumType: CityDisplayTypes.self, Default: .RelativeEmbedded) == .Names
                {
                    PlotCities()
                    ApplyAllStencils(Caller: "Cast shadows changed")
                }
                
            case .GridLinesDrawnOnMap:
                if Settings.GetEnum(ForKey: .ViewType, EnumType: ViewTypes.self, Default: .CubicWorld) == .Globe3D
                {
                    ApplyAllStencils(Caller: "SettingChanged(.GridLinesDrawnOnMap)")
                }
                
            case .GridLineColor, .MinorGridLineColor:
                if Settings.GetEnum(ForKey: .ViewType, EnumType: ViewTypes.self, Default: .CubicWorld) == .Globe3D
                {
                    ApplyAllStencils(Caller: "SettingChanged(.{Minor}GridLineColor)")
                }
                
            case .CityNamesDrawnOnMap:
                if Settings.GetEnum(ForKey: .ViewType, EnumType: ViewTypes.self, Default: .CubicWorld) == .Globe3D
                {
                    print("At .CityNamesDrawnOnMap")
                    ApplyAllStencils(Caller: "SettingChanged(.CityNamesDrawnOnMap)")
                }
                
            case .MagnitudeValuesDrawnOnMap:
                if Settings.GetEnum(ForKey: .ViewType, EnumType: ViewTypes.self, Default: .CubicWorld) == .Globe3D
                {
                    ClearEarthquakes()
                    ApplyAllStencils(Caller: "SettingChanged(.MagnitudeValuesDrawnOnMap)")
                }
                
            case .ShowEarthquakeRegions, .EarthquakeRegions:
                PlotRegions()
                
            case .QuakeScales:
                ClearEarthquakes()
                PlotEarthquakes()
                
            case .POIScale:
                PlotWorldHeritageSites()
                PlotCities()
                PlotPolarShape()
                
            case .UseSystemCameraControl:
                InitializeSceneCamera(!Settings.GetBool(.UseSystemCameraControl))
                
            case .CameraProjection, .CameraOrthographicScale, .CameraFieldOfView:
                UpdateFlatlandCamera()
                
            #if DEBUG
            case .ShowAxes:
                if Settings.GetBool(.ShowAxes)
                {
                    AddAxis()
                }
                else
                {
                    RemoveAxis()
                }
                
            case .ShowSkeletons, .ShowWireframes, .ShowBoundingBoxes, .ShowLightExtents,
                 .ShowLightInfluences, .ShowConstraints, .ShowStatistics, .ShowCreases,
                 .ShowPhysicsFields, .ShowPhysicsShapes, .RenderAsWireframe, .Debug3DMap,
                 .Enable3DDebugging:
                Settings.QueryBool(.ShowStatistics)
                {
                    Show in
                    self.self.showsStatistics = Show
                }
                var DebugTypes = [DebugOptions3D]()
                Settings.QueryBool(.ShowCreases)
                {
                    Show in
                    if Show
                    {
                        DebugTypes.append(.Creases)
                    }
                }
                Settings.QueryBool(.RenderAsWireframe)
                {
                    Show in
                    if Show
                    {
                        DebugTypes.append(.RenderWireFrame)
                    }
                }
                Settings.QueryBool(.ShowPhysicsShapes)
                {
                    Show in
                    if Show
                    {
                        DebugTypes.append(.PhysicsShapes)
                    }
                }
                Settings.QueryBool(.ShowPhysicsFields)
                {
                    Show in
                    if Show
                    {
                        DebugTypes.append(.PhysicsFields)
                    }
                }
                Settings.QueryBool(.ShowSkeletons)
                {
                    Show in
                    if Show
                    {
                        DebugTypes.append(.Skeleton)
                    }
                }
                Settings.QueryBool(.ShowBoundingBoxes)
                {
                    Show in
                    if Show
                    {
                        DebugTypes.append(.BoundingBoxes)
                    }
                }
                Settings.QueryBool(.ShowWireframes)
                {
                    Show in
                    if Show
                    {
                        DebugTypes.append(.WireFrame)
                    }
                }
                Settings.QueryBool(.ShowLightInfluences)
                {
                    Show in
                    if Show
                    {
                        DebugTypes.append(.LightInfluences)
                    }
                }
                Settings.QueryBool(.ShowLightExtents)
                {
                    Show in
                    if Show
                    {
                        DebugTypes.append(.LightExtents)
                    }
                }
                Settings.QueryBool(.ShowConstraints)
                {
                    Show in
                    if Show
                    {
                        DebugTypes.append(.Constraints)
                    }
                }
                SetDebugOption(DebugTypes)
                
            case .Debug_EnableClockControl, .Debug_ClockDebugMap, .Debug_ClockActionFreeze,
                 .Debug_ClockActionFreezeTime, .Debug_ClockActionClockAngle, .Debug_ClockUseTimeMultiplier,
                 .Debug_ClockActionClockMultiplier, .Debug_ClockActionSetClockAngle,
                 .Debug_ClockActionFreezeAtTime:
                UpdateEarthView()
                
            case .ShowKnownLocations:
                if Settings.GetBool(.ShowKnownLocations)
                {
                    PlotKnownLocations()
                }
                else
                {
                    HideKnownLocations()
                }
            #endif
            
            case .AntialiasLevel:
                let NewLevel = Settings.GetEnum(ForKey: .AntialiasLevel, EnumType: SceneJitters.self, Default: .Jitter4X)
                switch NewLevel
                {
                    case .None:
                        self.antialiasingMode = .none
                        
                    case .Jitter2X:
                        self.antialiasingMode = .multisampling2X
                        
                    case .Jitter4X:
                        self.antialiasingMode = .multisampling4X
                        
                    case .Jitter8X:
                        self.antialiasingMode = .multisampling4X
                        
                    case .Jitter16X:
                        self.antialiasingMode = .multisampling4X
                }
                
            case .EnableJittering:
                self.isJitteringEnabled = Settings.GetBool(.EnableJittering)
                
            case .HourScale:
                UpdateHours()
                
                #if false
            case .FollowMouse:
                SetMouseTracking(Track: Settings.GetBool(.FollowMouse))
                #endif
                
            case .HideMouseOverEarth:
                if !Settings.GetBool(.HideMouseOverEarth)
                {
                    #if false
                    if !MouseIsVisible
                    {
                        MouseIsVisible = true
                        NSCursor.unhide()
                    }
                    #endif
                }
                
            default:
                //Debug.Print("Unhandled setting \(Setting)")
                return
        }
    }
}
