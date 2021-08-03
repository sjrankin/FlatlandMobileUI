//
//  +SimpleShapes.swift
//  Flatland
//
//  Created by Stuart Rankin on 10/19/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit
import SceneKit

extension ShapeManager
{
    // MARK: - Functions to create simple shapes
    
    /// Creates a sphere-shaped node.
    /// - Parameter With: The size of the sphere to create.
    /// - Parameter OtherID: If nil, the standard ID is used for the sub-component field. If not-nil this
    ///                      value is used as the sub-component ID instead.
    /// - Returns: `SCNNode2` with the specified shape.
    public static func CreateSphere(With Size: Sizes, OtherID: UUID? = nil) -> SCNNode2
    {
        let Sphere = SCNSphere(radius: CGFloat(Size.Radius))
        let SphereNode = SCNNode2(geometry: Sphere)
        if let NonStandardID = OtherID
        {
            SphereNode.SubComponent = NonStandardID
        }
        else
        {
            SphereNode.SubComponent = ShapeParts.Value(.Sphere)
        }
        return SphereNode
    }
    
    /// Creates a box-shaped node.
    /// - Parameter With: The size of the box to create.
    /// - Parameter OtherID: If nil, the standard ID is used for the sub-component field. If not-nil this
    ///                      value is used as the sub-component ID instead.
    /// - Returns: `SCNNode2` with the specified shape.
    public static func CreateBox(With Size: Sizes, OtherID: UUID? = nil) -> SCNNode2
    {
        let Box = SCNBox(width: CGFloat(Size.Width),
                         height: CGFloat(Size.Height),
                         length: CGFloat(Size.Length),
                         chamferRadius: CGFloat(Size.ChamferRadius))
        let BoxNode = SCNNode2(geometry: Box)
        if let NonStandardID = OtherID
        {
            BoxNode.SubComponent = NonStandardID
        }
        else
        {
            BoxNode.SubComponent = ShapeParts.Value(.Box)
        }
        return BoxNode
    }
    
    /// Creates a cylinder-shaped node.
    /// - Parameter With: The size of the cylinder to create.
    /// - Parameter OtherID: If nil, the standard ID is used for the sub-component field. If not-nil this
    ///                      value is used as the sub-component ID instead.
    /// - Returns: `SCNNode2` with the specified shape.
    public static func CreateCylinder(With Size: Sizes, OtherID: UUID? = nil) -> SCNNode2
    {
        let Cylinder = SCNCylinder(radius: CGFloat(Size.Radius), height: CGFloat(Size.Height))
        let CylinderNode = SCNNode2(geometry: Cylinder)
        if let NonStandardID = OtherID
        {
            CylinderNode.SubComponent = NonStandardID
        }
        else
        {
            CylinderNode.SubComponent = ShapeParts.Value(.Cylinder)
        }
        return CylinderNode
    }
    
    /// Creates a cone-shaped node.
    /// - Parameter With: The size of the cone to create.
    /// - Parameter OtherID: If nil, the standard ID is used for the sub-component field. If not-nil this
    ///                      value is used as the sub-component ID instead.
    /// - Returns: `SCNNode2` with the specified shape.
    public static func CreateCone(With Size: Sizes, OtherID: UUID? = nil) -> SCNNode2
    {
        let Cone = SCNCone(topRadius: CGFloat(Size.TopRadius),
                           bottomRadius: CGFloat(Size.BottomRadius),
                           height: CGFloat(Size.Height))
        let ConeNode = SCNNode2(geometry: Cone)
        if let NonStandardID = OtherID
        {
            ConeNode.SubComponent = NonStandardID
        }
        else
        {
            ConeNode.SubComponent = ShapeParts.Value(.Cone)
        }
        return ConeNode
    }
    
    /// Creates a capsule-shaped node.
    /// - Parameter With: The size of the capsule to create.
    /// - Parameter OtherID: If nil, the standard ID is used for the sub-component field. If not-nil this
    ///                      value is used as the sub-component ID instead.
    /// - Returns: `SCNNode2` with the specified shape.
    public static func CreateCapsule(With Size: Sizes, OtherID: UUID? = nil) -> SCNNode2
    {
        let Capsule = SCNCapsule(capRadius: CGFloat(Size.Radius), height: CGFloat(Size.Height))
        let CapsuleNode = SCNNode2(geometry: Capsule)
        if let NonStandardID = OtherID
        {
            CapsuleNode.SubComponent = NonStandardID
        }
        else
        {
            CapsuleNode.SubComponent = ShapeParts.Value(.Capsule)
        }
        return CapsuleNode
    }
    
    /// Creates a pyramid-shaped node.
    /// - Parameter With: The size of the pyramid to create.
    /// - Parameter OtherID: If nil, the standard ID is used for the sub-component field. If not-nil this
    ///                      value is used as the sub-component ID instead.
    /// - Returns: `SCNNode2` with the specified shape.
    public static func CreatePyramid(With Size: Sizes, OtherID: UUID? = nil) -> SCNNode2
    {
        let Pyramid = SCNPyramid(width: CGFloat(Size.Width), height: CGFloat(Size.Height),
                                 length: CGFloat(Size.Length))
        let PyramidNode = SCNNode2(geometry: Pyramid)
        if let NonStandardID = OtherID
        {
            PyramidNode.SubComponent = NonStandardID
        }
        else
        {
            PyramidNode.SubComponent = ShapeParts.Value(.Pyramid)
        }
        return PyramidNode
    }
    
    /// Creates a torus-shaped node.
    /// - Parameter With: The size of the torus to create.
    /// - Parameter OtherID: If nil, the standard ID is used for the sub-component field. If not-nil this
    ///                      value is used as the sub-component ID instead.
    /// - Returns: `SCNNode2` with the specified shape.
    public static func CreateTorus(With Size: Sizes, OtherID: UUID? = nil) -> SCNNode2
    {
        let Torus = SCNTorus(ringRadius: CGFloat(Size.RingRadius), pipeRadius: CGFloat(Size.PipeRadius))
        let TorusNode = SCNNode2(geometry: Torus)
        if let NonStandardID = OtherID
        {
            TorusNode.SubComponent = NonStandardID
        }
        else
        {
            TorusNode.SubComponent = ShapeParts.Value(.Torus)
        }
        return TorusNode
    }
    
    /// Creates a tube-shaped node.
    /// - Parameter With: The size of the tube to create.
    /// - Parameter OtherID: If nil, the standard ID is used for the sub-component field. If not-nil this
    ///                      value is used as the sub-component ID instead.
    /// - Returns: `SCNNode2` with the specified shape.
    public static func CreateTube(With Size: Sizes, OtherID: UUID? = nil) -> SCNNode2
    {
        let Tube = SCNTube(innerRadius: CGFloat(Size.InnerRadius),
                           outerRadius: CGFloat(Size.OuterRadius),
                           height: CGFloat(Size.Height))
        let TubeNode = SCNNode2(geometry: Tube)
        if let NonStandardID = OtherID
        {
            TubeNode.SubComponent = NonStandardID
        }
        else
        {
            TubeNode.SubComponent = ShapeParts.Value(.Tube)
        }
        return TubeNode
    }
    
    /// Creates a regular polygon node.
    /// - Parameter With: The size of the polygon to create.
    /// - Parameter OtherID: If nil, the standard ID is used for the sub-component field. If not-nil this
    ///                      value is used as the sub-component ID instead.
    /// - Returns: `SCNNode2` with the specified shape.
    public static func CreatePolygon(With Size: Sizes, OtherID: UUID? = nil) -> SCNNode2
    {
        let Polygon = SCNRegular.Geometry(VertexCount: Size.VertexCount,
                                          Radius: CGFloat(Size.Radius),
                                          Depth: CGFloat(Size.Depth))
        let PolyNode = SCNNode2(geometry: Polygon)
        if let NonStandardID = OtherID
        {
            PolyNode.SubComponent = NonStandardID
        }
        else
        {
            PolyNode.SubComponent = ShapeParts.Value(.Polygon)
        }
        return PolyNode
    }
    
    /// Creates a star node.
    /// - Parameter With: The size of the star to create.
    /// - Parameter OtherID: If nil, the standard ID is used for the sub-component field. If not-nil this
    ///                      value is used as the sub-component ID instead.
    /// - Returns: `SCNNode2` with the specified shape.
    public static func CreateStar(With Size: Sizes, OtherID: UUID? = nil) -> SCNNode2
    {
        let Star = SCNStar.Geometry(VertexCount: Size.VertexCount, Height: Size.Height, Base: Size.Base,
                                    ZHeight: Size.ZHeight)
        let StarNode = SCNNode2(geometry: Star)
        if let NonStandardID = OtherID
        {
            StarNode.SubComponent = NonStandardID
        }
        else
        {
            StarNode.SubComponent = ShapeParts.Value(.Star) 
        }
        return StarNode
    }
}
