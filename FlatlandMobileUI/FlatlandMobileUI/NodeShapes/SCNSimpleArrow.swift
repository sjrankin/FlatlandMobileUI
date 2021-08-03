//
//  SCNSimpleArrow.swift
//  Flatland
//
//  Created by Stuart Rankin on 6/14/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit
import SceneKit

/// Implements/creates a simple arrow shape in an `SCNNode2`.
class SCNSimpleArrow: SCNNode2, ShapeAttribute
{
    /// Initializer. Creates a default shape.
    override init()
    {
        super.init()
        self.UseProtocolToSetState = true
        MakeGeometry()
    }
    
    /// Initializer
    /// - Parameters:
    ///   - Length: Overall length of the arrow.
    ///   - Width: Width of the arrow (the arrowhead's width).
    ///   - Extrusion: Depth of the arrow.
    ///   - Color: Color of the diffuse surface of the arrow.
    ///   - Specular: Color of the specular surface of the arrow.
    ///   - LightMask: The light mask to apply to each sub-node of the simple arrow. Defaults to 0.
    ///   - StemChamfer: The stem chamfer radius. Defaults to 0.05.
    init(Length: CGFloat, Width: CGFloat, Extrusion: CGFloat, Color: UIColor = UIColor.systemYellow,
         Specular: UIColor = UIColor.white, LightMask: Int = 0, StemChamfer: Double = 0.05)
    {
        super.init()
        self.UseProtocolToSetState = true
        self.Length = Length
        self.Width = Width
        self.Extrusion = Extrusion
        self.Color = Color
        self.Specular = Specular
        self.LightMask = LightMask
    }
    
    /// Initializer
    /// - Parameters:
    ///   - Length: Overall length of the arrow.
    ///   - Width: Width of the arrow (the arrowhead's width).
    ///   - Extrusion: Depth of the arrow.
    ///   - DiffuseTexture: Image to use for the diffuse surface.
    ///   - Specular: Color of the specular surface of the arrow.
    ///   - LightMask: The light mask to apply to each sub-node of the simple arrow. Defaults to 0.
    ///   - StemChamfer: The stem chamfer radius. Defaults to 0.05.
    init(Length: CGFloat, Width: CGFloat, Extrusion: CGFloat, DiffuseTexture: UIImage,
         Specular: UIColor = UIColor.white, LightMask: Int = 0, StemChamfer: Double = 0.05)
    {
        super.init()
        self.UseProtocolToSetState = true
        self.Length = Length
        self.Width = Width
        self.Extrusion = Extrusion
        self.Color = UIColor.white
        self.DiffuseTexture = DiffuseTexture
        self.Specular = Specular
        self.LightMask = LightMask
    }
    
    /// Initializers. Creates a default shape.
    /// - Parameter coder: See Apple documentation.
    required init?(coder: NSCoder)
    {
        super.init(coder: coder)
        self.UseProtocolToSetState = true
        MakeGeometry()
    }
    
    /// Holds the light mask value.
    private var _LightMask: Int = 0
    {
        didSet
        {
            MakeGeometry()
        }
    }
    /// Get or set the category light mask.
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
    
    /// Holds the length of the arrow.
    private var _Length: CGFloat = 2.0
    {
        didSet
        {
            MakeGeometry()
        }
    }
    /// Get or set the length of the arrow.
    public var Length: CGFloat
    {
        get
        {
            return _Length
        }
        set
        {
            _Length = newValue
        }
    }
    
    /// Holds the width of the arrow.
    private var _Width: CGFloat = 0.8
    {
        didSet
        {
            MakeGeometry()
        }
    }
    /// Get or set the width of the arrow.
    public var Width: CGFloat
    {
        get
        {
            return _Width
        }
        set
        {
            _Width = newValue
        }
    }
    
    /// Holds the depth of the arrow.
    private var _Extrusion: CGFloat = 0.2
    {
        didSet
        {
            MakeGeometry()
        }
    }
    /// Get or set the depth of the arrow.
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
    
    /// Holds the diffuse color.
    private var _Color: UIColor = UIColor.systemYellow
    {
        didSet
        {
            MakeGeometry()
        }
    }
    /// Get or set the color for the diffuse surface.
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
    
    private var _DiffuseTexture: UIImage? = nil
    {
        didSet
        {
            MakeGeometry()
        }
    }
    /// Get or set the diffuse surface texture image.
    public var DiffuseTexture: UIImage?
    {
        get
        {
            return _DiffuseTexture
        }
        set
        {
            _DiffuseTexture = newValue
        }
    }
    
    /// Holds the emission color.
    private var _Emission: UIColor? = nil
    {
        didSet
        {
            MakeGeometry()
        }
    }
    /// Get or set the emission color.
    public var Emission: UIColor?
    {
        get
        {
            return _Emission
        }
        set
        {
            _Emission = newValue
        }
    }
    
    /// Holds the specular color.
    private var _Specular: UIColor = UIColor.white
    {
        didSet
        {
            MakeGeometry()
        }
    }
    /// Get or set the color for the specular surface.
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
    
    /// Holds the lighting model.
    private var _LightingModel: SCNMaterial.LightingModel = .phong
        {
            didSet
            {
                MakeGeometry()
            }
        }
    /// Get or set the lighting model.
    public var LightingModel: SCNMaterial.LightingModel
    {
        get
        {
            return _LightingModel
        }
        set
        {
            _LightingModel = newValue
        }
    }
    
    /// Holds the metalness level.
    private var _Metalness: Double? = nil
    {
        didSet
        {
            MakeGeometry()
        }
    }
    /// Get or set the metalness level.
    public var Metalness: Double?
    {
        get
        {
            return _Metalness
        }
        set
        {
            _Metalness = newValue
        }
    }
    
    /// Holds the roughness level.
    private var _Roughness: Double? = nil
    {
        didSet
        {
            MakeGeometry()
        }
    }
    /// Get or set the roughness level.
    public var Roughness: Double?
    {
        get
        {
            return _Roughness
        }
        set
        {
            _Roughness = newValue
        }
    }
    
    /// Holds the stem chamfer radius.
    private var _StemChamfer: Double = 0.05
    {
        didSet
        {
            MakeGeometry()
        }
    }
    /// Get or set the stem chamfer radius.
    public var StemChamfer: Double
    {
        get
        {
            return _StemChamfer
        }
        set
        {
            _StemChamfer = newValue
        }
    }
    
    /// Create the arrow geometry and add it to `self`.
    func MakeGeometry()
    {
        for Child in self.childNodes
        {
            Child.removeFromParentNode()
            Child.geometry = nil
        }
        Triangle = SCNTriangle(Base: _Width, Height: _Length / 3.0, Extrusion: _Extrusion)
        if let Texture = DiffuseTexture
        {
            Triangle.DiffuseTexture = Texture
        }
        else
        {
            Triangle.Color = _Color
        }
        Triangle.Emission = _Emission
        Triangle.Specular = _Specular
        Triangle.LightMask = _LightMask
        Triangle.Metalness = _Metalness
        Triangle.Roughness = _Roughness
        let Box = SCNBox(width: _Width * 0.25, height: _Length * 0.5, length: _Extrusion,
                         chamferRadius: CGFloat(_StemChamfer))
        if let Texture = DiffuseTexture
        {
            Box.firstMaterial?.diffuse.contents = Texture
        }
        else
        {
            Box.firstMaterial?.diffuse.contents = _Color
        }
        Box.firstMaterial?.emission.contents = _Emission
        Box.firstMaterial?.specular.contents = _Specular
        Box.firstMaterial?.metalness.contents = _Metalness
        Box.firstMaterial?.roughness.contents = _Roughness
        Stem = SCNNode2(geometry: Box)
        Stem.categoryBitMask = _LightMask
        let HCenter = _Width / 2.0
        Stem.position = SCNVector3(HCenter , -0.5, 0.0)
        Arrow = SCNNode2()
        Arrow.position = SCNVector3(-_Width / 2.0, -_Extrusion / 2.0, 0.0)
        Arrow.addChildNode(Triangle)
        Arrow.addChildNode(Stem)
        self.addChildNode(Arrow)
    }
    
    #if true
    override var CanSwitchState: Bool
    {
        get
        {
            return super.CanSwitchState
        }
        set
        {
            super.CanSwitchState = newValue
            Arrow.CanSwitchState = true
            Triangle.CanSwitchState = true
            Stem.CanSwitchState = true
        }
    }
    #endif
    
    var Triangle = SCNTriangle()
    var Stem = SCNNode2()
    var Arrow = SCNNode2()
    
    // MARK: - Shape attributes.
    
    func SetMaterialColor(_ Color: UIColor)
    {
        self.Color = Color
    }
    
    func SetEmissionColor(_ Color: UIColor?)
    {
        self.Emission = Color
    }
    
    func SetDiffuseTexture(_ Image: UIImage)
    {
        self.DiffuseTexture = Image
    }
    
    func SetLightingModel(_ Model: SCNMaterial.LightingModel)
    {
        self.LightingModel = Model
    }
    
    func SetMetalness(_ Value: Double?)
    {
        self.Metalness = Value
    }
    
    func SetRoughness(_ Value: Double?)
    {
        self.Roughness = Value
    }
}
