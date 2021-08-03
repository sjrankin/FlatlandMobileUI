//
//  SCN3DArrow.swift
//  Flatland
//
//  Created by Stuart Rankin on 7/1/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit
import SceneKit

/// Implements/creates a 3D arrow shape in an `SCNNode2`.
class SCN3DArrow: SCNNode2
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
    ///   - Color: Color of the diffuse surface of the arrow.
    ///   - Specular: Color of the specular surface of the arrow.
    ///   - StemColor: Color of the diffuse surface of the stem.
    ///   - StemSpecular: Color of the specular surface of the stem.
    ///   - LightMask: The light mask to apply to each sub-node of the simple arrow. Defaults to 0.
    init(Length: CGFloat, Width: CGFloat, Color: UIColor = UIColor.systemYellow,
         Specular: UIColor = UIColor.white, StemColor: UIColor = UIColor.systemOrange,
         StemSpecular: UIColor = UIColor.white, LightMask: Int = 0)
    {
        super.init()
        self.Length = Length
        self.Width = Width
        self.Color = Color
        self.Specular = Specular
        self.StemColor = StemColor
        self.StemSpecular = StemSpecular
        self.LightMask = LightMask
    }
    
    /// Initializers. Creates a default shape.
    /// - Parameter coder: See Apple documentation.
    required init?(coder: NSCoder)
    {
        super.init(coder: coder)
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
    
    /// Holds the arrow diffuse color.
    private var _Color: UIColor = UIColor.systemYellow
    {
        didSet
        {
            MakeGeometry()
        }
    }
    /// Get or set the color for the diffuse arrow surface.
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
    
    /// Holds the arrow specular color.
    private var _Specular: UIColor = UIColor.white
    {
        didSet
        {
            MakeGeometry()
        }
    }
    /// Get or set the color for the specular arrow surface.
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
    
    /// Holds the stem diffuse color.
    private var _StemColor: UIColor = UIColor.systemOrange
    {
        didSet
        {
            MakeGeometry()
        }
    }
    /// Get or set the color for the diffuse stem surface.
    public var StemColor: UIColor
    {
        get
        {
            return _StemColor
        }
        set
        {
            _StemColor = newValue
        }
    }
    
    /// Holds the stem specular color.
    private var _StemSpecular: UIColor = UIColor.white
    {
        didSet
        {
            MakeGeometry()
        }
    }
    /// Get or set the color for the specular stem surface.
    public var StemSpecular: UIColor
    {
        get
        {
            return _StemSpecular
        }
        set
        {
            _StemSpecular = newValue
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
        
        let Cone = SCNCone(topRadius: 0.0, bottomRadius: _Width * 0.75, height: _Length / 3.0)
        ConeNode = SCNNode2(geometry: Cone)
        ConeNode.geometry?.firstMaterial?.diffuse.contents = _Color
        ConeNode.geometry?.firstMaterial?.specular.contents = _Specular
        ConeNode.categoryBitMask = _LightMask
        let Stem = SCNCapsule(capRadius: _Width * 0.25, height: _Length * 0.65)
        StemNode = SCNNode2(geometry: Stem)
        StemNode.position = SCNVector3(0.0, -0.8, 0.0)
        StemNode.geometry?.firstMaterial?.diffuse.contents = _StemColor
        StemNode.geometry?.firstMaterial?.specular.contents = _StemSpecular
        StemNode.categoryBitMask = _LightMask
        Arrow = SCNNode2()
        Arrow.addChildNode(ConeNode)
        Arrow.addChildNode(StemNode)
        self.addChildNode(Arrow)
    }
    
    var ConeNode = SCNNode2()
    var StemNode = SCNNode2()
    var Arrow = SCNNode2()
}
