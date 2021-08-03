//
//  SCNTriangleRing.swift
//  Flatland
//
//  Created by Stuart Rankin on 7/15/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit
import SceneKit

/// Implements a ring of triangles.
class SCNTriangleRing: SCNNode2
{
    /// The minimum number of triangles.
    public static let MinimumTriangleCount: Int = 4
    
    /// The maximum number of triangles.
    public static let MaximumTriangleCount: Int = 20
    
    /// Default initializer.
    override init()
    {
        super.init()
        MakeGeometry()
    }
    
    /// Initializer.
    /// - Parameter Count: Number of triangles.
    /// - Parameter Inner: The inner radius.
    /// - Parameter Outer: The outer radius.
    /// - Parameter Extrusion: The extrusion of each triangle.
    /// - Parameter Mask: The light mask.
    init(Count: Int, Inner: CGFloat, Outer: CGFloat, Extrusion: CGFloat, Mask: Int)
    {
        super.init()
        _Extrusion = Extrusion
        _LightMask = Mask
        _InnerRadius = Inner
        _OuterRadius = Outer
        _TriangleCount = Count
        MakeGeometry()
    }
    
    /// Initializer.
    /// - Parameter coder: See Apple documentation.
    required init?(coder: NSCoder)
    {
        super.init(coder: coder)
        MakeGeometry()
    }
    
    /// Holds the points out value.
    private var _PointsOut: Bool = true
    {
        didSet
        {
            MakeGeometry()
        }
    }
    /// Get or set the triangle points out flag.
    public var PointsOut: Bool
    {
        get
        {
            return _PointsOut
        }
        set
        {
            _PointsOut = newValue
        }
    }
    
    /// Holds the triangle count.
    private var _TriangleCount: Int = 5
    {
        didSet
        {
            MakeGeometry()
        }
    }
    /// Get or set the triangle count.
    public var TriangleCount: Int
    {
        get
        {
            return _TriangleCount
        }
        set
        {
            var FinalCount = min(newValue, SCNTriangleRing.MaximumTriangleCount)
            FinalCount = max(FinalCount, SCNTriangleRing.MinimumTriangleCount)
            _TriangleCount = FinalCount
        }
    }
    
    /// Holds the inner radius value.
    private var _InnerRadius: CGFloat = 1.0
    {
        didSet
        {
            MakeGeometry()
        }
    }
    /// Get or set the inner radius value.
    public var InnerRadius: CGFloat
    {
        get
        {
            return _InnerRadius
        }
        set
        {
            if newValue >= _OuterRadius
            {
                fatalError("InnerRadius value must be less than OuterRadius value.")
            }
            _InnerRadius = newValue
        }
    }
    
    /// Holds the outer radius value.
    private var _OuterRadius: CGFloat = 2.0
    {
        didSet
        {
            MakeGeometry()
        }
    }
    /// Get or set the outer radius value.
    public var OuterRadius: CGFloat
    {
        get
        {
            return _OuterRadius
        }
        set
        {
            if newValue <= _InnerRadius
            {
                fatalError("OuterRaidus value must be greater than InnerRadius value.")
            }
            _OuterRadius = newValue
        }
    }
    
    /// Holds the depth of the triangle.
    private var _Extrusion: CGFloat = 0.1
    {
        didSet
        {
            MakeGeometry()
        }
    }
    /// Get or set the depth of the triangle.
    public var Extrusion: CGFloat
    {
        get
        {
            return _Extrusion
        }
        set
        {
            _Extrusion = newValue
        }
    }
    
    /// Holds the color of the diffuse surface of the triangle.
    private var _Color: UIColor = UIColor.systemYellow
    {
        didSet
        {
            MakeGeometry()
        }
    }
    /// Get or set the color of the diffuse surface of the triangle.
    public var Color: UIColor
    {
        get
        {
            return _Color
        }
        set
        {
            _Color = newValue
        }
    }
    
    /// Holds the color of the specular surface of the triangle.
    private var _Specular: UIColor = UIColor.white
    {
        didSet
        {
            MakeGeometry()
        }
    }
    /// Get or set the color of the specular surface of the triangle.
    public var Specular: UIColor
    {
        get
        {
            return _Specular
        }
        set
        {
            _Specular = newValue
        }
    }
    
    /// Holds the light mask value.
    private var _LightMask: Int = 0
    {
        didSet
        {
            MakeGeometry()
        }
    }
    /// Get or set the category light mask value.
    public var LightMask: Int
    {
        get
        {
            return _LightMask
        }
        set
        {
            _LightMask = newValue
        }
    }
    
    /// Holds the triangle rotation duration in seconds.
    private var _TriangleRotationDuration: Double = 0.0
    {
        didSet
        {
            MakeGeometry()
        }
    }
    /// Get or set the triangle rotation duration in seconds.
    public var TriangleRotationDuration: Double
    {
        get
        {
            return _TriangleRotationDuration
        }
        set
        {
            _TriangleRotationDuration = newValue
        }
    }
    
    /// Creates a triangle.
    /// - Parameter Top: The top point.
    /// - Parameter Base1: First base point.
    /// - Parameter Base2: Second base point.
    /// - Returns: Triangle-shaped `SCNNode2` object.
    private func MakeTriangle(Top: CGPoint, Base1: CGPoint, Base2: CGPoint) -> SCNNode2
    {
        let Path = UIBezierPath()
        Path.move(to: Top)
        Path.addLine(to: Base1)
        Path.addLine(to: Base2)
        Path.addLine(to: Top)
        Path.close()
        let Geo = SCNShape(path: Path, extrusionDepth: _Extrusion)
        let GeoNode = SCNNode2(geometry: Geo)
        GeoNode.categoryBitMask = _LightMask
        let NodeColor = _Color
        let NodeSpecular = _Specular
        GeoNode.geometry?.firstMaterial?.diffuse.contents = NodeColor
        GeoNode.geometry?.firstMaterial?.specular.contents = NodeSpecular
        GeoNode.geometry?.firstMaterial?.lightingModel = SCNMaterial.LightingModel.physicallyBased
        return GeoNode
    }
    
    /// Create the geometry for the triangle ring.
    func MakeGeometry()
    {
        for Triangle in self.childNodes
        {
            Triangle.removeAllActions()
            Triangle.removeFromParentNode()
            Triangle.geometry = nil
        }
        if _TriangleCount < 1
        {
            return
        }
        
        var Circumference: CGFloat = 1.0
        var YOffset: CGFloat = 0.0
        var TopValue: CGFloat = 0.0
        if PointsOut
        {
            Circumference = _InnerRadius * 2.0 * CGFloat.pi
            YOffset = _InnerRadius
            TopValue = _OuterRadius
        }
        else
        {
            Circumference = _OuterRadius * 2.0 * CGFloat.pi
            YOffset = _OuterRadius
            TopValue = _InnerRadius
        }
        let Base = Circumference / CGFloat(_TriangleCount)
        for Count in 0 ..< _TriangleCount
        {
            let Triangle = MakeTriangle(Top: CGPoint(x: 0.0, y: TopValue),
                                        Base1: CGPoint(x: -Base / 2.0, y: YOffset),
                                        Base2: CGPoint(x: Base / 2.0, y: YOffset))
            Triangle.position = SCNVector3(0.0, 1.0, 0.0)
            if _TriangleRotationDuration > 0.0
            {
                let Rotation = SCNAction.rotateBy(x: CGFloat(0.0.Radians),
                                                  y: CGFloat(360.0.Radians),
                                                  z: CGFloat(0.0.Radians),
                                                  duration: _TriangleRotationDuration)
                let Forever = SCNAction.repeatForever(Rotation)
                Triangle.runAction(Forever)
            }
            let Angle = (CGFloat(Count) / CGFloat(_TriangleCount)) * 360.0
            Triangle.eulerAngles = SCNVector3(0.0, 0.0, Angle.Radians) 
            self.addChildNode(Triangle)
        }
        self.position = SCNVector3(0.8, 0.4, 0.0)
    }
}
