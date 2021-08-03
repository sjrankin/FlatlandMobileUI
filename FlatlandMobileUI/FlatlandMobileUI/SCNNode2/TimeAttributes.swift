//
//  TimeAttributes.swift
//  TimeAttributes
//
//  Created by Stuart Rankin on 7/18/21. Adapted from Flatland View.
//

import Foundation
import UIKit
import SceneKit

/// Convenience class that holds attributes for day and night locations for instances of `SCNNode2`s.
class TimeAttributes
{
    /// Initializer.
    /// - Parameter ForDay: Determines if the attributes are for day time or night time.
    /// - Parameter Diffuse: The color to apply as the diffuse material.
    /// - Parameter Emission: The color to apply as the emission material. Defaults to `nil`.
    /// - Parameter ApplyTo: A node to apply the passed values to. Defaults to `nil` meaning no action is taken.
    init(ForDay: Bool, Diffuse: UIColor, Emission: UIColor? = nil, ApplyTo: SCNNode2? = nil)
    {
        IsForDay = ForDay
        self.Diffuse = Diffuse
        self.Emission = Emission
        if let OnNode = ApplyTo
        {
            self.ApplyTo(OnNode)
        }
    }
    
    /// Initializer.
    /// - Parameter ForDay: Determines if the attributes are for day time or night time.
    /// - Parameter Diffuse: The color to apply as the diffuse material.
    /// - Parameter Specular: The color to apply as the specular material.
    /// - Parameter Emission: The color to apply as the emission material. Defaults to `nil`.
    /// - Parameter ApplyTo: A node to apply the passed values to. Defaults to `nil` meaning no action is taken.
    init(ForDay: Bool, Diffuse: UIColor, Specular: UIColor, Emission: UIColor? = nil, ApplyTo: SCNNode2? = nil)
    {
        IsForDay = ForDay
        self.Diffuse = Diffuse
        self.Specular = Specular
        self.Emission = Emission
        if let OnNode = ApplyTo
        {
            self.ApplyTo(OnNode)
        }
    }
    
    /// Day flag. If true, the values are applied during the day. If false, the values are applied during the night.
    var IsForDay: Bool = true
    
    /// Diffuse material color. Defaults to `.white`.
    var Diffuse: UIColor = UIColor.white
    
    /// Second diffuse material color.
    var Diffuse2: UIColor? = nil
    
    /// Specular material color. Defaults to `.white`.
    var Specular: UIColor = UIColor.white
    
    /// Second specular material color.
    var Specular2: UIColor? = nil
    
    /// Emission color. Nil disables emission.
    var Emission: UIColor? = nil
    
    /// Second emission color. Nil disables emission.
    var Emission2: UIColor? = nil
    
    /// Lighting model. Defaults to `.phong`.
    var Model: SCNMaterial.LightingModel = .phong
    
    /// Apply the current values to the passed node.
    /// - Parameter Node: An instance of `SCNNode2` to apply the values to. Also sets the node's
    ///                   `CanSwitchState` flag to `true`.
    func ApplyTo(_ Node: SCNNode2)
    {
        Node.CanSwitchState = true
        Node.SetState(ForDay: IsForDay, Color: Diffuse, Specular: Specular, Emission: Emission, Model: Model)
    }
}
