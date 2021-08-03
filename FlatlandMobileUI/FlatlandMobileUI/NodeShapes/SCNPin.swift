//
//  SCNPin.swift
//  Flatland
//
//  Created by Stuart Rankin on 6/11/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit
import SceneKit

/// Implements a 3D pin shape.
class SCNPin: SCNNode2
{
    /// Default initializer.
    override init()
    {
        super.init()
        MakeGeometry()
    }
    
    /// Initializer.
    /// - Parameters:
    ///   - KnobHeight: Height of the knob section of the pin.
    ///   - KnobRadius: Radius of the knob section of the pin.
    ///   - PinHeight: Height of the pin section of the pin.
    ///   - PinRadius: Radius of the pin section of the pin.
    ///   - KnobColor: Color of the knob section of the pin.
    ///   - PinColor: Color of the pin section.
    init(KnobHeight: CGFloat, KnobRadius: CGFloat, PinHeight: CGFloat, PinRadius: CGFloat,
         KnobColor: UIColor, PinColor: UIColor)
    {
        super.init()
        _KnobHeight = KnobHeight
        _KnobRadius = KnobRadius
        _KnobColor = KnobColor
        _PinHeight = PinHeight
        _PinRadius = PinRadius
        _PinColor = PinColor
        MakeGeometry()
    }
    
    /// Initializer.
    /// - Parameter coder: See Apple documentation.
    required init?(coder: NSCoder)
    {
        super.init(coder: coder)
        MakeGeometry()
    }
    
    /// Holds the current category bit mask value.
    private var _LightMask: Int = 0
    {
        didSet
        {
            Pin.categoryBitMask = _LightMask
            KnobTop.categoryBitMask = _LightMask
            KnobCenter.categoryBitMask = _LightMask
            KnobBottom.categoryBitMask = _LightMask
        }
    }
    /// Set the category bit mask value for all sub-parts of the pin.
    /// - Note: Use this property, _not_ `categoryBitMask`.
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
    
    /// Holds the height of the knob.
    private var _KnobHeight: CGFloat = 2.0
    {
        didSet
        {
            MakeGeometry()
        }
    }
    /// Get or set the height of the knob.
    public var KnobHeight: CGFloat
    {
        get
        {
            return _KnobHeight
        }
        set
        {
            _KnobHeight = newValue
        }
    }
    
    /// Holds the radius of the knob.
    private var _KnobRadius: CGFloat = 0.35
    {
        didSet
        {
            MakeGeometry()
        }
    }
    /// Get or set the radius of the knob.
    public var KnobRadius: CGFloat
    {
        get
        {
            return _KnobRadius
        }
        set
        {
            _KnobRadius = newValue
        }
    }
    
    /// Holds the height of the pin.
    private var _PinHeight: CGFloat = 2.0
    {
        didSet
        {
            MakeGeometry()
        }
    }
    /// Get or set the height of the pin.
    public var PinHeight: CGFloat
    {
        get
        {
            return _PinHeight
        }
        set
        {
            _PinHeight = newValue
        }
    }
    
    /// Holds the radius of the pin.
    private var _PinRadius: CGFloat = 0.15
    {
        didSet
        {
            MakeGeometry()
        }
    }
    /// Get or set the radius of the pin.
    public var PinRadius: CGFloat
    {
        get
        {
            return _PinRadius
        }
        set
        {
            _PinRadius = newValue
        }
    }
    
    /// Holds the color of the knob.
    private var _KnobColor: UIColor = UIColor.red
    {
        didSet
        {
            MakeGeometry()
        }
    }
    /// Get or set the color of the knob.
    public var KnobColor: UIColor
    {
        get
        {
            return _KnobColor
        }
        set
        {
            _KnobColor = newValue
        }
    }
    
    /// Holds the specular color of the knob.
    private var _KnobSpecular: UIColor = UIColor.white
    {
        didSet
        {
            MakeGeometry()
        }
    }
    /// Get or set the specular color of the knob.
    public var KnobSpecular: UIColor
    {
        get
        {
            return _KnobSpecular
        }
        set
        {
            _KnobSpecular = newValue
        }
    }
    
    /// Holds the color of the pin.
    private var _PinColor: UIColor = UIColor.gray
    {
        didSet
        {
            MakeGeometry()
        }
    }
    /// Get or set the color of the pin.
    public var PinColor: UIColor
    {
        get
        {
            return _PinColor
        }
        set
        {
            _PinColor = newValue
        }
    }
    
    /// Holds the specular color of the pin.
    private var _PinSpecular: UIColor = UIColor.white
    {
        didSet
        {
            MakeGeometry()
        }
    }
    /// Get or set the specular color of the pin.
    public var PinSpecular: UIColor
    {
        get
        {
            return _PinSpecular
        }
        set
        {
            _PinSpecular = newValue
        }
    }
    
    /// Create geometry for the pin using the current attribute.
    private func MakeGeometry()
    {
        for Child in self.childNodes
        {
            Child.removeFromParentNode()
            Child.geometry = nil
        }
        let KnobTopShape = SCNCone(topRadius: _KnobRadius, bottomRadius: 0.0, height: _KnobHeight / 2.0)
        KnobTopShape.firstMaterial?.diffuse.contents = _KnobColor
        KnobTopShape.firstMaterial?.specular.contents = _KnobSpecular
        let KnobBottomShape = SCNCone(topRadius: 0.0, bottomRadius: _KnobRadius, height: _KnobHeight / 2.0)
        KnobBottomShape.firstMaterial?.diffuse.contents = _KnobColor
        KnobBottomShape.firstMaterial?.specular.contents = _KnobSpecular
        let KnobCenterShape = SCNCylinder(radius: _KnobRadius * 0.45, height: _KnobHeight * 0.9)
        KnobCenterShape.firstMaterial?.diffuse.contents = _KnobColor
        KnobCenterShape.firstMaterial?.specular.contents = _KnobSpecular
        KnobTop = SCNNode2(geometry: KnobTopShape)
        KnobBottom = SCNNode2(geometry: KnobBottomShape)
        KnobCenter = SCNNode2(geometry: KnobCenterShape)
        KnobTop.position = SCNVector3(0.0, 0.5, 0.0)
        KnobBottom.position = SCNVector3(0.0, -0.5, 0.0)
        let KnobUI = SCNNode()
        KnobUI.addChildNode(KnobTop)
        KnobUI.addChildNode(KnobBottom)
        KnobUI.addChildNode(KnobCenter)
        KnobUI.position = SCNVector3(0.0, 1.0, 0.0)
        let PinShape = SCNCylinder(radius: _PinRadius, height: _PinHeight)
        Pin = SCNNode2(geometry: PinShape)
        Pin.geometry?.firstMaterial?.diffuse.contents = _PinColor
        Pin.geometry?.firstMaterial?.specular.contents = _PinSpecular
        Pin.position = SCNVector3(0.0, 2.5, 0.0)
        self.addChildNode(KnobUI)
        self.addChildNode(Pin)
    }
    
    private var KnobTop = SCNNode2()
    private var KnobBottom = SCNNode2()
    private var KnobCenter = SCNNode2()
    private var Pin = SCNNode2()
}
