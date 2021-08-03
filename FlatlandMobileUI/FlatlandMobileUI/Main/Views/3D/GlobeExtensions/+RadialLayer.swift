//
//  +RadialLayer.swift
//  Flatland
//
//  Created by Stuart Rankin on 2/2/21.
//  Copyright © 2021 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit
import SceneKit

/// Class to hold radial region information and infrastructure.
class RadialLayer
{
    /// Get or set the region's ID.
    var RegionID: UUID = UUID.Empty
    
    /// Get or set the region's shape layer.
    var Overlay: CAShapeLayer? = nil
    
    /// Get or set the region's containing node.
    var ContainingNode: SCNNode2? = nil
}
