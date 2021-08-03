//
//  +Axes.swift
//  Flatland
//
//  Created by Stuart Rankin on 11/20/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit
import SceneKit

extension GlobeView
{
    // MARK: - 3D Axis Display
    
    /// Add all debug axes to the display.
    func AddAxis()
    {
        AddAxis([.X, .Y, .Z])
    }
    
    /// Add the specified axes to the display.
    /// - Parameter WhichAxes: Array of axes to display. Duplicate axes are ignored.
    func AddAxis(_ WhichAxes: [DebugAxes])
    {
        let AxisSet = Set(WhichAxes)
        for Axis in AxisSet
        {
            let node = MakeDebugAxis(Axis)
            self.scene?.rootNode.addChildNode(node)
        }
    }
    
    /// Create a debug axis.
    /// - Note: Axes are created as follows:
    ///   - **X**: Color is red and it points to the right in default orientation.
    ///   - **Y**: Color is green and it points to the top in default orientation.
    ///   - **Z**: Color is cyan and it points to the user in default orientation.
    /// - Parameter Axis: Determines which axis is created. This in turn determines its color, position, and
    ///                   orientation.
    /// - Returns: The debug axis shape.
    func MakeDebugAxis(_ Axis: DebugAxes) -> SCNNode2
    {
        let Stalk = SCNCylinder(radius: 0.1, height: 15.0)
        let StalkNode = SCNNode2(geometry: Stalk)
        StalkNode.castsShadow = false
        StalkNode.position = SCNVector3(0.0, 0.0, 0.0)
        let Tip = SCNCone(topRadius: 0.0, bottomRadius: 0.2, height: 0.4)
        let TipNode = SCNNode2(geometry: Tip)
        if Axis == .X
        {
            TipNode.position = SCNVector3(0.0, -7.6, 0.0)
            TipNode.eulerAngles = SCNVector3(180.0.Radians, 0.0.Radians, 0.0)
        }
        else
        {
            TipNode.position = SCNVector3(0.0, 7.6, 0.0)
        }
        let AxisNode = SCNNode2()
        AxisNode.addChildNode(StalkNode)
        AxisNode.addChildNode(TipNode)
        AxisNode.position = SCNVector3(0.0, 15.0, 0.0)
        
        switch Axis
        {
            case .X:
                AxisNode.name = "DebugXAxis"
                StalkNode.geometry?.firstMaterial?.emission.contents = UIColor.red
                TipNode.geometry?.firstMaterial?.emission.contents = UIColor.red
                AxisNode.eulerAngles = SCNVector3(0.0, 0.0, 90.0.Radians)
                AxisNode.position = SCNVector3(15.0, 0.0, 0.0)
                DebugXAxis = AxisNode
                
            case .Y:
                AxisNode.name = "DebugYAxis"
                StalkNode.geometry?.firstMaterial?.emission.contents = UIColor.green
                TipNode.geometry?.firstMaterial?.emission.contents = UIColor.green
                DebugYAxis = AxisNode
                
            case .Z:
                AxisNode.name = "DebugZAxis"
                StalkNode.geometry?.firstMaterial?.emission.contents = UIColor.cyan
                TipNode.geometry?.firstMaterial?.emission.contents = UIColor.cyan
                AxisNode.eulerAngles = SCNVector3(90.0.Radians, 0.0, 0.0)
                AxisNode.position = SCNVector3(0.0, 0.0, 15.0)
                DebugZAxis = AxisNode
        }
        return AxisNode
    }
    
    ///Remove all debug axes from the display.
    func RemoveAxis()
    {
        RemoveAxis([.X, .Y, .Z])
    }
    
    /// Removed the specified debug axes from the display.
    /// - Parameter AxesToRemove: Array of axes to remove. Duplicate axes are ignored.
    func RemoveAxis(_ AxesToRemove: [DebugAxes])
    {
        let AxisSet = Set(AxesToRemove)
        for Axis in AxisSet
        {
            switch Axis
            {
                case .X:
                    DebugXAxis?.removeAllActions()
                    DebugXAxis?.removeAllAnimations()
                    DebugXAxis?.removeFromParentNode()
                    DebugXAxis = nil
                    
                case .Y:
                    DebugYAxis?.removeAllActions()
                    DebugYAxis?.removeAllAnimations()
                    DebugYAxis?.removeFromParentNode()
                    DebugYAxis = nil
                    
                case .Z:
                    DebugZAxis?.removeAllActions()
                    DebugZAxis?.removeAllAnimations()
                    DebugZAxis?.removeFromParentNode()
                    DebugZAxis = nil
            }
        }
    }
}
