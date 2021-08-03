//
//  +FloatingText.swift
//  Flatland
//
//  Created by Stuart Rankin on 4/11/21.
//  Copyright © 2021 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit
import SceneKit

extension GlobeView
{
    // MARK: - Floating text functions
    
    /// Plot floating text that curves along the surface of the Earth according to its location.
    /// - Note: If `Message` is empty, control returns immediately and nothing is displayed and `Closure` is
    ///         called.
    /// - Parameters:
    ///   - Message: The text of the message to display.
    ///   - Radius: The radial value use to determine how far away from the center the text is drawn.
    ///   - Latitude: The latitude of the text - determines how far up or down the text will be displayed
    ///               on the globe. Passing a value `0.0` shows the text on the equator.
    ///   - Longitude: The starting longitude of the text.
    ///   - Extrusion: Text extrustion depth.
    ///   - Font: Font to use for the text.
    ///   - Day: Time attributes for day time.
    ///   - Night: Time attributes for night time.
    ///   - LightMask: Mask value for lighting.
    ///   - Name: Name of the node.
    /// - Returns: Array of nodes, one for each letter plotted.. Nil returned on error or if no text specified.
    func GetFloatingTextNodes(_ Message: String, Radius: Double, Latitude: Double,
                          Longitude: Double, Extrusion: Double, Font: UIFont, Day: TimeAttributes,
                          Night: TimeAttributes, LightMask: Int, Name: String) -> [SCNNode2]?
    {
        if Message.isEmpty
        {
            return nil
        }
        let SpacingMap: [(High: Double, Low: Double, Spacing: Double)] =
            [
                (90.0, 80.0, 65.0),
                (79.99, 70.0, 58.0),
                (69.99, 60.0, 49.0),
                (59.99, 50.0, 40.0),
                (49.99, 40.0, 36.0),
                (39.99, 30.0, 33.0),
                (29.99, 20.0, 29.0),
                (19.99, 10.0, 25.0),
                (9.99, 00.0, 22.0),
            ]
        var Spacing: Double = 30.0
        let AbsLat = abs(Latitude)
        for (High, Low, Space) in SpacingMap
        {
            if AbsLat >= Low && AbsLat <= High
            {
                Spacing = Space
                break
            }
        }
        
        let TextNodes = Utility.MakeFloatingWord3(Radius: Radius,
                                                  Word: Message,
                                                  SpacingConstant: Spacing,
                                                  Latitude: Latitude,
                                                  Longitude: Longitude,
                                                  LatitudeOffset: -2.7,
                                                  LongitudeOffset: 1.8,
                                                  Mask: LightMask,
                                                  TextFont: Font,
                                                  DayAttributes: Day,
                                                  NightAttributes: Night,
                                                  Chamfer: 0.0)
        TextNodes.forEach({$0.name = Name})
        TextNodes.forEach({$0.castsShadow = false})
        return TextNodes
    }
    
    /// Plot floating text that curves along the surface of the Earth according to its location.
    /// - Note: If `Message` is empty, control returns immediately and nothing is displayed and `Closure` is
    ///         called.
    /// - Parameters:
    ///   - Message: The text of the message to display.
    ///   - Radius: The radial value use to determine how far away from the center the text is drawn.
    ///   - Latitude: The latitude of the text - determines how far up or down the text will be displayed
    ///               on the globe. Passing a value `0.0` shows the text on the equator.
    ///   - Longitude: The starting longitude of the text.
    ///   - Extrusion: Text extrustion depth.
    ///   - Font: Font to use for the text.
    ///   - Day: Time attributes for day time.
    ///   - Night: Time attributes for night time.
    ///   - LightMask: Mask value for lighting.
    ///   - Name: Name of the node.
    /// - Returns: Node with all characters rotated correctly. Nil returned on error or if no text specified.
    func PlotFloatingText(_ Message: String, Radius: Double, Latitude: Double,
                          Longitude: Double, Extrusion: Double, Font: UIFont, Day: TimeAttributes,
                          Night: TimeAttributes, LightMask: Int, Name: String) -> SCNNode2?
    {
        if Message.isEmpty
        {
            return nil
        }
        let SpacingMap: [(High: Double, Low: Double, Spacing: Double)] =
        [
            (90.0, 80.0, 65.0),
            (79.99, 70.0, 58.0),
            (69.99, 60.0, 49.0),
            (59.99, 50.0, 40.0),
            (49.99, 40.0, 36.0),
            (39.99, 30.0, 33.0),
            (29.99, 20.0, 29.0),
            (19.99, 10.0, 25.0),
            (9.99, 00.0, 22.0),
        ]
        var Spacing: Double = 30.0
        let AbsLat = abs(Latitude)
        for (High, Low, Space) in SpacingMap
        {
            if AbsLat >= Low && AbsLat <= High
            {
                Spacing = Space
                break
            }
        }

        let TextNodes = Utility.MakeFloatingWord3(Radius: Radius,
                                                  Word: Message,
                                                  SpacingConstant: Spacing,
                                                  Latitude: Latitude,
                                                  Longitude: Longitude,
                                                  LatitudeOffset: -2.7,
                                                  LongitudeOffset: 1.8,
                                                  Mask: LightMask,
                                                  TextFont: Font,
                                                  DayAttributes: Day,
                                                  NightAttributes: Night,
                                                  Chamfer: 0.0)
        let TextNode = SCNNode2()
        TextNode.castsShadow = false
        TextNode.name = Name
        TextNodes.forEach({$0.castsShadow = false})
        TextNodes.forEach({TextNode.addChildNode($0)})
        TextNode.position = SCNVector3(0.0, 0.0, 0.0)
        return TextNode
    }
    
    /// Plot floating text that curves along the surface of the Earth according to its location.
    /// - Note: If `Message` is empty, control returns immediately and nothing is displayed and `Closure` is
    ///         called.
    /// - Parameters:
    ///   - Message: The text of the message to display.
    ///   - Surface: The node around which the text will be wrapped and oriented.
    ///   - Latitude: The latitude of the text - determines how far up or down the text will be displayed
    ///               on the globe. Passing a value `0.0` shows the text on the equator.
    ///   - Longitude: The starting longitude of the text.
    ///   - Radius: Radial distance of the text.
    ///   - Extrusion: Text extrustion depth.
    ///   - Font: Font to use for the text.
    ///   - Color: Font diffuse color.
    ///   - Specular: Font specular color.
    ///   - Duration: How long to rotate the text. If set to `0.0`, the text will not rotate.
    ///   - After: Number of seconds to wait before removing the text. If nil, the text will not be removed.
    ///   - Closure: Closure to call after the text is removed. If `After` is nil, the closure will not be
    ///              called unless `Message` is empty, in which case `Closure` is always called.
    func PlotFloatingText(_ Message: String, On Surface: SCNNode2, Latitude: Double, Longitude: Double = 0.0,
                          Radius: Double = 12.0, Extrusion: Double = 5.0, Font: UIFont, Color: UIColor,
                          Specular: UIColor, Rotate Duration: Double = 0.05, Disappear After: Double? = nil,
                          Closure: ((Bool) -> ())? = nil)
    {
        if Message.isEmpty
        {
            Closure?(true)
            return
        }
        let TextNodes = Utility.MakeFloatingWord2(Radius: Radius,
                                                  Word: Message,
                                                  Latitude: Latitude,
                                                  Longitude: Longitude,
                                                  Extrusion: CGFloat(Extrusion),
                                                  TextFont: Font,
                                                  TextColor: Color,
                                                  TextSpecular: Specular)
        let TextNode = SCNNode2()
        TextNode.name = "Floating Text Node"
        TextNodes.forEach({TextNode.addChildNode($0)})
        TextNode.position = SCNVector3(0.0, 0.0, 0.0)
        Surface.addChildNode(TextNode)
        var HideSequence: SCNAction? = nil
        if let HideAfter = After
        {
            let DelayAction = SCNAction.wait(duration: HideAfter)
            let FadeAction = SCNAction.fadeOut(duration: 1.0)
            HideSequence = SCNAction.sequence([DelayAction, FadeAction, SCNAction.removeFromParentNode()])
        }
        var RotateForever: SCNAction? = nil
        if Duration >= 0.0
        {
            let RotateText = SCNAction.rotateBy(x: 0.0, y: -CGFloat.pi / 180.0, z: 0.0, duration: Duration)
            RotateForever = SCNAction.repeatForever(RotateText)
        }
        if RotateForever != nil
        {
            TextNode.runAction(RotateForever!)
        }
        if HideSequence != nil
        {
            TextNode.runAction(HideSequence!)
            {
                Closure?(true)
            }
        }
    }
}
