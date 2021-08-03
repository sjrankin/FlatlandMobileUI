//
//  +Maps.swift
//  Flatland
//
//  Created by Stuart Rankin on 1/1/21.
//  Copyright © 2021 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit
import SceneKit

extension GlobeView
{
    /// Return maps to be used as textures for the 3D Earth.
    /// - Important: The `blendMode` **must** be set to `.replace` (and the `blendMode` of the region node
    ///              set to `.alpha`) in order for the blending to work correctly.
    /// - Parameter Map: The map type whose image (or images) will be returned.
    /// - Returns: Tuple with the standard Earth map and, if the map type supports it, the sea map as well.
    func MakeMaps(_ Map: MapTypes) -> (Earth: UIImage, Sea: UIImage?)
    {
        let BaseMap = MapManager.ImageFor(MapType: Map, ViewType: .Globe3D)
//        let BaseMap = MapManager.ImageFor(MapType: .SimplePoliticalMap1, ViewType: .Globe3D)
        var SecondaryMap: UIImage? = nil
        switch Map
        {
            case .Standard:
                SecondaryMap = MapManager.ImageFor(MapType: .StandardSea, ViewType: .Globe3D)!
                
            case .TectonicOverlay:
                SecondaryMap = MapManager.ImageFor(MapType: .Dithered, ViewType: .Globe3D)!
                
            case .StylizedSea1:
                SecondaryMap = UIImage(named: "JapanesePattern4")!
                
            default:
                break
        }
        if let Category = MapManager.CategoryFor(Map: Map)
        {
            if Category == .Satellite
            {
                if let TheMap = GlobalBaseMap
                {
                    return (Earth: TheMap, Sea: SecondaryMap)
                }
                let LastResortMap = MapManager.ImageFor(MapType: .Standard, ViewType: .Globe3D)!
                return (Earth: LastResortMap, Sea: nil)
            }
        }
        return (Earth: BaseMap!, Sea: SecondaryMap)
    }
    
    func DoGetNodeCount(From: SCNNode) -> Int
    {
        var Count = 0
        for Child in From.childNodes
        {
            Count = Count + DoGetNodeCount(From: Child)
        }
        Count = Count + From.childNodes.count
        return Count
    }
    
    func ViewNodeCount() -> Int
    {
        return DoGetNodeCount(From: self.scene!.rootNode)
    }
    
    /// Set an Earth map view to the 3D view.
    /// - Parameter FastAnimated: Used for debugging.
    /// - Parameter WithMap: Image to use as the base map.
    func SetEarthMap(FastAnimate: Bool = false, WithMap: UIImage? = nil)
    {
        Features.FeatureEnabled(.CubicEarth)
        {
            IsEnabled in
            if IsEnabled
            {
                if Settings.GetEnum(ForKey: .ViewType, EnumType: ViewTypes.self, Default: .Globe3D) == .CubicWorld
                {
                    self.ShowCubicEarth()
                    return
                }
            }
        }
        let SFrame = Debug.StackFrameContents(10)
        let PrettyFrames = Debug.PrettyStackTrace(SFrame)
        Debug.Print(PrettyFrames)
        EarthNode?.removeAllActions()
        EarthNode?.removeFromParentNode()
        EarthNode = nil
        SeaNode?.removeAllActions()
        SeaNode?.removeFromParentNode()
        SeaNode = nil
        LineNode?.removeAllActions()
        LineNode?.removeFromParentNode()
        LineNode = nil
        SystemNode?.removeAllActions()
        SystemNode?.removeFromParentNode()
        SystemNode = nil
        HourNode?.removeAllActions()
        HourNode?.removeFromParentNode()
        HourNode = nil
        
        SystemNode = SCNNode2()
        
        let EarthSphere = SCNSphere(radius: GlobeRadius.Primary.rawValue)
        EarthSphere.segmentCount = Settings.GetInt(.SphereSegmentCount, IfZero: Int(Defaults.SphereSegmentCount.rawValue))
        let SeaSphere = SCNSphere(radius: GlobeRadius.SeaSphere.rawValue)
        SeaSphere.segmentCount = Settings.GetInt(.SphereSegmentCount, IfZero: Int(Defaults.SphereSegmentCount.rawValue))
        
        let MapType = Settings.GetEnum(ForKey: .MapType, EnumType: MapTypes.self, Default: .SimplePoliticalMap1)
        var BaseMap: UIImage? = nil
        var SecondaryMap = UIImage()
        
        if let OtherMap = WithMap
        {
            BaseMap = OtherMap
        }
        else
        {
            let (Earth, Sea) = MakeMaps(MapType)
            BaseMap = Earth
            if let SeaMap = Sea
            {
                SecondaryMap = SeaMap
            }
        }
        
        //If the map is a satellite tile map, load the most recently cached map. If no cached map is available,
        //display a simple political map.
        var IsSatelliteMap = false
        if let Category = MapManager.CategoryFor(Map: MapType)
        {
            if Category == .Satellite
            {
                if let LastSatelliteMap = Settings.GetCachedImage(For: MapType)
                {
                    BaseMap = LastSatelliteMap
                    IsSatelliteMap = true
                }
                else
                {
                    BaseMap = MapManager.ImageFor(MapType: .SimplePoliticalMap1, ViewType: .Globe3D)
                }
            }
        }
        
        switch MapType
        {
            case .Standard:
                SecondaryMap = MapManager.ImageFor(MapType: .StandardSea, ViewType: .Globe3D)!
                
            case .TectonicOverlay:
                SecondaryMap = MapManager.ImageFor(MapType: .Dithered, ViewType: .Globe3D)!
                
            case .StylizedSea1:
                SecondaryMap = UIImage(named: "JapanesePattern4")!
                
            default:
                break
        }
        
        GlobalBaseMap = BaseMap
        
        EarthNode = SCNNode2(geometry: EarthSphere)
        EarthNode?.castsShadow = true
        EarthNode?.CanShowBoundingShape = false
        EarthNode?.categoryBitMask = LightMasks3D.Sun.rawValue | LightMasks3D.Moon.rawValue
        EarthNode?.position = SCNVector3(0.0, 0.0, 0.0)
        let Stenciled = Stenciler.AddGridLines(To: BaseMap!, Ratio: 1.0)
        EarthNode?.geometry?.firstMaterial?.diffuse.contents = Stenciled
//        EarthNode?.geometry?.firstMaterial?.diffuse.contents = BaseMap!
        EarthNode?.geometry?.firstMaterial?.emission.contents = nil
        if IsSatelliteMap
        {
            if MapType == .GIBS_SNPP_VIIRS_DayNightBand_At_Sensor_Radiance
            {
                EarthNode?.geometry?.firstMaterial?.emission.contents = BaseMap!
            }
        }
        EarthNode?.geometry?.firstMaterial?.lightingModel = .blinn
        //The blend mode must be .replace if there are nodes over the Earth with alpha levels. Those nodes
        //must have a blend mode of .alpha.
        EarthNode?.geometry?.firstMaterial?.blendMode = .replace
        
        let Constraint = SCNDistanceConstraint(target: self.EarthNode!)
        Constraint.maximumDistance = 200
        Constraint.minimumDistance = 70
        CameraNode.constraints = [Constraint]
        
        //Precondition the surfaces.
        switch MapType
        {
            case .EarthquakeMap:
                SeaNode = SCNNode2(geometry: SeaSphere)
                SeaNode?.castsShadow = true
                SeaNode?.categoryBitMask = LightMasks3D.Sun.rawValue | LightMasks3D.Moon.rawValue
                SeaNode?.position = SCNVector3(0.0, 0.0, 0.0)
                SeaNode?.geometry?.firstMaterial?.diffuse.contents = UIColor.systemTeal.withAlphaComponent(CGFloat(Defaults.EarthquakeMapOpacity.rawValue))
                EarthNode?.opacity = CGFloat(Defaults.EarthquakeMapOpacity.rawValue)
                
            case .StylizedSea1:
                SeaNode = SCNNode2(geometry: SeaSphere)
                SeaNode?.castsShadow = true
                SeaNode?.categoryBitMask = LightMasks3D.Sun.rawValue | LightMasks3D.Moon.rawValue
                SeaNode?.position = SCNVector3(0.0, 0.0, 0.0)
                SeaNode?.geometry?.firstMaterial?.diffuse.contents = SecondaryMap
                
            case .Debug2:
                SeaNode = SCNNode2(geometry: SeaSphere)
                SeaNode?.castsShadow = true
                SeaNode?.categoryBitMask = LightMasks3D.Sun.rawValue | LightMasks3D.Moon.rawValue
                SeaNode?.position = SCNVector3(0.0, 0.0, 0.0)
                SeaNode?.geometry?.firstMaterial?.diffuse.contents = UIColor.systemTeal
                SeaNode?.geometry?.firstMaterial?.specular.contents = UIColor.white
                EarthNode?.geometry?.firstMaterial?.specular.contents = UIColor.clear
                
            case .Debug5:
                SeaNode = SCNNode2(geometry: SeaSphere)
                SeaNode?.castsShadow = true
                SeaNode?.categoryBitMask = LightMasks3D.Sun.rawValue | LightMasks3D.Moon.rawValue
                SeaNode?.position = SCNVector3(0.0, 0.0, 0.0)
                SeaNode?.geometry?.firstMaterial?.diffuse.contents = UIColor.systemYellow
                SeaNode?.geometry?.firstMaterial?.specular.contents = UIColor.white
                EarthNode?.geometry?.firstMaterial?.specular.contents = UIColor.clear
                
            case .TectonicOverlay:
                SeaNode = SCNNode2(geometry: SeaSphere)
                SeaNode?.castsShadow = true
                SeaNode?.categoryBitMask = LightMasks3D.Sun.rawValue | LightMasks3D.Moon.rawValue
                SeaNode?.position = SCNVector3(0.0, 0.0, 0.0)
                SeaNode?.geometry?.firstMaterial?.diffuse.contents = SecondaryMap
                
            case .ASCIIArt1:
                SeaNode = SCNNode2(geometry: SeaSphere)
                SeaNode?.castsShadow = true
                SeaNode?.categoryBitMask = LightMasks3D.Sun.rawValue | LightMasks3D.Moon.rawValue
                SeaNode?.position = SCNVector3(0.0, 0.0, 0.0)
                SeaNode?.geometry?.firstMaterial?.diffuse.contents = UIColor.white
                SeaNode?.geometry?.firstMaterial?.specular.contents = UIColor.yellow
                
            case .BlackWhiteShiny:
                SeaNode = SCNNode2(geometry: SeaSphere)
                SeaNode?.castsShadow = true
                SeaNode?.categoryBitMask = LightMasks3D.Sun.rawValue | LightMasks3D.Moon.rawValue
                SeaNode?.position = SCNVector3(0.0, 0.0, 0.0)
                SeaNode?.geometry?.firstMaterial?.diffuse.contents = UIColor.white
                SeaNode?.geometry?.firstMaterial?.specular.contents = UIColor.yellow
                SeaNode?.geometry?.firstMaterial?.lightingModel = .phong
                
            case .Standard:
                SeaNode = SCNNode2(geometry: SeaSphere)
                SeaNode?.castsShadow = true
                SeaNode?.categoryBitMask = LightMasks3D.Sun.rawValue | LightMasks3D.Moon.rawValue
                SeaNode?.position = SCNVector3(0.0, 0.0, 0.0)
                SeaNode?.geometry?.firstMaterial?.diffuse.contents = SecondaryMap
                SeaNode?.geometry?.firstMaterial?.specular.contents = UIColor.white
                SeaNode?.geometry?.firstMaterial?.lightingModel = .blinn
                
            case .SimpleBorders2:
                SeaNode = SCNNode2(geometry: SeaSphere)
                SeaNode?.castsShadow = true
                SeaNode?.categoryBitMask = LightMasks3D.Sun.rawValue | LightMasks3D.Moon.rawValue
                SeaNode?.position = SCNVector3(0.0, 0.0, 0.0)
                SeaNode?.geometry?.firstMaterial?.diffuse.contents = UIColor.systemBlue
                SeaNode?.geometry?.firstMaterial?.specular.contents = UIColor.white
                SeaNode?.geometry?.firstMaterial?.lightingModel = .phong
                
            case .Topographical1:
                SeaNode = SCNNode2(geometry: SeaSphere)
                SeaNode?.castsShadow = true
                SeaNode?.categoryBitMask = LightMasks3D.Sun.rawValue | LightMasks3D.Moon.rawValue
                SeaNode?.position = SCNVector3(0.0, 0.0, 0.0)
                SeaNode?.geometry?.firstMaterial?.diffuse.contents = UIColor.systemBlue
                SeaNode?.geometry?.firstMaterial?.specular.contents = UIColor.white
                SeaNode?.geometry?.firstMaterial?.lightingModel = .phong
                
            case .Pink:
                SeaNode = SCNNode2(geometry: SeaSphere)
                SeaNode?.castsShadow = true
                SeaNode?.categoryBitMask = LightMasks3D.Sun.rawValue | LightMasks3D.Moon.rawValue
                SeaNode?.position = SCNVector3(0.0, 0.0, 0.0)
                SeaNode?.geometry?.firstMaterial?.diffuse.contents = UIColor.orange
                SeaNode?.geometry?.firstMaterial?.specular.contents = UIColor.yellow
                EarthNode?.geometry?.firstMaterial?.lightingModel = .phong
                
            case .Bronze:
                EarthNode?.geometry?.firstMaterial?.specular.contents = UIColor.orange
                SeaNode = SCNNode2(geometry: SeaSphere)
                SeaNode?.castsShadow = true
                SeaNode?.categoryBitMask = LightMasks3D.Sun.rawValue | LightMasks3D.Moon.rawValue
                SeaNode?.position = SCNVector3(0.0, 0.0, 0.0)
                SeaNode?.geometry?.firstMaterial?.diffuse.contents = UIColor(red: 1.0,
                                                                             green: 210.0 / 255.0,
                                                                             blue: 0.0,
                                                                             alpha: 1.0)
                SeaNode?.geometry?.firstMaterial?.specular.contents = UIColor.white
                SeaNode?.geometry?.firstMaterial?.lightingModel = .lambert
                
            default:
                //Create an empty sea node if one is not needed.
                SeaNode = SCNNode2()
                SeaNode?.categoryBitMask = LightMasks3D.Sun.rawValue | LightMasks3D.Moon.rawValue
                SeaNode?.castsShadow = true
        }
        SeaNode?.geometry?.firstMaterial?.blendMode = .replace
        
        EarthNode?.NodeID = NodeTables.EarthGlobe
        EarthNode?.NodeClass = UUID(uuidString: NodeClasses.Miscellaneous.rawValue)!
        SeaNode?.NodeID = NodeTables.SeaGlobe
        SeaNode?.CanShowBoundingShape = false
        SeaNode?.NodeClass = UUID(uuidString: NodeClasses.Miscellaneous.rawValue)!
        
        PlotLocations(On: EarthNode!, WithRadius: GlobeRadius.Primary.rawValue)
        
        let SeaMapList: [MapTypes] = [.Standard, .Topographical1, .SimpleBorders2, .Pink, .Bronze,
                                      .TectonicOverlay, .BlackWhiteShiny, .ASCIIArt1, .Debug2,
                                      .Debug5, .StylizedSea1, .EarthquakeMap]
        self.prepare([EarthNode!, SeaNode!], completionHandler:
                        {
                            success in
                            if success
                            {
                                self.SystemNode?.addChildNode(self.EarthNode!)
                                if SeaMapList.contains(MapType)
                                {
                                    self.SystemNode?.addChildNode(self.SeaNode!)
                                }
                                self.scene?.rootNode.addChildNode(self.SystemNode!)
                            }
                        }
        )
        
        let HourType = Settings.GetEnum(ForKey: .HourType, EnumType: HourTypes.self, Default: .None)
        UpdateHourLabels(With: HourType)
        
        let Declination = Sun.Declination(For: Date())
        SystemNode?.eulerAngles = SCNVector3(Declination.Radians, 0.0, 0.0)
        SystemNode?.geometry?.firstMaterial?.blendMode = .replace
        
        if FastAnimate
        {
            let EarthRotate = SCNAction.rotateBy(x: 0.0, y: 360.0 * CGFloat.pi / 180.0, z: 0.0,
                                                 duration: Defaults.FastAnimationDuration.rawValue)
            let RotateForever = SCNAction.repeatForever(EarthRotate)
            SystemNode?.runAction(RotateForever)
        }
    }
    
    /// Change the base map to the passed map.
    /// - Note: Stenciling will be applied as appropriate and the new base map will be applied
    ///         once the stenciling process has been completed.
    /// - Parameter To: Texture to use for the base map.
    func ChangeEarthBaseMap(To NewMap: UIImage)
    {
        GlobalBaseMap = NewMap
        OperationQueue.main.addOperation
        {
            self.EarthNode?.geometry?.firstMaterial?.diffuse.contents = NewMap
        }
        ApplyAllStencils(Caller: #function)
    }
}
