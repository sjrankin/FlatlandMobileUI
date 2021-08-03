//
//  +CubicEarth.swift
//  Flatland
//
//  Created by Stuart Rankin on 6/4/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit
import SceneKit

extension GlobeView
{
    // MARK: - Cubic Earth Creation
    
    /// Draws a cubical Earth for no other reason than being silly.
    func ShowCubicEarth()
    {
        EarthNode?.removeAllActions()
        EarthNode?.removeFromParentNode()
        EarthNode?.geometry = nil
        SeaNode?.removeAllActions()
        SeaNode?.removeFromParentNode()
        SeaNode?.geometry = nil
        //        LineNode?.removeAllActions()
        //        LineNode?.removeFromParentNode()
        SystemNode?.removeAllActions()
        SystemNode?.removeFromParentNode()
        SystemNode?.geometry = nil
        HourNode?.removeAllActions()
        HourNode?.removeFromParentNode()
        HourNode?.geometry = nil
        
        let EarthCube = SCNBox(width: 10.0, height: 10.0, length: 10.0, chamferRadius: 0.5)
        EarthNode = SCNNode2(geometry: EarthCube)
        EarthNode?.NodeID = NodeTables.EarthGlobe
        EarthNode?.NodeClass = UUID(uuidString: NodeClasses.Miscellaneous.rawValue)!
        EarthNode?.categoryBitMask = LightMasks3D.Sun.rawValue | LightMasks3D.Moon.rawValue
        
        EarthNode?.position = SCNVector3(0.0, 0.0, 0.0)
        EarthNode?.geometry?.materials.removeAll()
        EarthNode?.geometry?.materials.append(MapManager.CubicImageMaterial(.nx)!)
        EarthNode?.geometry?.materials.append(MapManager.CubicImageMaterial(.pz)!)
        EarthNode?.geometry?.materials.append(MapManager.CubicImageMaterial(.px)!)
        EarthNode?.geometry?.materials.append(MapManager.CubicImageMaterial(.nz)!)
        EarthNode?.geometry?.materials.append(MapManager.CubicImageMaterial(.pym90)!)
        EarthNode?.geometry?.materials.append(MapManager.CubicImageMaterial(.ny90)!)
        
        EarthNode?.geometry?.firstMaterial?.specular.contents = UIColor.clear
        EarthNode?.geometry?.firstMaterial?.lightingModel = .blinn
        
        let HourType = Settings.GetEnum(ForKey: .HourType, EnumType: HourTypes.self, Default: .None)
        UpdateHourLabels(With: HourType)
        
        let Declination = Sun.Declination(For: Date())
        SystemNode = SCNNode2()
        SystemNode?.eulerAngles = SCNVector3(Declination.Radians, 0.0, 0.0)
        HourNode?.eulerAngles = SCNVector3(Declination.Radians, 0.0, 0.0)
        
        self.prepare([EarthNode!, HourNode!], completionHandler:
                        {
            success in
            if success
            {
                self.SystemNode?.addChildNode(self.EarthNode!)
                self.SystemNode?.addChildNode(self.HourNode!)
                self.scene?.rootNode.addChildNode(self.SystemNode!)
            }
        }
        )
    }
}
