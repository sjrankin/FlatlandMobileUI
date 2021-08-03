//
//  SCNSatellite.swift
//  Flatland
//
//  Created by Stuart Rankin on 10/14/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit
import SceneKit

class SCNSatellite: SCNNode2
{
    override init()
    {
        super.init()
    }
    
    required init?(coder: NSCoder)
    {
        super.init(coder: coder)
    }
    
    init(_ Shape: Satellites, Scale: Double = 1.0)
    {
        super.init()
    }
    
    func RemoveSatellite()
    {
        for Node in self.childNodes
        {
            if Node.name == SatelliteNodes.ShapeNode.rawValue
            {
                Node.removeAllActions()
                Node.removeAllAnimations()
                Node.removeFromParentNode()
                Node.geometry = nil
            }
        }
    }
    
    func MakeSatellite(_ Satellite: Satellites, Scale: Double)
    {
        RemoveSatellite()
        Container = SCNNode2()
        Container.name = SatelliteNodes.ShapeNode.rawValue
        switch Satellite
        {
            case .Generic:
                MakeGeneric(With: Scale)
                
            case .Hubble:
                MakeHubble(With: Scale)
                
            case .ISS:
                MakeISS(With: Scale)
        }
        Container.scale = SCNVector3(Scale, Scale, Scale)
        self.addChildNode(Container)
    }
    
    func MakeISS(With Scale: Double)
    {
    }
    
    func MakeGeneric(With Scale: Double)
    {
    }
    
    func MakeHubble(With Scale: Double)
    {
        let Tube = SCNCone(topRadius: 0.05, bottomRadius: 0.07, height: 1.0)
        let TubeNode = SCNNode(geometry: Tube)
        TubeNode.geometry?.firstMaterial?.diffuse.contents = UIColor(hue: 0.9, saturation: 0.9, brightness: 0.9, alpha: 1.0)
    }
    
    private var Container: SCNNode2 = SCNNode2()
}

enum Satellites: String, CaseIterable
{
    case ISS = "International Space Station"
    case Hubble = "Hubble Space Telescope"
    case Generic = "Generic"
}

enum SatelliteNodes: String
{
    case ShapeNode = "SatelliteShape"
}
