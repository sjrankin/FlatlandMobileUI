//
//  +NodeState.swift
//  +NodeState
//
//  Created by Stuart Rankin on 7/18/21. Adapted from Flatland View
//

import Foundation
import UIKit
import SceneKit

/// Visual state description for `SCNNode2` states.
struct NodeState
{
    /// Node state.
    let State: NodeStates
    
    /// Diffuse color.
    let Color: UIColor
    
    /// Diffuse surface image. If nil, no image supplied.
    let Diffuse: UIImage?
    
    /// Emission color. If nil, `UIColor.clear` is applied to the emission contents.
    let Emission: UIColor?
    
    /// Specular color.
    let Specular: UIColor?
    
    /// Lighting model.
    let LightModel: SCNMaterial.LightingModel
    
    /// Metalness value. If nil, not used.
    let Metalness: Double?
    
    /// Roughness value. If nil, not used.
    let Roughness: Double?
    
    /// Casts shadow value. If nil, not used.
    let CastsShadow: Bool?
}

/// States for `SCNNode2` instances.
enum NodeStates: String
{
    /// Node is in the daylight.
    case Day = "Day"
    
    // Node is in the dark.
    case Night = "Night"
}
