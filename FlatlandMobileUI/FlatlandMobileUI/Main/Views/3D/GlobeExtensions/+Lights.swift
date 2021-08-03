//
//  +Lights.swift
//  Flatland
//
//  Created by Stuart Rankin on 9/21/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//
import Foundation
import UIKit
import SceneKit

extension GlobeView
{
    // MARK: - 3D light-related functions
    
    /// Setup lights to use to view the 3D scene.
    func SetupLights()
    {
        if Settings.GetBool(.UseAmbientLight)
        {
            CreateAmbientLight()
            MoonNode?.removeAllActions()
            MoonNode?.removeFromParentNode()
            MoonNode = nil
            LightNode.removeAllActions()
            LightNode.removeFromParentNode()
            MetalSunNode.removeAllActions()
            MetalSunNode.removeFromParentNode()
            MetalMoonNode.removeAllActions()
            MetalMoonNode.removeFromParentNode()
            GridLightNode1.removeAllActions()
            GridLightNode1.removeFromParentNode()
            GridLightNode2.removeAllActions()
            GridLightNode2.removeFromParentNode()
        }
        else
        {
            RemoveAmbientLight()
            SetGridLight()
            SetMetalLights()
            SetSunlight()
            SetMoonlight(Show: Settings.GetBool(.ShowMoonLight))
        }
    }
    
    /// Create a light to use for the 3D scene.
    /// - Parameter CastsShadow: If true, the light will cast a shadow. If false, no shadow will be shown.
    /// - Parameter Mask: The category mask for the light. If not specified `0` is used.
    /// - Parameter LightName: The name of the light, if specified. If nil, no name is assigned.
    /// - Returns: An `SCNLight` for the 3D scene.
    func CreateDefaultLight(CastsShadow: Bool = true, Mask: Int = 0, LightName: LightNames? = nil) -> SCNLight
    {
        let Light = SCNLight()
        if let Name = LightName
        {
            Light.name = Name.rawValue
        }
        Light.categoryBitMask = Mask
        if CastsShadow
        {
            Light.castsShadow = true
            Light.shadowColor = UIColor.black.withAlphaComponent(CGFloat(Defaults.ShadowAlpha.rawValue))
            Light.shadowMode = .forward
            Light.shadowRadius = CGFloat(Defaults.ShadowRadius.rawValue)
            #if false
            Light.shadowSampleCount = 16
            Light.shadowMapSize = CGSize(width: 2048, height: 2048)
            Light.automaticallyAdjustsShadowProjection = true
            Light.shadowCascadeCount = 3
            Light.shadowCascadeSplittingFactor = 0.09
            #endif
        }
        Light.zFar = CGFloat(Defaults.ZFar.rawValue)//1000
        Light.zNear = 0.1
        return Light
    }
    
    /// Create an ambient light for the scene.
    func CreateAmbientLight()
    {
        let Ambient = CreateDefaultLight(Mask: LightMasks3D.Sun.rawValue, LightName: LightNames.Ambient3D)
        Ambient.type = .ambient
        Ambient.intensity = CGFloat(Defaults.AmbientLightIntensity.rawValue)
        Ambient.color = UIColor.white
        AmbientLightNode = SCNNode()
        AmbientLightNode?.name = LightNames.Ambient3D.rawValue
        AmbientLightNode?.light = Ambient
        AmbientLightNode?.position = SCNVector3(0.0, 0.0, Defaults.AmbientLightZ.rawValue)
        self.scene?.rootNode.addChildNode(AmbientLightNode!)
    }
    
    /// Remove the ambient light from the scene.
    func RemoveAmbientLight()
    {
        AmbientLightNode?.removeAllActions()
        AmbientLightNode?.removeFromParentNode()
        AmbientLightNode = nil
    }
    
    /// Set up "sun light" for the scene.
    func SetSunlight()
    {
        SunLight = CreateDefaultLight(Mask: LightMasks3D.Sun.rawValue, LightName: LightNames.Sun3D)
        SunLight.type = .directional
        SunLight.intensity = CGFloat(Defaults.SunLightIntensity.rawValue)
        SunLight.color = UIColor.white
        LightNode = SCNNode()
        LightNode.name = LightNames.Sun3D.rawValue
        LightNode.light = SunLight
        LightNode.position = SCNVector3(0.0, 0.0, Defaults.SunLightZ.rawValue)
        self.scene?.rootNode.addChildNode(LightNode)
    }
    
    /// Show or hide the moonlight node.
    /// - Parameter Show: Determines if moonlight is shown or removed.
    func SetMoonlight(Show: Bool)
    {
        if Show
        {
            let MoonLight = CreateDefaultLight(Mask: LightMasks3D.Moon.rawValue, LightName: LightNames.Moon3D)
            MoonLight.type = .directional
            MoonLight.intensity = CGFloat(Defaults.MoonLightIntensity.rawValue)
            MoonLight.color = UIColor.cyan
            MoonNode = SCNNode()
            MoonNode?.name = LightNames.Moon3D.rawValue
            MoonNode?.light = MoonLight
            MoonNode?.position = SCNVector3(0.0, 0.0, Defaults.MoonLightZ.rawValue)
            MoonNode?.eulerAngles = SCNVector3(180.0 * CGFloat.pi / 180.0, 0.0, 0.0)
            self.scene?.rootNode.addChildNode(MoonNode!)
            
            MetalMoonLight = CreateDefaultLight(Mask: LightMasks3D.MetalMoon.rawValue, LightName: LightNames.MoonMetallic3D)
            MetalMoonLight.type = .directional
            MetalMoonLight.intensity = CGFloat(Defaults.MetalMoonLightIntensity.rawValue)
            MetalMoonLight.color = UIColor.cyan
            MetalMoonNode = SCNNode()
            MetalMoonNode.name = LightNames.MoonMetallic3D.rawValue
            MetalMoonNode.light = MetalMoonLight
            MetalMoonNode.position = SCNVector3(0.0, 0.0, Defaults.MoonLightZ.rawValue)
            MetalMoonNode.eulerAngles = SCNVector3(180.0 * CGFloat.pi / 180.0, 0.0, 0.0)
            self.scene?.rootNode.addChildNode(MetalMoonNode)
        }
        else
        {
            MetalMoonNode.removeAllActions()
            MetalMoonNode.removeFromParentNode()
            MoonNode?.removeAllActions()
            MoonNode?.removeFromParentNode()
            MoonNode = nil
        }
    }
    
    /// Set the lights used for metallic components.
    func SetMetalLights()
    {
        MetalSunLight = CreateDefaultLight(Mask: LightMasks3D.MetalSun.rawValue, LightName: LightNames.SunMetallic3D)
        MetalSunLight.type = .directional
        MetalSunLight.intensity = CGFloat(Defaults.MetalSunLightIntensity.rawValue)
        MetalSunLight.color = UIColor.white
        MetalSunNode = SCNNode()
        MetalSunNode.name = LightNames.SunMetallic3D.rawValue
        MetalSunNode.light = MetalSunLight
        MetalSunNode.position = SCNVector3(0.0, 0.0, Defaults.SunLightZ.rawValue)
        self.scene?.rootNode.addChildNode(MetalSunNode)
        
        MetalMoonLight = CreateDefaultLight(Mask: LightMasks3D.MetalMoon.rawValue, LightName: LightNames.MoonMetallic3D)
        MetalMoonLight.type = .directional
        MetalMoonLight.intensity = CGFloat(Defaults.MetalMoonLightIntensity.rawValue)
        MetalMoonLight.color = UIColor.cyan
        MetalMoonNode = SCNNode()
        MetalMoonNode.name = LightNames.MoonMetallic3D.rawValue
        MetalMoonNode.light = MetalMoonLight
        MetalMoonNode.position = SCNVector3(0.0, 0.0, Defaults.MoonLightZ.rawValue)
        MetalMoonNode.eulerAngles = SCNVector3(180.0 * CGFloat.pi / 180.0, 0.0, 0.0)
        self.scene?.rootNode.addChildNode(MetalMoonNode)
    }
    
    /// Set the lights for the grid. The grid needs a separate light because when it's over the night
    /// side, it's not easily visible. There are two grid lights - one for day time and one for night time.
    func SetGridLight()
    {
        #if false
        GridLight1 = CreateDefaultLight(Mask: LightMasks3D.Grid.rawValue, LightName: LightNames.Grid13D)
        GridLight1.type = .omni
        GridLight1.color = UIColor.white
        GridLightNode1 = SCNNode()
        GridLightNode1.name = LightNames.Grid13D.rawValue
        GridLightNode1.light = GridLight1
        GridLightNode1.position = SCNVector3(0.0, 0.0, Defaults.Grid1Z.rawValue)
        self.MainScene?.rootNode.addChildNode(GridLightNode1)
        
        GridLight2 = CreateDefaultLight(Mask: LightMasks3D.Grid.rawValue, LightName: LightNames.Grid23D)
        GridLight2.type = .omni
        GridLight2.color = UIColor.white
        GridLightNode2 = SCNNode()
        GridLightNode2.name = LightNames.Grid23D.rawValue
        GridLightNode2.light = GridLight2
        GridLightNode2.position = SCNVector3(0.0, 0.0, Defaults.Grid2Z.rawValue)
        self.MainScene?.rootNode.addChildNode(GridLightNode2)
        #endif
    }
}
