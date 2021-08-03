//
//  +NodeBounding.swift
//  +NodeBounding
//
//  Created by Stuart Rankin on 7/18/21. Adapted from Flatland View.
//

import Foundation
import UIKit
import SceneKit

extension SCNNode2
{
    // MARK: - Bounding shapes.
    
    /// Determines whether bounding shape can be shown. If set to true, bounding shapes can be shown with a
    /// call to `ShowBoundingShape`. If set to false, bounding boxes are not shown and if a bounding shape is
    /// currently showing, it is hidden.
    var CanShowBoundingShape: Bool
    {
        get
        {
            return _CanShowBoundingShape
        }
        set
        {
            _CanShowBoundingShape = newValue
        }
    }
    
    /// Draw a bounding box around the node.
    /// - Note: Bounding boxes do not cast shadows.
    /// - Note: The caller _must_ set `RotateOnX`, `RotateOnY` and/or `RotateOnZ` before calling
    ///         this function if there are any changes to default behavior desired.
    /// - Parameter LineColor: The line color of the bounding box. Defaults to `UIColor.red`.
    /// - Parameter RotateBox: If true, the box rotates. If false, no rotation occurs. Defaults to `true`.
    /// - Parameter RotationDuration: The time in seconds to rotate the bounding box. Ignored if `RotateBox`
    ///                               is false.
    /// - Parameter LineThickness: The thickness of the lines making up the bounding box. Scaling the parent
    ///                            `SCNNode2` will affect the visual thickness of the bounding box lines.
    ///                            Defaults to `0.005`.
    func ShowBoundingBox(LineColor: UIColor = UIColor.red,
                         RotateBox: Bool = true,
                         RotationDuration: Double = 3.0,
                         LineThickness: CGFloat = 0.005)
    {
        if !CanShowBoundingShape
        {
            return
        }
#if true
        let Radius = self.boundingSphere.radius * 1.12
        let BoxShape = SCNBox(width: CGFloat(Radius * 2),
                              height: CGFloat(Radius * 2),
                              length: CGFloat(Radius * 2),
                              chamferRadius: 0.0)
        BoxShape.firstMaterial?.diffuse.contents = LineColor
        BoxShape.firstMaterial?.fillMode = .lines
        BoxShape.firstMaterial?.emission.contents = LineColor
        BoxNode = SCNNode(geometry: BoxShape)
        BoxNode.position = self.boundingSphere.center
        BoxNode.castsShadow = false
        if RotateBox
        {
            let XMultiplier = RotateOnX ? 1.0 : 0.0
            let YMultiplier = RotateOnY ? 1.0 : 0.0
            let ZMultiplier = RotateOnZ ? 1.0 : 0.0
            let Rotation = SCNAction.rotateBy(x: CGFloat(90.0.Radians * XMultiplier),
                                              y: CGFloat(90.0.Radians * YMultiplier),
                                              z: CGFloat(90.0.Radians * ZMultiplier),
                                              duration: RotationDuration)
            let RotateForever = SCNAction.repeatForever(Rotation)
            BoxNode.runAction(RotateForever)
        }
        self.addChildNode(BoxNode)
#else
        let (BoxMin, BoxMax) = self.boundingBox
        _ShowingBoundingShape = true
        let Point1 = SCNVector3(BoxMin.x, BoxMin.y, BoxMin.z)
        let Point2 = SCNVector3(BoxMin.x, BoxMax.y, BoxMin.z)
        let Point3 = SCNVector3(BoxMax.x, BoxMax.y, BoxMin.z)
        let Point4 = SCNVector3(BoxMax.x, BoxMin.y, BoxMin.z)
        let Point5 = SCNVector3(BoxMin.x, BoxMin.y, BoxMax.z)
        let Point6 = SCNVector3(BoxMin.x, BoxMax.y, BoxMax.z)
        let Point7 = SCNVector3(BoxMax.x, BoxMax.y, BoxMax.z)
        let Point8 = SCNVector3(BoxMax.x, BoxMin.y, BoxMax.z)
        let Line1 = BoundingBoxLine(Start: Point1, End: Point2, Color: LineColor, LineThickness: LineThickness)
        let Line2 = BoundingBoxLine(Start: Point2, End: Point3, Color: LineColor, RotateZ: 90.0, LineThickness: LineThickness)
        let Line3 = BoundingBoxLine(Start: Point3, End: Point4, Color: LineColor, LineThickness: LineThickness)
        let Line4 = BoundingBoxLine(Start: Point4, End: Point1, Color: LineColor, RotateZ: 90.0, LineThickness: LineThickness)
        let Line5 = BoundingBoxLine(Start: Point5, End: Point6, Color: LineColor, RotateY: 90.0, LineThickness: LineThickness)
        let Line6 = BoundingBoxLine(Start: Point6, End: Point7, Color: LineColor, RotateZ: 90.0, LineThickness: LineThickness)
        let Line7 = BoundingBoxLine(Start: Point7, End: Point8, Color: LineColor, LineThickness: LineThickness)
        let Line8 = BoundingBoxLine(Start: Point8, End: Point5, Color: LineColor, RotateZ: 90.0, LineThickness: LineThickness)
        let Line9 = BoundingBoxLine(Start: Point1, End: Point5, Color: LineColor, RotateX: 90.0, LineThickness: LineThickness)
        let Line10 = BoundingBoxLine(Start: Point2, End: Point6, Color: LineColor, RotateX: 90.0, LineThickness: LineThickness)
        let Line11 = BoundingBoxLine(Start: Point3, End: Point7, Color: LineColor, RotateX: 90.0, LineThickness: LineThickness)
        let Line12 = BoundingBoxLine(Start: Point4, End: Point8, Color: LineColor, RotateX: 90.0, LineThickness: LineThickness)
        BoundingBoxLines.append(Line1)
        BoundingBoxLines.append(Line2)
        BoundingBoxLines.append(Line3)
        BoundingBoxLines.append(Line4)
        BoundingBoxLines.append(Line5)
        BoundingBoxLines.append(Line6)
        BoundingBoxLines.append(Line7)
        BoundingBoxLines.append(Line8)
        BoundingBoxLines.append(Line9)
        BoundingBoxLines.append(Line10)
        BoundingBoxLines.append(Line11)
        BoundingBoxLines.append(Line12)
        BoxNode = SCNNode()
        BoxNode.castsShadow = false
        BoxNode.addChildNode(Line1)
        BoxNode.addChildNode(Line2)
        BoxNode.addChildNode(Line3)
        BoxNode.addChildNode(Line4)
        BoxNode.addChildNode(Line5)
        BoxNode.addChildNode(Line6)
        BoxNode.addChildNode(Line7)
        BoxNode.addChildNode(Line8)
        BoxNode.addChildNode(Line9)
        BoxNode.addChildNode(Line10)
        BoxNode.addChildNode(Line11)
        BoxNode.addChildNode(Line12)
        self.addChildNode(BoxNode)
        BoundingBoxLines.append(BoxNode)
        if RotateBox
        {
            let XMultiplier = RotateOnX ? 1.0 : 0.0
            let YMultiplier = RotateOnY ? 1.0 : 0.0
            let ZMultiplier = RotateOnZ ? 1.0 : 0.0
            let Rotation = SCNAction.rotateBy(x: CGFloat(90.0.Radians * XMultiplier),
                                              y: CGFloat(90.0.Radians * YMultiplier),
                                              z: CGFloat(90.0.Radians * ZMultiplier),
                                              duration: RotationDuration)
            let RotateForever = SCNAction.repeatForever(Rotation)
            BoxNode.runAction(RotateForever)
        }
#endif
    }
    
    /// Hide the bounding box around the node.
    func HideBoundingBox()
    {
        for Line in BoundingBoxLines
        {
            Line.removeAllActions()
            Line.removeAllAnimations()
            Line.removeFromParentNode()
            Line.geometry = nil
        }
        BoundingBoxLines.removeAll()
        BoxNode.removeAllActions()
        BoxNode.removeAllAnimations()
        BoxNode.removeFromParentNode()
        BoxNode.geometry = nil
        _ShowingBoundingShape = false
    }
    
    /// Return an `SCNNode` that acts looks like a line.
    /// - Parameter Start: The starting point of the line.
    /// - Parameter End: The ending point of the line.
    /// - Parameter Color: The color of the line.
    /// - Parameter RotateX: How to rotate the line on the X axis. In degrees. Defaults to 0.0.
    /// - Parameter RotateY: How to rotate the line on the Y axis. In degrees. Defaults to 0.0.
    /// - Parameter RotateZ: How to rotate the line on the Z axis. In degrees. Defaults to 0.0.
    /// - Parameter LineThickness: The thickness of the line. Defaults to 0.005.
    func BoundingBoxLine(Start: SCNVector3, End: SCNVector3, Color: UIColor, RotateX: Double = 0.0,
                         RotateY: Double = 0.0, RotateZ: Double = 0.0,
                         LineThickness: CGFloat = 0.005) -> SCNNode
    {
        let Vector = SCNVector3(Start.x - End.x, Start.y - End.y, Start.z - End.z)
        let Distance = sqrt(Vector.x * Vector.x + Vector.y * Vector.y + Vector.z * Vector.z)
        let MidPosition = SCNVector3(x: (Start.x + End.x) / 2,
                                     y: (Start.y + End.y) / 2,
                                     z: (Start.z + End.z) / 2)
        let Line =  SCNCylinder()
        Line.radius = LineThickness
        Line.height = CGFloat(Distance)
        Line.radialSegmentCount = 4
        Line.firstMaterial?.diffuse.contents = Color
        Line.firstMaterial?.selfIllumination.contents = Color
        let LineNode = SCNNode(geometry: Line)
        LineNode.castsShadow = false
        LineNode.position = MidPosition
        LineNode.eulerAngles = SCNVector3(RotateX.Radians, RotateY.Radians, RotateZ.Radians)
        return LineNode
    }
    
    /// Create a bounding sphere shape around the parent `SCNNode2`.
    /// - Note: Bounding spheres do not cast shadows.
    /// - Note: The caller _must_ set `RotateOnX`, `RotateOnY` and/or `RotateOnZ` before calling
    ///         this function if there are any changes to default behavior desired.
    /// - Parameter LineColor: The color of the lines.
    /// - Parameter RotateSphere: Determines if the bounding sphere rotates.
    /// - Parameter RotationDuration: Number of seconds for the rotation animation.
    /// - Parameter SegmentCount: Number of segments for the sphere. More segments add processing time and
    ///             makes the parent `SCNNode2` harder to see. Defaults to 16.
    /// - Parameter HideAfter: Number of seconds after which the bounding sphere will be hidden.
    ///                        Defaults to 10.0 seconds.
    /// - Parameter HideEffectDuration: Number of seconds to run the hide special effects in seconds. Defaults
    ///                                 to 1.0 seconds.
    private func ShowBoundingSphere(LineColor: UIColor = UIColor.red,
                                    RotateSphere: Bool = true,
                                    RotationDuration: Double = 3.0,
                                    SegmentCount: Int = 16,
                                    HideAfter Seconds: Double = 10.0,
                                    HideEffectDuration: Double = 1.0)
    {
        if !CanShowBoundingShape
        {
            return
        }
        let BoundingRadius = self.boundingSphere.radius * 1.25
        let BoundingSphere = SCNSphere(radius: CGFloat(BoundingRadius))
        BoundingSphere.firstMaterial?.fillMode = .lines
        BoundingSphere.firstMaterial?.diffuse.contents = LineColor
        BoundingSphere.firstMaterial?.emission.contents = LineColor
        BoundingSphere.segmentCount = SegmentCount
        BoundingSphereNode = SCNNode(geometry: BoundingSphere)
        BoundingSphereNode?.position = self.boundingSphere.center
        BoundingSphereNode?.castsShadow = false
        self.addChildNode(BoundingSphereNode!)
        
        if RotateSphere
        {
            let XMultiplier = RotateOnX ? 1.0 : 0.0
            let YMultiplier = RotateOnY ? 1.0 : 0.0
            let ZMultiplier = RotateOnZ ? 1.0 : 0.0
            let Rotation = SCNAction.rotateBy(x: CGFloat(90.0.Radians * XMultiplier),
                                              y: CGFloat(90.0.Radians * YMultiplier),
                                              z: CGFloat(90.0.Radians * ZMultiplier),
                                              duration: RotationDuration)
            let RotateForever = SCNAction.repeatForever(Rotation)
            BoundingSphereNode?.runAction(RotateForever)
        }
        if Seconds > 0.0
        {
            let Wait = SCNAction.wait(duration: Seconds)
            let Scale = SCNAction.scale(to: 0.01, duration: HideEffectDuration)
            let Remove = SCNAction.removeFromParentNode()
            let FadeOutSequence = SCNAction.sequence([Wait, Scale, Remove])
            BoundingSphereNode?.runAction(FadeOutSequence)
        }
    }
    
    /// Remove the bounding sphere.
    func HideBoundingSphere()
    {
        BoundingSphereNode?.removeAllActions()
        BoundingSphereNode?.removeAllAnimations()
        BoundingSphereNode?.removeFromParentNode()
        BoundingSphereNode = nil
    }
    
    /// Show a bounding shape around the node.
    /// - Parameter Shape: The shape of the bounding indicator.
    /// - Parameter LineColor: The color of the lines.
    /// - Parameter RotateSphere: Determines if the bounding sphere rotates.
    /// - Parameter RotationDuration: Number of seconds for the rotation animation.
    /// - Parameter LineThickness: Thickness of the line. Ignored if `Shape` is .Sphere.
    /// - Parameter SegmentCount: Number of segments for the sphere. More segments add processing time and
    ///             makes the parent `SCNNode2` harder to see. Defaults to 16. Ignored if `Shape` is .Box.
    func ShowBoundingShape(_ Shape: NodeBoundingShapes,
                           LineColor: UIColor = UIColor.red,
                           RotateBox: Bool = true,
                           RotationDuration: Double = 3.0,
                           LineThickness: CGFloat = 0.005,
                           SegmentCount: Int = 16)
    {
        CurrentBoundingShape = Shape
        HideBoundingBox()
        HideBoundingSphere()
        switch Shape
        {
            case .Box:
                ShowBoundingBox(LineColor: LineColor,
                                RotateBox: RotateBox,
                                RotationDuration: RotationDuration,
                                LineThickness: LineThickness)
                
            case .Sphere:
                ShowBoundingSphere(LineColor: LineColor,
                                   RotateSphere: RotateBox,
                                   RotationDuration: RotationDuration,
                                   SegmentCount: SegmentCount)
        }
    }
    
    /// Hide the bounding shape.
    public func HideBoundingShape()
    {
        switch CurrentBoundingShape
        {
            case .Box:
                HideBoundingBox()
                
            case .Sphere:
                HideBoundingSphere()
        }
    }
}
