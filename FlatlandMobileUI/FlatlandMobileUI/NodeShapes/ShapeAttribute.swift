//
//  ShapeAttribute.swift
//  Flatland
//
//  Created by Stuart Rankin on 10/18/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit
import SceneKit

/// Protocol for setting shape attributes.
protocol ShapeAttribute: AnyObject
{
    /// Sets the first diffuse material to the specified color.
    /// - Parameter Color: The color to use to set the first diffuse material.
    func SetMaterialColor(_ Color: UIColor)
    
    /// Sets the first diffuse material to the specified texture.
    /// - Parameter Image: The image to use as the texture.
    func SetDiffuseTexture(_ Image: UIImage)
    
    /// Sets the first material's emission color.
    /// - Parameter Color: The color to use to set the first material's emission
    ///                    color. If nil, the color is removed.
    func SetEmissionColor(_ Color: UIColor?)
    
    /// Sets the first material's lighting model.
    /// - Parameter Model: The lighting model to use.
    func SetLightingModel(_ Model: SCNMaterial.LightingModel)
    
    /// Sets the first material's metalness value.
    /// - Parameter Value: The value to use for metalness. If nil, not set.
    func SetMetalness(_ Value: Double?)
    
    /// Sets the first material's roughness value.
    /// - Parameter Value: The value to use for roughness. If nil, not set.
    func SetRoughness(_ Value: Double?)
}
