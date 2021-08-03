//
//  +Orbits.swift
//  Flatland
//
//  Created by Stuart Rankin on 6/10/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit
import SceneKit

extension GlobeView
{
    // MARK: - Orbital item plotting
    
    func PlotOrbits()
    {
        
    }
}

class OrbitalObject
{
    var StartingAngle: Double = 0.0
    /// Mean orbital radius of the orbit in terms of the radius of the main body.
    var MeanRadius: Double = 1.1
    var Name: String = ""
    var A: Double = 1.0
    var ASquared: Double
    {
        get
        {
            return A * A
        }
    }
    var B: Double = 0.5
    var BSquared: Double
    {
        get
        {
            return B * B
        }
    }
    var ATimesB: Double
    {
        get
        {
            return A * B
        }
    }
    var Declination: Double = 0.0
    
    func Shape() -> SCNNode
    {
        return SCNNode2()
    }
    
    //https://en.wikipedia.org/wiki/Orbital_speed
    public static func GetOrbitalVelocity(For Orbital: OrbitalObject) -> Double
    {
        return 0.0
    }
    
    //https://math.stackexchange.com/questions/22064/calculating-a-point-that-lies-on-an-ellipse-given-an-angle
    public static func GetCoordinatesAt(Angle: Double, In Ellipse: OrbitalObject) -> (Double, Double)
    {
        let Radians = Angle.Radians
        let SquaredTanRadian = tan(Radians) * tan(Radians)
        let X = Ellipse.ATimesB / sqrt(Ellipse.BSquared + Ellipse.ASquared * SquaredTanRadian)
        let Y = Ellipse.ATimesB / sqrt(Ellipse.ASquared + (Ellipse.BSquared / SquaredTanRadian))
        return (X, Y)
    }
}
