//
//  SCNTriangle.swift
//  FlatlandView
//
//  Created by Stuart Rankin on 6/14/20.
//  Copyright © 2020, 2021 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit
import SceneKit

/// Implements a simple triangle `SCNNode2`.
class SCNTriangle: SCNNode2, ShapeAttribute
{
    /// Initializer. Creates a default triangle.
    override init()
    {
        super.init()
        self.UseProtocolToSetState = true
        MakeGeometry()
    }
    
    /// Initializer. Creates a default triangle.
    /// - Parameter coder: See Apple documentation.
    required init?(coder: NSCoder)
    {
        super.init(coder: coder)
        self.UseProtocolToSetState = true
        MakeGeometry()
    }
    
    /// Initializer based on the shape of the triangle.
    /// - Parameters:
    ///   - Base: Lenght of the base of the triangle.
    ///   - Height: Height of the triangle.
    ///   - Extrusion: Depth of the triangle.
    ///   - Color: Color of the diffuse material.
    ///   - Specular: Color of the specular material.
    ///   - LightMask: The light mask value. Defaults to 0.
    ///   - UseState: Sets the `UseProtocolToSetState` flag.
    init(Base: CGFloat, Height: CGFloat, Extrusion: CGFloat, Color: UIColor = UIColor.systemYellow,
         Specular: UIColor = UIColor.white, LightMask: Int = 0, UseState: Bool = true)
    {
        super.init()
        self.UseProtocolToSetState = UseState
        self.Base = Base
        self.Height = Height
        self.Extrusion = Extrusion
        self.Color = Color
        self.Specular = Specular
        self.LightMask = LightMask
    }
    
    /// Initializer based on the vertices of the triangle.
    /// - Parameters:
    ///   - Vertex1: First vertex.
    ///   - Vertex2: Second vertex.
    ///   - Vertex3: Third vertex.
    ///   - Extrusion: Depth of the triangle.
    ///   - Color: Color of the diffuse material.
    ///   - Specular: Color of the specular material.
    ///   - LightMask: The light mask value. Defaults to 0.
    ///   - UseState: Sets the `UseProtocolToSetState` flag. Defaults to `true`.
    init(Vertex1: CGPoint, Vertex2: CGPoint, Vertex3: CGPoint, Extrusion: CGFloat,
         Color: UIColor = UIColor.systemYellow, Specular: UIColor = UIColor.white,
         LightMask: Int = 0, UseState: Bool = true)
    {
        super.init()
        self.UseProtocolToSetState = UseState
        self.Vertices = [Vertex1, Vertex2, Vertex3]
        self.Extrusion = Extrusion
        self.Color = Color
        self.Specular = Specular
        self.LightMask = LightMask
    }
    
    /// Holds the set of vertices for the triangle.
    private var _Vertices: [CGPoint]? = nil
    {
        didSet
        {
            MakeGeometryWithVertices()
        }
    }
    /// Get or set the triangle's vertices.
    /// - Warning: If the number of points in the passed array is not 3, a fatal error will be thrown.
    public var Vertices: [CGPoint]?
    {
        get
        {
            return _Vertices
        }
        set
        {
            if let Raw = newValue
            {
                if Raw.count != 3
                {
                    Debug.FatalError("Incorrect number of vertices set. Must be 3.")
                }
            }
            _Vertices = newValue
        }
    }
    
    /// Holds the length of the base of the triangle.
    private var _Base: CGFloat = 1.0
    {
        didSet
        {
            MakeGeometry()
        }
    }
    /// Get or set the length of the base of the triangle.
    public var Base: CGFloat
    {
        get
        {
            return _Base
        }
        set
        {
            _Base = newValue
        }
    }
    
    /// Holds the height of the triangle.
    private var _Height: CGFloat = 1.0
    {
        didSet
        {
            MakeGeometry()
        }
    }
    /// Get or set the height of the triangle.
    public var Height: CGFloat
    {
        get
        {
            return _Height
        }
        set
        {
            _Height = newValue
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
    
    private var _DiffuseTexture: UIImage? = nil
    {
        didSet
        {
            MakeGeometry()
        }
    }
    /// Get or set the texture to use for the diffuse surface.
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
    
    private var _CastsShadow: Bool = true
    public var CastsShadow: Bool
    {
        get
        {
            return _CastsShadow
        }
        set
        {
            _CastsShadow = newValue
            for Child in self.childNodes
            {
                Child.castsShadow = newValue
            }
        }
    }
    
    /// Create a triangle using the vertex data in `Vertices`. Only the first three points are used. All prior
    /// shapes are removed.
    /// - Note: If no vertices have been set, no triangle is created. *This implies setting attributes
    ///         before setting the vertices will effectively have no result.*
    func MakeGeometryWithVertices()
    {
        for Child in self.childNodes
        {
            Child.removeFromParentNode()
            Child.geometry = nil
        }
        if let LocalVertices = Vertices
        {
            let Path = UIBezierPath()
            Path.move(to: LocalVertices[0])
            Path.addLine(to: LocalVertices[1])
            Path.addLine(to: LocalVertices[2])
            Path.addLine(to: LocalVertices[0])
            Path.close()
            TriangleVertices = [CGPoint]()
            TriangleVertices?.append(LocalVertices[0])
            TriangleVertices?.append(LocalVertices[1])
            TriangleVertices?.append(LocalVertices[2])
            let Geo = SCNShape(path: Path, extrusionDepth: _Extrusion)
            GeoNode = SCNNode2(geometry: Geo)
            GeoNode.categoryBitMask = _LightMask
            if let Texture = DiffuseTexture
            {
                GeoNode.geometry?.firstMaterial?.diffuse.contents = Texture
            }
            else
            {
                GeoNode.geometry?.firstMaterial?.diffuse.contents = Color
            }
            GeoNode.geometry?.firstMaterial?.specular.contents = Specular
            GeoNode.geometry?.firstMaterial?.emission.contents = Emission
            GeoNode.geometry?.firstMaterial?.metalness.contents = Metalness
            GeoNode.geometry?.firstMaterial?.roughness.contents = Roughness
            self.addChildNode(GeoNode)
        }
    }
    
    /// Create the geometric triangle and add it to `self`. All prior shapes
    /// are removed first.
    /// - Note: If vertices are available (in `Vertices`), `MakeGeometryWithVertices` will be called and used
    ///         instead of the code here.
    func MakeGeometry()
    {
        if Vertices != nil
        {
            MakeGeometryWithVertices()
            return
        }
        for Child in self.childNodes
        {
            Child.removeFromParentNode()
            Child.geometry = nil
        }
        let Path = UIBezierPath()
        let HCenter = _Base / 2.0
        TriangleVertices = [CGPoint]()
        Path.move(to: CGPoint(x: HCenter, y: _Height))
        TriangleVertices?.append(CGPoint(x: HCenter, y: _Height))
        Path.addLine(to: CGPoint(x: HCenter + _Base / 2.0, y: 0.0))
        TriangleVertices?.append(CGPoint(x: HCenter + _Base / 2.0, y: 0.0))
        Path.addLine(to: CGPoint(x: 0.0, y: 0.0))
        TriangleVertices?.append((CGPoint.zero))
        Path.addLine(to: CGPoint(x: HCenter, y: _Height))
        Path.close()
        let Geo = SCNShape(path: Path, extrusionDepth: _Extrusion)
        GeoNode = SCNNode2(geometry: Geo)
        GeoNode.categoryBitMask = _LightMask
        if let Texture = DiffuseTexture
        {
            GeoNode.geometry?.firstMaterial?.diffuse.contents = Texture
        }
        else
        {
            GeoNode.geometry?.firstMaterial?.diffuse.contents = Color
        }
        GeoNode.geometry?.firstMaterial?.specular.contents = Specular
        GeoNode.geometry?.firstMaterial?.emission.contents = Emission
        GeoNode.geometry?.firstMaterial?.metalness.contents = Metalness
        GeoNode.geometry?.firstMaterial?.roughness.contents = Roughness
        self.addChildNode(GeoNode)
    }
    
    /// Holds the triangle's vertices.
    private var TriangleVertices: [CGPoint]? = nil
    
    /// Returns an array of triangle vertices.
    /// - Returns: Array of generated vertices. If no vertices available, nil is returned.
    func GetVertices() -> [CGPoint]?
    {
        return TriangleVertices
    }
    
    var GeoNode = SCNNode2()
    
    // MARK: - Shape attributes.
    
    func SetMaterialColor(_ Color: UIColor)
    {
        GeoNode.geometry?.firstMaterial?.diffuse.contents = Color
    }
    
    func SetEmissionColor(_ Color: UIColor?)
    {
        if let Emission = Color
        {
            GeoNode.geometry?.firstMaterial?.emission.contents = Emission
        }
        else
        {
            GeoNode.geometry?.firstMaterial?.emission.contents = nil
        }
    }
    
    func SetDiffuseTexture(_ Image: UIImage)
    {
        self.DiffuseTexture = Image
    }
    
    func SetLightingModel(_ Model: SCNMaterial.LightingModel)
    {
        GeoNode.geometry?.firstMaterial?.lightingModel = Model
    }
    
    func SetMetalness(_ Value: Double?)
    {
        if let Metal = Value
        {
            GeoNode.geometry?.firstMaterial?.metalness.contents = Metal
        }
    }
    
    func SetRoughness(_ Value: Double?)
    {
        if let Rough = Value
        {
            GeoNode.geometry?.firstMaterial?.roughness.contents = Rough
        }
    }
}
