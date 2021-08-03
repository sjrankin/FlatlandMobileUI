//
//  +Zoom.swift
//  Flatland
//
//  Created by Stuart Rankin on 4/13/21.
//  Copyright © 2021 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit
import SceneKit

extension GlobeView
{
    /// Handles camera zooming (in or out). When the camera zooms in closer, the scale of drawn nodes is
    /// reduced to allow more items to appear in a smaller area.
    /// - Parameter NewDistance: New distance for the camera from the center of the Earth.
    func HandleCameraLocationChanged(NewDistance: CGFloat)
    {
        UpdateFlatnessForCamera(Distance: NewDistance)
        UpdateCityFlatnessForCamera(Distance: NewDistance)
        ScaleNodes(NewDistance)
    }
    
    /// Returns an appropriate scale value for 3D objects depending on the distance of the camera from the
    /// center of the Earth.
    /// - Parameter From: The distance from the camera to the center of the Earth.
    /// - Returns: Scale value for 3D objects based on the camera location.
    func GetObjectScale(From Distance: CGFloat, For: ScaleTypes) -> CGFloat
    {
        var DistancePercent = Double(Distance) / Defaults.InitialZ.rawValue
        if DistancePercent > 1.0
        {
            DistancePercent = 1.0
        }
        switch For
        {
            case .Cities:
                let ScaleRange = Defaults.CityScaleHigh.rawValue - Defaults.CityScaleLow.rawValue
                let FinalScale = CGFloat(ScaleRange * DistancePercent) + CGFloat(Defaults.CityScaleLow.rawValue)
                return FinalScale
                
            case .CityNames:
                let ScaleRange = Defaults.CityNameScaleHigh.rawValue - Defaults.CityNameScaleLow.rawValue
                let FinalScale = CGFloat(ScaleRange * DistancePercent) + CGFloat(Defaults.CityNameScaleLow.rawValue)
                return FinalScale
                
            case .POIs:
                let ScaleRange = Defaults.NodeScaleHigh.rawValue - Defaults.NodeScaleLow.rawValue
                let FinalScale = CGFloat(ScaleRange * DistancePercent) + CGFloat(Defaults.NodeScaleLow.rawValue)
                return FinalScale
                
            case .Earthquakes:
                let ScaleRange = Defaults.EarthquakeScaleHigh.rawValue - Defaults.EarthquakeScaleLow.rawValue
                let FinalScale = CGFloat(ScaleRange * DistancePercent) + CGFloat(Defaults.EarthquakeScaleLow.rawValue)
                return FinalScale
                
            case .MagnitudeText:
                let ScaleRange = Defaults.MagScaleHigh.rawValue - Defaults.MagScaleLow.rawValue
                let FinalScale = CGFloat(ScaleRange * DistancePercent) + CGFloat(Defaults.MagScaleLow.rawValue)
                return FinalScale
                
            case .Hours:
                let ScaleRange = Defaults.HourScaleHigh.rawValue - Defaults.HourScaleLow.rawValue
                let FinalScale = CGFloat(ScaleRange * DistancePercent) + CGFloat(Defaults.HourScaleLow.rawValue)
                return FinalScale
        }
    }
    
    /// Scale nodes according to the passed camera distance. The closer the camera is to the surface of the
    /// Earth, the smaller the scale of objects will be. This is to allow for more objects to be displayed
    /// legibly when zooming in.
    /// - Parameter CameraDistance: The distance from the camera to the center of the Earth.
    func ScaleNodes(_ CameraDistance: CGFloat)
    {
        if let System = SystemNode
        {
            for Node in System.ChildNodes2()
            {
                if let NodeName = Node.name
                {
                    var FinalScale: CGFloat = 1.0
                    if NodeName == GlobeNodeNames.HomeNode.rawValue
                    {
                        FinalScale = GetObjectScale(From: CameraDistance, For: .Hours)
                    }
                    Node.scale = SCNVector3(FinalScale)
                }
            }
        }
        if let Surface = EarthNode
        {
            for Node in Surface.ChildNodes2()
            {
                if let NodeName = Node.name
                {
                    var FinalScale: CGFloat = 1.0
                    switch NodeName
                    {
                        case GlobeNodeNames.CityNameNode.rawValue:
                            FinalScale = GetObjectScale(From: CameraDistance, For: .CityNames)
                            
                        case GlobeNodeNames.CityNode.rawValue:
                            FinalScale = GetObjectScale(From: CameraDistance, For: .Cities)
                            
                        case GlobeNodeNames.POI.rawValue:
                            FinalScale = GetObjectScale(From: CameraDistance, For: .POIs)
                            
                        case GlobeNodeNames.HomeNode.rawValue:
                            FinalScale = GetObjectScale(From: CameraDistance, For: .Cities)
                            
                        case GlobeNodeNames.MagnitudeNode.rawValue:
                            FinalScale = GetObjectScale(From: CameraDistance, For: .MagnitudeText)
                            
                        case GlobeNodeNames.EarthquakeNodes.rawValue,
                             GlobeNodeNames.IndicatorNode.rawValue:
                            FinalScale = GetObjectScale(From: CameraDistance, For: .Earthquakes)
                            
                        default:
                            continue
                    }
                    Node.scale = SCNVector3(FinalScale)
                }
            }
        }
    }
}

enum ScaleTypes
{
    case CityNames
    case Cities
    case Earthquakes
    case MagnitudeText
    case POIs
    case Hours
}
