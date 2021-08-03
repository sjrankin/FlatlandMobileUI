//
//  +Debug.swift
//  Flatland
//
//  Created by Stuart Rankin on 12/5/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit
import SceneKit

extension GlobeView
{
    /// Hide known locations.
    func HideKnownLocations()
    {
        #if DEBUG
        if let Earth = EarthNode
        {
            for SomeNode in Earth.childNodes
            {
                if SomeNode.name == GlobeNodeNames.KnownLocation.rawValue
                {
                    SomeNode.removeAllActions()
                    SomeNode.removeAllAnimations()
                    SomeNode.removeFromParentNode()
                    SomeNode.geometry = nil
                }
            }
        }
        #endif
    }
    
    /// Plot known locations. Intended for use for debugging purposes only.
    func PlotKnownLocations()
    {
        #if DEBUG
        NodeTables.RemoveKnownLocations()
        for Longitude in [-90.0, 0.0, 90.0, 180.0]
        {
            for Latitude in [-66.56341666666667, -23.43657, 0.0, 23.43657, 66.56341666666667]
            {
                let (X, Y, Z) = Geometry.ToECEF(Latitude, Longitude, Radius: Double(GlobeRadius.Primary.rawValue))
                let Sphere = SCNSphere(radius: 0.2)
                let KnownNode = SCNNode2(geometry: Sphere)
                KnownNode.NodeID = UUID()
                NodeTables.AddKnownLocation(ID: KnownNode.NodeID!, Latitude, Longitude, X: X, Y: Y, Z: Z)
                KnownNode.name = GlobeNodeNames.KnownLocation.rawValue
                KnownNode.geometry?.firstMaterial?.diffuse.contents = UIColor.black
                KnownNode.geometry?.firstMaterial?.emission.contents = UIColor.yellow
                KnownNode.categoryBitMask = LightMasks3D.Sun.rawValue | LightMasks3D.Moon.rawValue
                KnownNode.position = SCNVector3(X, Y, Z)
                EarthNode?.addChildNode(KnownNode)
                let LightSwitch = SCNAction.customAction(duration: 1.0)
                {
                    Node, Elapsed in
                    if Elapsed >= 1.0
                    {
                        if let OldColor = Node.geometry?.firstMaterial?.emission.contents as? UIColor
                        {
                            if OldColor == UIColor.yellow
                            {
                                Node.geometry?.firstMaterial?.emission.contents = UIColor.systemOrange
                            }
                            else
                            {
                                Node.geometry?.firstMaterial?.emission.contents = UIColor.yellow
                            }
                        }
                    }
                }
                let SwitchForever = SCNAction.repeatForever(LightSwitch)
                KnownNode.runAction(SwitchForever)
            }
        }
        #endif
    }
}
