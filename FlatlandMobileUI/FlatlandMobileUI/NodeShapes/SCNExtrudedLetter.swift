//
//  SCNExtrudedLetter.swift
//  Flatland
//
//  Created by Stuart Rankin on 12/14/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit
import SceneKit

class SCNExtrudedLetter: SCNNode2
{
    override init()
    {
    super.init()
        UpdateLetter()
    }
    
    init(Letter: String, Font: UIFont, Depth: Double, Scale: Double = 0.1)
    {
        super.init()
        _Font = Font
        _Scale = Scale
        _Depth = Depth
        UpdateLetter()
    }
    
    required init?(coder: NSCoder)
    {
        super.init(coder: coder)
        UpdateLetter()
    }

    private var _Depth: Double = 0.1
    public var Depth: Double
    {
        get
        {
            return _Depth
        }
        set
        {
            _Depth = newValue
            UpdateLetter()
        }
    }
    
    private var _Font: UIFont = UIFont.systemFont(ofSize: 12.0)
    public var Font: UIFont
    {
        get
        {
            return _Font
        }
        set
        {
            _Font = newValue
            UpdateLetter()
        }
    }
    
    private var _Scale: Double = 0.1
    public var Scale: Double
    {
        get
        {
            return _Scale
        }
        set
        {
            _Scale = newValue
            UpdateLetter()
        }
    }
    
    private var _Letter: String = "?"
    public var Letter: String
    {
        get
        {
            return _Letter
        }
        set
        {
            if newValue.isEmpty
            {
                return
            }
            _Letter = String(newValue.first!)
            UpdateLetter()
        }
    }
    
    private var _Flatness: Double = 0.4
    public var Flatness: Double
    {
        get
        {
            return _Flatness
        }
        set
        {
            _Flatness = newValue
            UpdateLetter()
        }
    }
    
    func UpdateLetter()
    {
        let Shape = SCNText(string: Letter, extrusionDepth: CGFloat(Depth))
        Shape.font = Font
        Shape.flatness = CGFloat(Flatness)
        self.geometry = Shape
        self.scale = SCNVector3(Scale, Scale, Scale)
    }
}
