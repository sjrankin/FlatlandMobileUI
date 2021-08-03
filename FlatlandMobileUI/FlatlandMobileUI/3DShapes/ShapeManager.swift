//
//  ShapeManager.swift
//  Flatland
//
//  Created by Stuart Rankin on 10/19/20.
//  Copyright © 2020, 2021 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit
import SceneKit

/// Creates shapes for use on maps.
/// - Note: Shapes are not rotated unless explicitly told to do so.
class ShapeManager
{
    /// Creates and returns a simple shape populated by the passed set of attributes.
    /// - Warning: A fatal error is thrown if `Shape` is a composite shape. See `IsComposite` to determine
    ///            the type of shape.
    /// - Warning: A fatal error is thrown if the diffuse material type is image but no image name is specified.
    /// - Parameter Shape: The shape to create.
    /// - Parameter Attributes: The attributes to use to create the shape.
    /// - Parameter Latitude: The latitude of the shape.
    /// - Parameter Longitude: The longitude of the shape.
    /// - Returns: The shape.
    public static func Create(_ Shape: Shapes, Attributes: ShapeAttributes, Latitude: Double? = nil, Longitude: Double? = nil) -> SCNNode2
    {
        if IsComposite(Shape)
        {
            fatalError("Incorrect shape \(Shape) passed to \(#function)")
        }
        var BaseNode = SCNNode2()
        switch Shape
        {
            case .Polygon:
                BaseNode = CreatePolygon(With: Attributes.ShapeSize)
                
            case .Star, .InnerStar:
                BaseNode = CreateStar(With: Attributes.ShapeSize)
                
            case .Box:
                BaseNode = CreateBox(With: Attributes.ShapeSize)
                
            case .Cone:
                BaseNode = CreateCone(With: Attributes.ShapeSize)
                
            case .Cylinder:
                BaseNode = CreateCylinder(With: Attributes.ShapeSize)
                
            case .Pyramid:
                BaseNode = CreatePyramid(With: Attributes.ShapeSize)
                
            case .Sphere:
                BaseNode = CreateSphere(With: Attributes.ShapeSize)
                
            case .Torus:
                BaseNode = CreateTorus(With: Attributes.ShapeSize)
                
            case .Tube:
                BaseNode = CreateTube(With: Attributes.ShapeSize)
                
            case .Capsule:
                BaseNode = CreateCapsule(With: Attributes.ShapeSize)
                
            default:
                fatalError("Unexpected shape \(Shape) encountered in \(#function)")
        }
        BaseNode.Latitude = Latitude
        BaseNode.Longitude = Longitude
        BaseNode.NodeClass = Attributes.Class
        BaseNode.NodeID = Attributes.ID
        BaseNode.CanShowBoundingShape = Attributes.ShowBoundingShapes
        if let Latitude = Attributes.Latitude, let Longitudes = Attributes.Longitude
        {
            BaseNode.SetLocation(Latitude, Longitudes)
        }
        switch Attributes.DiffuseType
        {
            case .Color:
                BaseNode.geometry?.firstMaterial?.diffuse.contents = Attributes.DiffuseColor
                BaseNode.geometry?.firstMaterial?.metalness.contents = Attributes.Metalness
                BaseNode.geometry?.firstMaterial?.roughness.contents = Attributes.Roughness
                
            case .Image:
                if let ImageName = Attributes.DiffuseMaterial
                {
                    BaseNode.geometry?.firstMaterial?.diffuse.contents = UIImage(named: ImageName)
                }
                else
                {
                    fatalError("Image name not available even though image specified for diffuse contents in \(#function)")
                }
        }
        if Attributes.AttributesChange && Attributes.DayState != nil && Attributes.NightState != nil
        {
            BaseNode.CanSwitchState = true
            BaseNode.NightState = Attributes.NightState!.EmitNodeState(For: .Night)
            BaseNode.DayState = Attributes.DayState!.EmitNodeState(For: .Day)
            if let IsDay = Solar.IsInDaylight(BaseNode.Latitude!, BaseNode.Longitude!)
            {
                BaseNode.IsInDaylight = IsDay
                if IsDay
                {
                    BaseNode.geometry?.firstMaterial?.diffuse.contents = Attributes.DayState!.Color
                }
                else
                {
                    BaseNode.geometry?.firstMaterial?.diffuse.contents = Attributes.NightState!.Color
                }
            }
        }
        else
        {
            BaseNode.CanSwitchState = false
            BaseNode.geometry?.firstMaterial?.lightingModel = Attributes.LightingModel
            BaseNode.geometry?.firstMaterial?.specular.contents = Attributes.SpecularColor
            if let Emission = Attributes.EmissionColor
            {
                BaseNode.geometry?.firstMaterial?.emission.contents = Emission
            }
        }
        if let Mask = Attributes.LightMask
        {
            BaseNode.categoryBitMask = Mask
        }
        BaseNode.scale = SCNVector3(Attributes.Scale, Attributes.Scale, Attributes.Scale)
        BaseNode.eulerAngles = SCNVector3(Attributes.EulerX, Attributes.EulerY, Attributes.EulerZ)
        if let Position = Attributes.Position
        {
            BaseNode.position = Position
        }
        return BaseNode
    }
    
    /// Creates and returns a composite shape.
    /// - Warning: A fatal error is thrown if a non-composite shape is passed to this function. See
    ///            `IsComposite` for information on how to determine shape types.
    /// - Parameter Shape: The composite shape to create.
    /// - Parameter Composite: Data on sub-components of the composite shape. It is assume the caller sets
    ///                        the location of each sub-shape prior to calling this function.
    /// - Parameter BaseAttributes: Attributes that apply to the overall node containing the sub-shapes.
    /// - Returns: `SCNNode2` object populated with sub-shapes making up the composite shape.
    public static func Create(_ Shape: Shapes, Composite: CompositeComponents,
                              BaseAttributes: ShapeAttributes) -> SCNNode2
    {
        if !IsComposite(Shape)
        {
            fatalError("Incorrect shape \(Shape) passed to \(#function)")
        }
        
        let BaseNode = SCNNode2()
        BaseNode.CanShowBoundingShape = BaseAttributes.ShowBoundingShapes
        BaseNode.NodeID = BaseAttributes.ID
        BaseNode.NodeClass = BaseAttributes.Class
        BaseNode.CanSwitchState = BaseAttributes.AttributesChange
        
        for (Shape, Attributes) in Composite.Attributes
        {
            let SubComponent = Create(Shape, Attributes: Attributes)
            BaseNode.addChildNode(SubComponent)
        }
        
        BaseNode.scale = SCNVector3(BaseAttributes.Scale, BaseAttributes.Scale, BaseAttributes.Scale)
        if let Location = BaseAttributes.Position
        {
            BaseNode.position = Location
        }
        BaseNode.eulerAngles = SCNVector3(BaseAttributes.EulerX, BaseAttributes.EulerY, BaseAttributes.EulerZ)
        
        return BaseNode
    }
    
    /// Determines if the passed shape is composite or simple.
    /// - Parameter Shape: The shape to verify for compositeness.
    /// - Returns: True if `Shape` is a composite shape, false if not.
    public static func IsComposite(_ Shape: Shapes) -> Bool
    {
        return CompositeShapes.contains(Shape)
    }
    
    /// Array of composite shapes.
    public static let CompositeShapes: [Shapes] =
    [
        .EmbeddedStar, .FloatingBox, .FloatingSphere, .Pin, .Pole, .Flag,
        .Gnomon
    ]
}

/// Shape sub-component IDs.
enum ShapeParts: String, CaseIterable
{
    /// Sphere shape.
    case Sphere = "c9a05ed9-2dbb-49e6-8e8e-32dd9feaae20"
    /// Box shape.
    case Box = "e3e084ae-f2ac-413f-99d9-39665b05bf58"
    /// Triangle shape.
    case Triangle = "119a3145-4a90-4644-a762-118d9f10abca"
    /// Cone shape.
    case Cone = "17f4b413-3a49-450b-adf4-24fc0916d417"
    /// Capsule shape.
    case Capsule = "ed6ba889-b9e0-498b-beee-fd71ecd3d8d6"
    /// Cylinder shape.
    case Cylinder = "3b539b30-377e-434e-a9cd-7fb9be3bbe39"
    /// Torus shape.
    case Torus = "04ed8d7f-b792-4ef3-9c53-a95bb1a0699c"
    /// Pyramid shape.
    case Pyramid = "5e39674d-771f-451a-8cee-91bdc7f4f767"
    /// Tube shape.
    case Tube = "dcb1f4c7-3667-421c-87d5-d704851ada53"
    /// Regular polygon.
    case Polygon = "e3230570-786d-487d-b14d-5ed61d5225f4"
    /// Regular star shape.
    case Star = "9a0e8d12-d7e7-4ab6-965f-0e880b3fa338"
    
    /// Returns the UUID value of the passed `ShapePart`. `UUID.Empty` is returned if the shape part
    /// value cannot be property converted.
    static func Value(_ Part: ShapeParts) -> UUID
    {
        if let Actual = UUID(uuidString: Part.rawValue)
        {
            return Actual
        }
        else
        {
            return UUID.Empty
        }
    }
}

/// Attributes for shapes.
class ShapeAttributes
{
    /// If present, the ID of the sub-node of the overall shape. Attributes here are applied to only those
    /// sub-nodes with this ID.
    var SubComponentID: UUID? = nil
    
    /// Determines the size of the shape.
    var ShapeSize: Sizes = Sizes()
    
    /// If present, the ID of the node to enable it to participate in the user-interaction system. Defaults to
    /// nil.
    var ID: UUID? = nil
    
    /// If present, the class ID of the node to enable it to participate in the user-interaction system.
    /// Defaults to `nil`.
    var Class: UUID? = nil
    
    /// The scale of the node. Defaults to `1.0`.
    var Scale: Double = 1.0
    
    /// If present, the category bit mask for the node. If not present, nothing is assigned.
    /// Defaults to `nil`.
    var LightMask: Int? = nil
    
    /// Show bounding shapes. Defaults to `false`.
    var ShowBoundingShapes: Bool = false
    
    /// The bounding shape to indicate a node in the user interaction system. If nil, no shapes are shown.
    /// Defaults to `nil`.
    var ShowBoundingShape: NodeBoundingShapes? = nil
    
    /// Flag that tells the Dark Clock that a given node can change depending on the local daylight.
    /// Defaults to `false`.
    var AttributesChange: Bool = false
    
    /// If present, the visual attributes for the day state. Defaults to `nil`.
    var DayState: TimeState? = nil
    
    /// If present, the visual attributes for the night state. Defaults to `nil`.
    var NightState: TimeState? = nil
    
    /// Cast shadow flag. Defaults to `true`.
    var CastsShadow: Bool = true

    /// Determines whether to use the color or image name when creating the diffuse surface contents.
    var DiffuseType: DiffuseMaterialTypes = .Color
    
    /// The node's diffuse material name for non-time changing nodes.
    var DiffuseMaterial: String? = nil
    
    /// The node's diffuse material color for non-time changing nodes.
    var DiffuseColor: UIColor = UIColor.red
    
    /// The node's specular material color for non-time changing nodes.
    var SpecularColor: UIColor = UIColor.white
    
    /// If present, the emission color (eg, glow color) of the node. If not present, the node will not glow.
    /// This is used only when the node does not change attributes depending on the time of day.
    var EmissionColor: UIColor? = nil
    
    /// Metalness value for non-changing contents.
    var Metalness: Double? = nil
    
    /// Roughness value for non-changing contents.
    var Roughness: Double? = nil
    
    /// If present, the latitude of the real-world position of the shape. Defaults to `nil`.
    var Latitude: Double? = nil
    
    /// If present, the longitude of the real-world position of the shape. Defaults to `nil`.
    var Longitude: Double? = nil
    
    /// The lighting model.
    var LightingModel: SCNMaterial.LightingModel = .phong
    
    /// Euler X axis value for orientation. *Must be in radians*.
    var EulerX: Double = 0.0
    
    /// Euler Y axis value for orientation. *Must be in radians*.
    var EulerY: Double = 0.0
    
    /// Euler Z axis value for orientation. *Must be in radians*.
    var EulerZ: Double = 0.0
    
    /// If present, the location assigned to the node before being returned. If not present, no location/position
    /// is assigned.
    var Position: SCNVector3? = nil
}

/// Contains sizes and attributes for composite shapes.
class CompositeComponents
{
    /// Shape to size map.
    var Size: [Shapes: Sizes] = [Shapes: Sizes]()
    
    /// Shape to attribute map.
    var Attributes: [Shapes: ShapeAttributes] = [Shapes: ShapeAttributes]()
}

enum DiffuseMaterialTypes: String, CaseIterable
{
    case Color = "Color"
    case Image = "Image"
}

/// Holds the time state for nodes. Enables changing some attributes based on whether the node is in the day
/// or in the night.
class TimeState
{
    /// Day/night state.
    var State: NodeStates? = nil
    /// Determines if the nodes if for daylight or nighttime.
    var IsDayState: Bool = true
    /// Color of the node.
    var Color: UIColor = UIColor.white
    /// Emission color of the node.
    var Emission: UIColor? = nil
    /// Specular color of the node.
    var Specular: UIColor = UIColor.white
    /// Lighting mode for the node.
    var LightingModel: SCNMaterial.LightingModel = .phong
    /// Metalness value of the node (for physically-based rendering).
    var Metalness: Double? = nil
    /// Roughness value of the node (for physically-based rendering).
    var Roughness: Double? = nil
    /// The texture for the diffuse surface.
    var DiffuseTexture: UIImage? = nil
    /// The casts shadow flag.
    var CastsShadow: Bool? = nil
    
    /// Returns a node state based on current conditions.
    /// - Parameter For: The node state type.
    /// - Returns: Node state.
    func EmitNodeState(For State: NodeStates) -> NodeState
    {
        let EmitMe = NodeState(State: State, Color: Color, Diffuse: DiffuseTexture, Emission: Emission, 
                               Specular: Specular, LightModel: LightingModel, Metalness: Metalness,
                               Roughness: Roughness, CastsShadow: CastsShadow)
        return EmitMe
    }
}

/// Holds various dimensions for shapes to create. The same field may be used by different shapes.
class Sizes
{
    var Width: Double = 0.0
    var Height: Double = 0.0
    var Length: Double = 0.0
    var Base: Double = 0.0
    var Depth: Double = 0.0
    var ZHeight: Double = 0.0
    var VertexCount: Int = 5
    var SideCount: Int = 5
    var TopRadius: Double = 0.0
    var BottomRadius: Double = 0.0
    var Radius: Double = 0.0
    var KnobHeight: Double = 0.0
    var KnobRadius: Double = 0.0
    var PinHeight: Double = 0.0
    var PinRadius: Double = 0.0
    var PoleRadius: Double = 0.0
    var ChamferRadius: Double = 0.0
    var RingRadius: Double = 0.0
    var PipeRadius: Double = 0.0
    var InnerRadius: Double = 0.0
    var OuterRadius: Double = 0.0
}

enum Shapes: String, CaseIterable
{
    case Sphere = "Sphere"
    case Box = "Box"
    case Cylinder = "Cylinder"
    case Pyramid = "Pyramid"
    case Cone = "Cone"
    case Capsule = "Capsule"
    case Torus = "Torus"
    case Tube = "Tube"
    case Pin = "Pin"
    case Flag = "Flag"
    case Pole = "Pole"
    case Polygon = "Polygon"
    case Star = "Star"
    case InnerStar = "Inner Star"
    case EmbeddedStar = "Embedded Star"
    case FloatingSphere = "Floating Sphere"
    case FloatingBox = "Floating Box"
    case Gnomon = "Gnomon"
}
