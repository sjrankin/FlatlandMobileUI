//
//  +MouseHandling.swift
//  Flatland
//
//  Created by Stuart Rankin on 11/15/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit
import SceneKit

#if false
extension GlobeView
{
    // MARK: - Mouse handling
    
    /// Toggle the mouse follow mode. If disabling, the mouse indicator is removed from the scene.
    /// - Parameter sender: Not used.
    @objc func ContextToggleFollowMouse(_ sender: Any)
    {
        Settings.ToggleBool(.FollowMouse)
        if !Settings.GetBool(.FollowMouse)
        {
            RemoveMousePointer()
        }
    }
    
    func SetMouseTracking(Track: Bool)
    {
        if Track
        {
            PlotMouseIndicator()
        }
        else
        {
            RemoveMousePointer()
        }
    }
    
    /// Handle mouse motion reported by the main view controller.
    /// - Note:
    ///   - Depending on various parameters, the mouse's location is translated to scene coordinates and
    ///     the node under the mouse is queried and its associated data may be displayed.
    ///   - The implementation for mouse over node is slightly different between the 2D and 3D displays...
    ///   - The mouse point's latitude and longitude are stored in `CurrentMouseLatitude` and
    ///     `CurrentMouseLongitude`.
    /// - Parameter Point: The point in the view reported by the main controller. Converted to map coordinates
    ///                    here for use by the map and other functions that expect latitude and longitude
    ///                    values.
    func MouseMovedTo(Point: CGPoint)
    {
        if InWidgetMode
        {
            return
        }
        if Settings.GetEnum(ForKey: .ViewType, EnumType: ViewTypes.self, Default: ViewTypes.Globe3D) != .Globe3D
        {
            return
        }
        let SearchOptions: [SCNHitTestOption: Any] =
            [
                .searchMode: SCNHitTestSearchMode.closest.rawValue,
                .ignoreHiddenNodes: true,
                .ignoreChildNodes: true,
                .rootNode: self.EarthNode as Any
            ]
        let HitObject = self.hitTest(Point, options: SearchOptions)
        if HitObject.count > 0
        {
            if HitObject[0].node.self is SCNNode2
            {
                let TxWhere = HitObject[0].textureCoordinates(withMappingChannel: 0)
                CurrentMouseLocation = TxWhere
                let (Latitude, Longitude) = MakeWhereFromTexture(TxWhere)
                CurrentMouseLatitude = Latitude
                CurrentMouseLongitude = Longitude
                if Settings.GetBool(.FollowMouse)
                {
                    #if false
                    if Settings.GetBool(.HideMouseOverEarth)
                    {
                        if MouseIsVisible
                        {
                            MouseIsVisible = false
                            NSCursor.hide()
                        }
                    }
                    #endif
                    MainDelegate?.MouseAtLocation(Latitude: Latitude, Longitude: Longitude, Caller: "Globe")
                    PlotMouseIndicator(Latitude: Latitude, Longitude: Longitude)
                }
            }
            else
            {
                if Settings.GetBool(.HideMouseOverEarth)
                {
                    #if false
                    if !MouseIsVisible
                    {
                        MouseIsVisible = true
                        NSCursor.unhide()
                    }
                    #endif
                }
            }
        }
        else
        {
            if Settings.GetBool(.HideMouseOverEarth)
            {
                #if false
                if !MouseIsVisible
                {
                    MouseIsVisible = true
                    NSCursor.unhide()
                }
                #endif
            }
            CurrentMouseLocation = nil
        }
    }
    
    /// Create the latitude and longitude from the passed texture location. The texture location is the location
    /// of the mouse on the globe's texture where the top is at Y == 0.0, the bototm at Y == 1.0, left is X == 0.0
    /// and right is X == 1.0.
    /// - Parameter TextureLocation: The location of the mouse on the texture of the globe. See summary for
    ///                              description.
    /// - Returns: Tuple of the latitude and longitude.
    func MakeWhereFromTexture(_ TextureLocation: CGPoint) -> (Latitude: Double, Longitude: Double)
    {
        if TextureLocation == CGPoint.zero
        {
            return (0.0, 0.0)
        }
        var Latitude: Double = 0.0
        var Longitude: Double = 0.0
        if TextureLocation.x < 0.5
        {
            //Western hemisphere
            let AdjustedX = 0.5 - Double(TextureLocation.x)
            Longitude = (AdjustedX * 2.0) * 180.0 * -1.0
            if TextureLocation.y <= 0.5
            {
                //Northern hemisphere
                let AdjustedY = 0.5 - Double(TextureLocation.y)
                Latitude = (AdjustedY * 2.0) * 90.0
            }
            else
            {
                //Southern hemisphere
                let AdjustedY = Double(TextureLocation.y) - 0.5
                Latitude = (AdjustedY * 2.0) * 90.0 * -1.0
            }
        }
        else
        {
            //Eastern hemisphere
            let AdjustedX = Double(TextureLocation.x) - 0.5
            Longitude = (AdjustedX * 2.0) * 180.0
            if TextureLocation.y <= 0.5
            {
                //Nothern hemisphere
                let AdjustedY = 0.5 - Double(TextureLocation.y)
                Latitude = (AdjustedY * 2.0) * 90.0
            }
            else
            {
                //Southern hemisphere
                let AdjustedY = Double(TextureLocation.y) - 0.5
                Latitude = (AdjustedY * 2.0) * 90.0 * -1.0
            }
        }
        return (Latitude, Longitude)
    }
    
    func PlotMouseIndicator()
    {
        RemoveMousePointer()
        PlotMouseIndicator(Latitude: MostRecentMouseLatitude, Longitude: MostRecentMouseLongitude)
    }
    
    /// Draw the mouse indicator on the surface of the globe.
    /// - Note:
    ///   - This has the potential to be distracting to the user...
    ///   - The visibility of the Flatland moust pointer is dependent on the feature level.
    /// - Parameter Latitude: The latitude of where to draw the indicator.
    /// - Parameter Longitude: The longitude of where to draw the indicator.
    func PlotMouseIndicator(Latitude: Double, Longitude: Double)
    {
        if MouseIndicator == nil
        {
            MouseIndicator = MakeMouseIndicator()
            if MouseIndicator != nil
            {
                EarthNode?.addChildNode(MouseIndicator!)
            }
        }
        MostRecentMouseLatitude = Latitude
        MostRecentMouseLongitude = Longitude
        let (X, Y, Z) = Geometry.ToECEF(Latitude, Longitude,
                               Radius: Double(GlobeRadius.Primary.rawValue) + Double(MouseShape.RadialOffset.rawValue))
        MainDelegate?.MouseAtLocation(Latitude: Latitude, Longitude: Longitude, Caller: "Globe")
        MouseIndicator?.position = SCNVector3(X, Y, Z)
        MouseIndicator?.eulerAngles = SCNVector3(CGFloat(Latitude + 90.0).Radians,
                                                 CGFloat(Longitude + 180.0).Radians,
                                                 0.0)
    }
    
    /// Handle mouse clicks reported by the main view controller.
    /// - Note: Depending on various parameters, the mouse's location is translated to scene coordinates and
    ///         the node under the mouse is queried and its associated data may be displayed.
    /// - Note: The implementation for mouse over node is slightly different between the 2D and 3D displays...
    /// - Parameter Point: The point in the view reported by the main controller.
    func MouseClickedAt(Point: CGPoint)
    {
        if InWidgetMode
        {
            return
        }
        let MapView = Settings.GetEnum(ForKey: .ViewType, EnumType: ViewTypes.self, Default: .FlatSouthCenter)
        if MapView == .Globe3D
        {
            let SearchOptions: [SCNHitTestOption: Any] =
                [
                    .searchMode: SCNHitTestSearchMode.closest.rawValue,
                    .ignoreHiddenNodes: true,
                    .ignoreChildNodes: false,
                    .rootNode: self.EarthNode as Any
                ]
            let HitObject = self.hitTest(Point, options: SearchOptions)
            if HitObject.count > 0
            {
                if let Node = HitObject[0].node as? SCNNode2
                {
                    if InRegionCreationMode
                    {
                        let Geo = GeoPoint(CurrentMouseLatitude, CurrentMouseLongitude)
                        MouseClickReceiver?.MouseClicked(At: Geo)
                        return
                    }
                    if InPointCreationMode
                    {
                        let Geo = GeoPoint(CurrentMouseLatitude, CurrentMouseLongitude)
                        MouseClickReceiver?.MouseClicked(At: Geo)
                        return
                    }
                    if let NodeID = Node.NodeID
                    {
                        #if false
                        if PreviousNodeID != nil
                        {
                            if PreviousNodeID! == NodeID
                            {
                                return
                            }
                        }
                        #endif
                        
                        if let NodeData = NodeTables.GetItemData(For: NodeID)
                        {
                            if Settings.GetBool(.HighlightNodeUnderMouse)
                            {
                                Node.ShowBoundingShape(.Sphere,
                                                       LineColor: UIColor.red,
                                                       SegmentCount: 10)
                                #if false
                                if let PN = PreviousNode
                                {
                                    PN.HideBoundingShape()
                                }
                                #endif
                            }
                            PreviousNodeID = NodeID
                            PreviousNode = Node
                            MakePopOver(At: Point, For: NodeData)
                        }
                        else
                        {
                            Pop?.performClose(self)
                        }
                    }
                }
                else
                {
                    Pop?.performClose(self)
                }
            }
        }
    }
    
    /// Create a pop-over view to display information.
    /// - Parameter At: Where to create the pop-over window.
    /// - Parameter For: Information to display.
    func MakePopOver(At: CGPoint, For: DisplayItem)
    {
        if let PopController = NSStoryboard(name: "Popovers", bundle: nil).instantiateController(withIdentifier: "POIPopover") as? POIPopover
        {
            Pop = NSPopover()
            Pop?.contentSize = CGSize(width: 376, height: 159)
            Pop?.behavior = .semitransient
            Pop?.animates = true
            Pop?.contentViewController = PopController
            Pop?.show(relativeTo: CGRect(x: At.x, y: At.y, width: 10.0, height: 10.0), of: self, preferredEdge: .minX)
            PopController.ItemToDisplay(For)
            PopController.PopParent = self
            PopController.SetSelf(Pop!)
        }
    }
    
    /// Remove the mouse pointer from the Earth.
    func RemoveMousePointer()
    {
        MouseIndicator?.removeAllActions()
        MouseIndicator?.removeAllAnimations()
        MouseIndicator?.removeFromParentNode()
        MouseIndicator = nil
    }
    
    /// Make a mouse indicator for the globe.
    /// - Note: The shape returned is dependent on the value of `MousePointerType`.
    /// - Returns: A shape to use as a mouse location indicator. Nil returned if the pointer type is `.Normal`
    ///            but the feature level is insufficient.
    func MakeMouseIndicator() -> SCNNode2?
    {
        RemoveMousePointer()
        switch MousePointerType
        {
            case .Normal:
                if Features.FeatureEnabled(.FlatlandMouseCursor)
                {
                    return MakeNormalMouseIndicator()
                }
                else
                {
                    return nil
                }
                
            case .EndPin:
                return MakePlottedPin(MostRecentMouseLatitude, MostRecentMouseLongitude, Color: UIColor.red)
                
            case .StartPin:
                return MakePlottedPin(MostRecentMouseLatitude, MostRecentMouseLongitude, Color: UIColor.green)
        }
    }
    
    /// Make a mouse indicator for the globe. This is the normal type of mouse indicator which merely indicates
    /// location and not an ongoing function.
    /// - Returns: A shape to use for the indicator.
    func MakeNormalMouseIndicator() -> SCNNode2
    {
        let top = SCNCone(topRadius: CGFloat(MouseShape.PointRadius.rawValue),
                          bottomRadius: CGFloat(MouseShape.BottomRadius.rawValue),
                          height: CGFloat(MouseShape.Height.rawValue))
        let bottom = SCNCone(topRadius: CGFloat(MouseShape.BottomRadius.rawValue),
                             bottomRadius: CGFloat(MouseShape.PointRadius.rawValue),
                             height: CGFloat(MouseShape.Height.rawValue))
        let topnode = SCNNode2(geometry: top)
        let bottomnode = SCNNode2(geometry: bottom)
        topnode.categoryBitMask = LightMasks3D.Sun.rawValue | LightMasks3D.Moon.rawValue
        bottomnode.categoryBitMask = LightMasks3D.Sun.rawValue | LightMasks3D.Moon.rawValue
        topnode.position = SCNVector3(0.0, CGFloat(MouseShape.Height.rawValue), 0.0)
        topnode.geometry?.firstMaterial?.diffuse.contents = UIColor.black
        topnode.geometry?.firstMaterial?.emission.contents = UIColor.systemOrange
        bottomnode.geometry?.firstMaterial?.diffuse.contents = UIColor.black
        bottomnode.geometry?.firstMaterial?.emission.contents = UIColor.systemYellow
        let SwapDuration: Double = MouseShape.ColorSwapDuration.rawValue
        #if true
        let BottomGradient = MakeGradient(UIColor.yellow, UIColor.blue, 0.5)
        bottomnode.geometry?.firstMaterial?.emission.contents = BottomGradient
        let TopGradient = MakeGradient(UIColor.blue, UIColor.black, 0.0, 0.5)
        topnode.geometry?.firstMaterial?.emission.contents = TopGradient
        #else
        let TopColorSwap = SCNAction.customAction(duration: SwapDuration)
        {
            Node, Elapsed in
            if Double(Elapsed) >= SwapDuration
            {
                if let OldColor = Node.geometry?.firstMaterial?.emission.contents as? UIColor
                {
                    if OldColor == UIColor.systemYellow
                    {
                        Node.geometry?.firstMaterial?.emission.contents = UIColor.systemOrange
                    }
                    else
                    {
                        Node.geometry?.firstMaterial?.emission.contents = UIColor.systemYellow
                    }
                }
            }
        }
        let SwapTopForever = SCNAction.repeatForever(TopColorSwap)
        topnode.runAction(SwapTopForever)
        let BottomColorSwap = SCNAction.customAction(duration: SwapDuration)
        {
            Node, Elapsed in
            if Double(Elapsed) >= SwapDuration
            {
                if let OldColor = Node.geometry?.firstMaterial?.emission.contents as? UIColor
                {
                    if OldColor == UIColor.systemOrange
                    {
                        Node.geometry?.firstMaterial?.emission.contents = UIColor.systemYellow
                    }
                    else
                    {
                        Node.geometry?.firstMaterial?.emission.contents = UIColor.systemOrange
                    }
                }
            }
        }
        let Test = MakeGradient(UIColor.red, UIColor.TeaGreen)
        let SwapBottomForever = SCNAction.repeatForever(BottomColorSwap)
        bottomnode.runAction(SwapBottomForever)
        #endif
        let FinalIndicator = SCNNode2()
        FinalIndicator.name = GlobeNodeNames.MouseIndicator.rawValue
        FinalIndicator.addChildNode(topnode)
        FinalIndicator.addChildNode(bottomnode)
        var Angles = [Double]()
        var Previous = 0.0
        let GenericAngle = 360.0 * (1.0 / MouseShape.AngleCount.rawValue)
        for _ in 0 ..< Int(MouseShape.AngleCount.rawValue)
        {
            let NewAngle = Previous + GenericAngle
            Previous = NewAngle
            Angles.append(NewAngle)
        }
        for Angle in Angles
        {
            let Radius = MouseShape.BottomRadius.rawValue
            let Sphere = SCNSphere(radius: CGFloat(MouseShape.SuperfluousSphereRadius.rawValue))
            let SNode = SCNNode2(geometry: Sphere)
            SNode.geometry?.firstMaterial?.emission.contents = UIColor.cyan
            let X = Radius * cos(Angle.Radians)
            let Y = Radius * sin(Angle.Radians)
            SNode.position = SCNVector3(X, MouseShape.Height.rawValue / 2.0, Y)
            FinalIndicator.addChildNode(SNode)
            let RotateDuration = MouseShape.SuperfluousSphereRotationDuration.rawValue
            let RotateSphere = SCNAction.customAction(duration: RotateDuration)
            {
                Node, Elapsed in
                let NewAngle = Angle + 360.0 * (Double(Elapsed) / RotateDuration)
                let NewX = Radius * cos(NewAngle.Radians)
                let NewY = Radius * sin(NewAngle.Radians)
                Node.position = SCNVector3(NewX, MouseShape.Height.rawValue / 2.0, NewY)
            }
            let Forever = SCNAction.repeatForever(RotateSphere)
            SNode.runAction(Forever)
        }
        
        return FinalIndicator
    }
    
    /// Place a pin on the map to indicate a location desired by the user.
    /// - Parameter Start: If true, the pin is assumed to be the start of a region.
    /// - Parameter Latitude: Latitude of the location.
    /// - Parameter Longitude: Longitude of the location.
    /// - Returns: `SCNNode2` of a pin to plot on the Earth.
    func MakePinnedLocation(Start: Bool, Latitude: Double, Longitude: Double) -> SCNNode2
    {
        let KnobColor = Start ? UIColor.green : UIColor.red
        let Pin = SCNPin(KnobHeight: 2.0, KnobRadius: 1.0, PinHeight: 1.4, PinRadius: 0.15,
                         KnobColor: KnobColor, PinColor: UIColor.gray)
        Pin.scale = SCNVector3(0.15, 0.15, 0.15)
        Pin.LightMask = LightMasks3D.Sun.rawValue | LightMasks3D.Moon.rawValue
        let (X, Y, Z) = Geometry.ToECEF(Latitude, Longitude, Radius: Double(GlobeRadius.Primary.rawValue))
        Pin.position = SCNVector3(X, Y, Z)
        let YRotation = Latitude + 90.0
        let XRotation = Longitude + 180.0
        Pin.eulerAngles = SCNVector3(YRotation.Radians, XRotation.Radians, 0.0)
        EarthNode?.addChildNode(Pin)
        return Pin
    }
    
    /// Create a gradient layer with the passed colors.
    /// - Parameter Color1: Initial color.
    /// - Parameter Color2: Second color.
    /// - Parameter Pos1: Position of first color. Defaults to `0.0`.
    /// - Parameter Pos2: Position of second color. Defaults to `1.0`.
    /// - Returns: `CAGradientLayer` with the specified gradient.
    func MakeGradient(_ Color1: UIColor, _ Color2: UIColor, _ Pos1: Double = 0.0, _ Pos2: Double = 1.0) -> CAGradientLayer
    {
        let GLayer = CAGradientLayer()
        GLayer.frame = CGRect(origin: CGPoint.zero, size: CGSize(width: 100.0, height: 100.0))
        GLayer.colors = [Color1.cgColor as Any, Color2.cgColor as Any]
        GLayer.locations = [NSNumber(value: Pos1), NSNumber(value: Pos2)]
        return GLayer
    }
}

#endif
