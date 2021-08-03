//
//  +Attract.swift
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
    // MARK: - Attract mode
    
    /// Set or reset attract mode depending on the current user settings.
    public func SetAttractMode()
    {
        if Settings.GetBool(.InAttractMode)
        {
            EarthNode?.removeAllActions()
            SeaNode?.removeAllActions()
            LineNode?.removeAllActions()
            HourNode?.removeAllActions()
            for (_, Layer) in StencilLayers
            {
                Layer.removeAllActions()
            }
            StopClock()
            AttractEarth()
        }
        else
        {
            EarthNode?.removeAllActions()
            SeaNode?.removeAllActions()
            LineNode?.removeAllActions()
            HourNode?.removeAllActions()
            for (_, Layer) in StencilLayers
            {
                Layer.removeAllActions()
            }
            StartClock()
        }
    }
    
    /// Display the globe in attract mode.
    func AttractEarth()
    {
        let Rotate = SCNAction.rotateBy(x: 0.0, y: CGFloat(360.0.Radians), z: 0.0,
                                        duration: Defaults.AttractRotationDuration.rawValue)
        let RotateForever = SCNAction.repeatForever(Rotate)
        EarthNode?.runAction(RotateForever)
        SeaNode?.runAction(RotateForever)
        LineNode?.runAction(RotateForever)
        for (_, Layer) in StencilLayers
        {
            Layer.runAction(RotateForever)
        }
        if Settings.GetEnum(ForKey: .HourType, EnumType: HourTypes.self, Default: .None) == .RelativeToLocation
        {
            HourNode?.runAction(RotateForever)
        }
    }
}
