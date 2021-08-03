//
//  +Earthquakes.swift
//  Flatland
//
//  Created by Stuart Rankin on 6/15/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit
import SceneKit

extension GlobeView
{
    /// Plot earthquakes on the globe.
    /// - Note: If #DEBUG is defined, memory is tracked over the course of plotting earthquakes. If #DEBUG
    ///         is not defined, memory is not tracked.
    /// - Parameter From: Name of the caller. Defaults to nil.
    /// - Parameter FromCache: If true, earthquakes are from the cache.
    /// - Parameter Final: Completion block called after plot functions have been called. Defaults to nil.
    func PlotEarthquakes(_ From: String? = nil, FromCache: Bool = false, _ Final: (() -> ())? = nil)
    {
        if let Earth = EarthNode
        {
            if let AlreadyDone = InitialStenciledMap
            {
                ApplyEarthquakeStencils(InitialMap: AlreadyDone, Caller: #function)
            }
            else
            {
                ApplyAllStencils(Caller: #function)
            }
            #if DEBUG
            MemoryDebug.Block(#function)
            {
                [weak self] _ in
                self?.PlotEarthquakes((self?.EarthquakeList)!, IsCached: FromCache, On: Earth)
            }
            #else
            PlotEarthquakes(EarthquakeList, IsCached: FromCache, On: Earth)
            #endif
            Final?()
        }
    }
    
    /// Remove all earthquake nodes from the globe.
    func ClearEarthquakes()
    {
        let RemovalList =
        [
            GlobeNodeNames.EarthquakeNodes.rawValue,
            GlobeNodeNames.IndicatorNode.rawValue,
            GlobeNodeNames.InfoNode.rawValue,
            GlobeNodeNames.MagnitudeNode.rawValue
        ]
        if let Earth = EarthNode
        {
            for Node in Earth.childNodes
            {
                if let SomeName = Node.name
                {
                    if RemovalList.contains(SomeName)
                    {
                        Node.removeAllAnimations()
                        Node.removeAllActions()
                        Node.removeFromParentNode()
                        Node.geometry = nil
                    }
                }
            }
            IndicatorAgeMap.removeAll()
        }
        PlottedEarthquakes.removeAll()
    }
    
    func GetDeltas(_ List1: [Earthquake], _ List2: [Earthquake]) -> [Earthquake]
    {
        let Set1 = Set<Earthquake>(List1.map{$0})
        let Set2 = Set<Earthquake>(List2.map{$0})
        let Difference = Array(Set1.subtracting(Set2))
        return Difference
    }
    
    /// Determines if two lists of earthquakes have the same contents. This function works regardless
    /// of the order of the contents.
    /// - Parameter List1: First earthquake list.
    /// - Parameter List2: Second earthquake list.
    /// - Parameter Delta: The difference between `List1` and `List2`.
    /// - Returns: True if the lists have equal contents, false if not.
    func SameEarthquakes(_ List1: [Earthquake], _ List2: [Earthquake],
                         Delta: inout [Earthquake]) -> Bool
    {
        if List1.count != List2.count
        {
            return false
        }
        
        //let Set1 = Set<String>(List1.map{$0.Code})
        //let Set2 = Set<String>(List2.map{$0.Code})
        //let DeltaSet = Set1.subtracting(Set2)
        
        let SList1 = List1.sorted(by: {$0.Code < $1.Code})
        let SList2 = List2.sorted(by: {$0.Code < $1.Code})
        Delta = GetDeltas(SList1, SList2)
        for Index in 0 ..< SList1.count
        {
            if SList1[Index].Code != SList2[Index].Code
            {
                #if false
                for Idx in 0 ..< SList1.count
                {
                    print("SList1[\(Idx)]=\(SList1[Idx].Code), SList2[\(Idx)]=\(SList2[Idx].Code)")
                }
                #endif
                return false
            }
        }
        return true
    }
    
    /// Called when a new list of earthquakes was obtained from the remote source.
    /// - Parameter NewList: New list of earthquakes. If the new list has the same contents as the
    ///                      previous list, no action is taken.
    /// - Parameter FromCache: If true, the set of earthquakes is from the cache.
    /// - Parameter Final: Completion handler.
    func NewEarthquakeList(_ NewList: [Earthquake], FromCache: Bool = false, Final: (() -> ())? = nil)
    {
        RemoveExpiredIndicators(NewList)
        let FilteredList = EarthquakeFilterer.FilterList(NewList)
        if FilteredList.count == 0
        {
            return
        }
        var NewQuakes = [Earthquake]()
        if SameEarthquakes(FilteredList, EarthquakeList, Delta: &NewQuakes)
        {
            #if DEBUG
            //Debug.Print("No new earthquakes")
            #endif
            return
        }
        NewQuakes.sort(by: {$0.Magnitude > $1.Magnitude})
        if let Biggest = NewQuakes.max(by: {$0.Magnitude > $1.Magnitude})
        {
            var TimeString = "\(Biggest.Time)"
            TimeString = TimeString.replacingOccurrences(of: "+0000", with: "GMT")
            //MainDelegate?.PushStatusMessage("New quake: \(Biggest.Title), \(TimeString)", PersistFor: 600.0)
        }
        ClearEarthquakes()
        EarthquakeList.removeAll()
        EarthquakeList = FilteredList
        PlottedEarthquakes.removeAll()
        PlotEarthquakes(#function, FromCache: FromCache, Final)
        
        Settings.CacheEarthquakes(EarthquakeList) 
        NodeTables.RemoveEarthquakes()
        for Quake in EarthquakeList
        {
            NodeTables.AddEarthquake(Quake)
        }
    }
    
    /// Go through all current earthquakes and remove indicators for those earthquakes that are no longer
    /// "recent" (as defined by the user).
    /// - Parameter Quakes: The list of earthquakes to check for which indicators to remove.
    func RemoveExpiredIndicators(_ Quakes: [Earthquake])
    {
        let HighlightHow = Settings.GetEnum(ForKey: .EarthquakeStyles, EnumType: EarthquakeIndicators.self,
                                            Default: .None)
        if HighlightHow == .None
        {
            for (_, Node) in IndicatorAgeMap
            {
                Node.removeAllAnimations()
                Node.removeAllActions()
                Node.removeFromParentNode()
                Node.geometry = nil
            }
            IndicatorAgeMap.removeAll()
            return
        }
        else
        {
            let HowRecent = Settings.GetEnum(ForKey: .RecentEarthquakeDefinition, EnumType: EarthquakeRecents.self,
                                             Default: .Day1)
            for Quake in Quakes
            {
                if let RecentSeconds = RecentMap[HowRecent]
                {
                    if Quake.GetAge() > RecentSeconds
                    {
                        if let INode = IndicatorAgeMap[Quake.Code]
                        {
                            INode.removeAllAnimations()
                            INode.removeAllActions()
                            INode.removeFromParentNode()
                            INode.geometry = nil
                            IndicatorAgeMap.removeValue(forKey: Quake.Code)
                        }
                    }
                }
            }
        }
    }
    
    /// Plot a passed list of earthquakes on the passed surface.
    /// - Note:
    ///   - Earthquakes are **not** shown if:
    ///     - The `.EnableEarthquakes` flag is false.
    ///     - The view is running in widget mode.
    /// - Parameter List: The list of earthquakes to plot.
    /// - Parameter IsCached: Flag that determines if the earthquakes are from the cache.
    /// - Parameter On: The 3D surface upon which to plot the earthquakes.
    func PlotEarthquakes(_ List: [Earthquake], IsCached: Bool = false, On Surface: SCNNode2)
    {
        if !Settings.GetBool(.EnableEarthquakes)
        {
            return
        }
        /*
        if InWidgetMode
        {
            return
        }
         */

        var MaxSignificance = 0
        for Quake in List
        {
            if Quake.Significance > MaxSignificance
            {
                MaxSignificance = Quake.Significance
            }
        }
        for Quake in List
        {
            let (QShape, MagShape, InfoNode) = MakeEarthquakeNode(Quake, IsCached: IsCached)
            if let INode = InfoNode
            {
                Surface.addChildNode(INode)
            }
            if let QNode = QShape
            {
                var BaseColor = Settings.GetColor(.BaseEarthquakeColor, UIColor.red)
                let HighlightHow = Settings.GetEnum(ForKey: .EarthquakeStyles,
                                                    EnumType: EarthquakeIndicators.self,
                                                    Default: .None)
                //let QuakeShapeType =  Settings.GetEnum(ForKey: .EarthquakeShapes,
                //                                       EnumType: EarthquakeShapes.self,
                //                                       Default: .Arrow)
                if HighlightHow != .None //&& QuakeShapeType != .TetheredNumber
                {
                    let HowRecent = Settings.GetEnum(ForKey: .RecentEarthquakeDefinition, EnumType: EarthquakeRecents.self,
                                                     Default: .Day1)
                    if let RecentSeconds = RecentMap[HowRecent]
                    {
                        if Quake.GetAge() <= RecentSeconds
                        {
                            let Ind = HighlightEarthquake(Quake)
                            Ind.name = GlobeNodeNames.IndicatorNode.rawValue
                            Surface.addChildNode(Ind)
                        }
                    }
                }
                
                QNode.geometry?.firstMaterial?.emission.contents = nil
                let MagRange = GetMagnitudeRange(For: Quake.GreatestMagnitude)
                let Colors = Settings.GetMagnitudeColors()
                for (Magnitude, Color) in Colors
                {
                    if Magnitude == MagRange
                    {
                        BaseColor = Color
                    }
                }
                
                let Shape = Settings.GetEnum(ForKey: .EarthquakeShapes, EnumType: EarthquakeShapes.self, Default: .Sphere)
                switch Shape
                {
                    case .Arrow, .StaticArrow:
                        if let ANode = QNode.childNodes.first as? SCNSimpleArrow
                        {
                            ANode.Color = BaseColor
                        }
                        
                    case .PulsatingSphere:
                        QNode.geometry?.firstMaterial?.diffuse.contents = BaseColor.withAlphaComponent(0.6)
                        
                    default:
                        QNode.geometry?.firstMaterial?.diffuse.contents = BaseColor
                }
                
                if MagShape != nil
                {
                    MagShape?.geometry?.firstMaterial?.diffuse.contents = BaseColor
                    MagShape?.geometry?.firstMaterial?.specular.contents = UIColor.white
                    Surface.addChildNode(MagShape!)
                }
                
                Surface.addChildNode(QNode)
                #if true
                let Day = TimeAttributes(ForDay: true, Diffuse: BaseColor, Emission: nil)
                let Night = TimeAttributes(ForDay: false, Diffuse: BaseColor, Emission: BaseColor)
                let MagString = "M\(Quake.Magnitude.RoundedTo(2))"
                let FontSize = Defaults.MagnitudeFontSizeMultiplier.rawValue *
                    (Quake.Magnitude / PhysicalConstants.GreatestEarthquake.rawValue) +
                    Defaults.MagnitudeBaseFontSize.rawValue
                let QuakeFont = UIFont(name: "Avenir-Black", size: CGFloat(FontSize))!
                let RadialOffset = GlobeRadius.QuakeMagnitudeBaseRadius.rawValue +
                    CGFloat((Quake.Magnitude / PhysicalConstants.GreatestEarthquake.rawValue)) *
                    GlobeRadius.QuakeMagnitudeMultiplier.rawValue
                let MagText = SCNText(string: MagString, extrusionDepth: CGFloat(Defaults.MagnitudeExtrusion.rawValue))
                let MagNode = SCNNode2(geometry: MagText)
                MagNode.Latitude = Quake.Latitude
                MagNode.Longitude = Quake.Longitude
                Day.ApplyTo(MagNode)
                Night.ApplyTo(MagNode)
                MagNode.SetDaylightState()
                MagText.font = QuakeFont
                let (X, Y, Z) = Geometry.ToECEF(Quake.Latitude, Quake.Longitude,
                                                Radius: Double(GlobeRadius.Primary.rawValue + RadialOffset))
                MagNode.name = GlobeNodeNames.MagnitudeNode.rawValue
                Surface.addChildNode(MagNode)
                MagNode.position = SCNVector3(X, Y, Z)
                MagNode.scale = SCNVector3(0.05)
                //https://stackoverflow.com/questions/25266017/rotate-scntext-node-around-center-of-itself-swift-scenekit
                MagNode.pivot = SCNMatrix4MakeTranslation((MagNode.boundingBox.max.x - MagNode.boundingBox.min.x) / 2.0,
                                                       (MagNode.boundingBox.max.y - MagNode.boundingBox.min.y) / 1.0,
                                                       0.0)
                let XRotation = -Quake.Latitude
                let YRotation = Quake.Longitude
                MagNode.eulerAngles = SCNVector3(XRotation.Radians, YRotation.Radians, 0.0)
                #else
                let Day = TimeAttributes(ForDay: true, Diffuse: BaseColor, Emission: nil)
                let Night = TimeAttributes(ForDay: false, Diffuse: BaseColor, Emission: BaseColor)
                let MagString = "M\(Quake.Magnitude.RoundedTo(2))"
                let FontSize = Defaults.MagnitudeFontSizeMultiplier.rawValue *
                    (Quake.Magnitude / PhysicalConstants.GreatestEarthquake.rawValue) +
                    Defaults.MagnitudeBaseFontSize.rawValue
                let QuakeFont = UIFont(name: "Avenir-Black", size: CGFloat(FontSize))!
                let RadialOffset = GlobeRadius.QuakeMagnitudeBaseRadius.rawValue +
                    CGFloat((Quake.Magnitude / PhysicalConstants.GreatestEarthquake.rawValue)) *
                    GlobeRadius.QuakeMagnitudeMultiplier.rawValue
                let QMag = PlotFloatingText(MagString,
                                            Radius: Double(GlobeRadius.Primary.rawValue + RadialOffset),
                                            Latitude: Quake.Latitude,
                                            Longitude: Quake.Longitude,
                                            Extrusion: Defaults.MagnitudeExtrusion.rawValue,
                                            Font: QuakeFont,
                                            Day: Day,
                                            Night: Night,
                                            LightMask: LightMasks3D.Sun.rawValue | LightMasks3D.Moon.rawValue,
                                            Name: GlobeNodeNames.MagnitudeNode.rawValue)
                Surface.addChildNode(QMag!)
                #endif
            }
        }
    }
    
    /// Create a shape for the passed earthquake. Additionally, an extruded text shape may be returned.
    /// - Note: If extruded magnitude values are specified as the node, node shapes are not drawn - just the
    ///         extruded number.
    /// - Parameter Quake: The earthquake whose shape will be created.
    /// - Parameter IsCached: If true, the earthquake is from the cache.
    /// - Returns: Tuple of three `SCNNode2`s. The first is a shape to be used to indicate an earthquake and the
    ///            second (which may not be present, depending on the value of `.EarthquakeMagnitudeViews`)
    ///            is extruded text with the value of the magntiude of the earthquake. The third node is an
    ///            invisible info node to interact with the mouse.
    func MakeEarthquakeNode(_ Quake: Earthquake, IsCached: Bool = false) -> (Shape: SCNNode2?, Magnitude: SCNNode2?, InfoNode: SCNNode2?)
    {
        let FinalRadius = GlobeRadius.Primary.rawValue
        let Percent = 1.0
        var FinalNode: SCNNode2!
        var YRotation: Double = 0.0
        var XRotation: Double = 0.0
        var RadialOffset: Double = 0.5
        
        var ScaleMultiplier = 1.0
        switch Settings.GetEnum(ForKey: .QuakeScales, EnumType: MapNodeScales.self, Default: .Normal)
        {
            case .Small:
                ScaleMultiplier = 0.5
                
            case .Normal:
                ScaleMultiplier = 1.0
                
            case .Large:
                ScaleMultiplier = 1.5
        }
        
        var MagNode: SCNNode2? = nil
        switch Settings.GetEnum(ForKey: .EarthquakeMagnitudeViews, EnumType: EarthquakeMagnitudeViews.self, Default: .No)
        {
            case .No:
                break
                
            case .Horizontal:
                MagNode = PlotMagnitudes(Quake)
                MagNode?.NodeClass = UUID(uuidString: NodeClasses.Earthquake.rawValue)!
                MagNode?.NodeID = Quake.QuakeID
                MagNode?.name = GlobeNodeNames.EarthquakeNodes.rawValue
                
            case .Vertical:
                MagNode = PlotMagnitudes(Quake, Vertically: true)
                MagNode?.NodeClass = UUID(uuidString: NodeClasses.Earthquake.rawValue)!
                MagNode?.NodeID = Quake.QuakeID
                MagNode?.name = GlobeNodeNames.EarthquakeNodes.rawValue
                
            case .Stenciled:
                break
        }
        
        let Radiusp = Double(FinalRadius) + RadialOffset - Quake3D.InvisibleEarthquakeOffset.rawValue
        let (Xp, Yp, Zp) = Geometry.ToECEF(Quake.Latitude, Quake.Longitude, Radius: Radiusp)
        let ERadius = (Quake.GreatestMagnitude * Quake3D.SphereMultiplier.rawValue) * Quake3D.SphereConstant.rawValue
        let QSphere = SCNSphere(radius: CGFloat(ERadius))
        let InfoNode = SCNNode2(geometry: QSphere)
        InfoNode.name = GlobeNodeNames.InfoNode.rawValue
        InfoNode.CanShowBoundingShape = true
        InfoNode.geometry?.firstMaterial?.diffuse.contents = UIColor.clear
        InfoNode.NodeClass = UUID(uuidString: NodeClasses.Earthquake.rawValue)!
        InfoNode.NodeID = Quake.QuakeID
        InfoNode.position = SCNVector3(Xp, Yp, Zp)
        
        #if false
        let Pole = SCNNode2()
        let PoleGeometry = SCNCylinder(radius: 0.05, height: CGFloat(Quake.Magnitude))
        Pole.geometry = PoleGeometry
        Pole.geometry?.firstMaterial?.diffuse.contents = UIColor.white
        Pole.position = SCNVector3(0.0, CGFloat(-Quake.Magnitude * 0.3), 0.0)
        Pole.Latitude = Quake.Latitude
        Pole.Longitude = Quake.Longitude
        let Day = TimeAttributes(ForDay: true, Diffuse: UIColor.red)
        let Night = TimeAttributes(ForDay: false, Diffuse: UIColor.systemPink, Emission: UIColor.Sunglow)
        Day.ApplyTo(Pole)
        Night.ApplyTo(Pole)
        Pole.SetDaylightState()
        
        for YLocation in stride(from: Int(Quake.Magnitude), to: 0, by: -1)
        {
            let Ring = SCNNode2(geometry: SCNTorus(ringRadius: CGFloat(YLocation) * 0.2, pipeRadius: 0.03))
            Ring.geometry?.firstMaterial?.diffuse.contents = UIColor.systemGreen
            Ring.Latitude = Quake.Latitude
            Ring.Longitude = Quake.Longitude
            let Day = TimeAttributes(ForDay: true, Diffuse: UIColor.systemOrange)
            let Night = TimeAttributes(ForDay: false, Diffuse: UIColor.systemOrange, Emission: UIColor.orange)
            Day.ApplyTo(Ring)
            Night.ApplyTo(Ring)
            Ring.SetDaylightState()
            var FinalY = Double(YLocation)
            FinalY = FinalY - Double(Quake.Magnitude / 2.0)
            Ring.position = SCNVector3(0.0, CGFloat(-FinalY), 0.0)
            Pole.addChildNode(Ring)
        }
        
        let TDay = TimeAttributes(ForDay: true, Diffuse: UIColor.yellow, Specular: UIColor.white, Emission: UIColor.systemYellow)
        let TNight = TimeAttributes(ForDay: false, Diffuse: UIColor.black, Emission: UIColor.white)
        let MagText = "M\(Quake.Magnitude.RoundedTo(2))"
        let QText = SCNText(string: MagText, extrusionDepth: 2.0)
        let QMag = SCNNode2(geometry: QText)
        QText.font = UIFont(name: "Avenir-Black", size: 20.0)!
//        QText.font = UIFont.boldSystemFont(ofSize: 24.0)
        QMag.scale = SCNVector3(0.05)
        //https://stackoverflow.com/questions/25266017/rotate-scntext-node-around-center-of-itself-swift-scenekit
        QMag.pivot = SCNMatrix4MakeTranslation((QMag.boundingBox.max.x - QMag.boundingBox.min.x) / 2.0,
                                               (QMag.boundingBox.max.y - QMag.boundingBox.min.y) / 1.0,
                                               0.0)
        let YTextPos = Quake.Magnitude * 0.85
        QMag.position = SCNVector3(0.0, CGFloat(-YTextPos), 0.0)
        QMag.eulerAngles = SCNVector3(90.0.Radians, 180.0.Radians, 0.0.Radians)
        QMag.Latitude = Quake.Latitude
        QMag.Longitude = Quake.Longitude
        TDay.ApplyTo(QMag)
        TNight.ApplyTo(QMag)
        QMag.SetDaylightState()

        FinalNode = SCNNode2()
        FinalNode.NodeClass = UUID(uuidString: NodeClasses.Earthquake.rawValue)
        FinalNode.NodeID = Quake.QuakeID
        FinalNode.NodeUsage = .Earthquake
        YRotation = Quake.Latitude + 90.0
        XRotation = Quake.Longitude + 180.0

        FinalNode.eulerAngles = SCNVector3(XRotation.Radians, YRotation.Radians, 0.0)
        FinalNode.addChildNode(Pole)
        FinalNode.addChildNode(QMag)

        #else
        switch Settings.GetEnum(ForKey: .EarthquakeShapes, EnumType: EarthquakeShapes.self, Default: .Sphere)
        {
            case .Arrow:
                RadialOffset = 0.7
                let Arrow = SCNSimpleArrow(Length: CGFloat(Quake3D.ArrowLength.rawValue),
                                           Width: CGFloat(Quake3D.ArrowWidth.rawValue),
                                           Extrusion: CGFloat(Quake3D.ArrowExtrusion.rawValue),
                                           Color: Settings.GetColor(.BaseEarthquakeColor, UIColor.systemYellow))
                Arrow.NodeClass = UUID(uuidString: NodeClasses.Earthquake.rawValue)!
                Arrow.NodeID = Quake.QuakeID
                Arrow.LightMask = LightMasks3D.Sun.rawValue | LightMasks3D.Moon.rawValue
                let FinalScale = NodeScales3D.ArrowScale.rawValue * CGFloat(ScaleMultiplier)
                Arrow.scale = SCNVector3(FinalScale, FinalScale, FinalScale)
                Arrow.CanSwitchState = true
                Arrow.SetLocation(Quake.Latitude, Quake.Longitude)
                if IsCached
                {
                    Arrow.SetState(ForDay: true, Color: UIColor.lightGray,
                                   Emission: nil, Model: .physicallyBased, Metalness: nil, Roughness: nil)
                    Arrow.SetState(ForDay: false, Color: UIColor.darkGray,
                                   Emission: UIColor.darkGray,
                                   Model: .physicallyBased, Metalness: nil, Roughness: nil)
                }
                else
                {
                    Arrow.SetState(ForDay: true, Color: Settings.GetColor(.BaseEarthquakeColor, UIColor.red),
                                   Emission: nil, Model: .physicallyBased, Metalness: nil, Roughness: nil)
                    Arrow.SetState(ForDay: false, Color: Settings.GetColor(.BaseEarthquakeColor, UIColor.systemYellow),
                                   Emission: Settings.GetColor(.BaseEarthquakeColor, UIColor.orange),
                                   Model: .physicallyBased, Metalness: nil, Roughness: nil)
                }
                if let InDay = Solar.IsInDaylight(Quake.Latitude, Quake.Longitude)
                {
                    Arrow.IsInDaylight = InDay
                }
                
                YRotation = Quake.Latitude + 90.0
                XRotation = Quake.Longitude + 180.0
                let RotateDirection = Quake.Latitude >= 0.0 ? 1.0 : -1.0
                let Rotate = SCNAction.rotateBy(x: 0.0, y: CGFloat(RotateDirection), z: 0.0,
                                                duration: Quake3D.ArrowRotationDuration.rawValue)
                let RotateForever = SCNAction.repeatForever(Rotate)
                let BounceDistance: CGFloat = CGFloat(Quake3D.ArrowBounceDistance.rawValue)
                let BounceDuration = (10.0 - Quake.GreatestMagnitude) / Quake3D.ArrowBounceDurationDivisor.rawValue
                let BounceAway = SCNAction.move(by: SCNVector3(0.0, -BounceDistance, 0.0), duration: BounceDuration)
                BounceAway.timingMode = .easeOut
                let BounceTo = SCNAction.move(by: SCNVector3(0.0, BounceDistance, 0.0), duration: BounceDuration)
                BounceTo.timingMode = .easeIn
                let BounceSequence = SCNAction.sequence([BounceAway, BounceTo])
                let MoveForever = SCNAction.repeatForever(BounceSequence)
                let AnimationGroup = SCNAction.group([MoveForever, RotateForever])
                Arrow.runAction(AnimationGroup)
                Arrow.runAction(RotateForever)
                
                let Encapsulate = SCNNode2()
                Encapsulate.CanSwitchState = true
                Encapsulate.SetLocation(Quake.Latitude, Quake.Longitude)
                Encapsulate.addChildNode(Arrow)
                FinalNode = Encapsulate
                FinalNode.CanSwitchState = true
                FinalNode.SetLocation(Quake.Latitude, Quake.Longitude)
                if let IsInDay = Solar.IsInDaylight(Quake.Latitude, Quake.Longitude)
                {
                    FinalNode.IsInDaylight = IsInDay
                }
                FinalNode.NodeClass = UUID(uuidString: NodeClasses.Earthquake.rawValue)
                FinalNode.NodeID = Quake.QuakeID
                FinalNode.NodeUsage = .Earthquake
                
            case .StaticArrow:
                RadialOffset = 0.7
                let Arrow = SCNSimpleArrow(Length: CGFloat(Quake3D.StaticArrowLength.rawValue),
                                           Width: CGFloat(Quake3D.StaticArrowWidth.rawValue),
                                           Extrusion: CGFloat(Quake3D.StaticArrowExtrusion.rawValue),
                                           Color: Settings.GetColor(.BaseEarthquakeColor, UIColor.red))
                if IsCached
                {
                    Arrow.Color = UIColor.lightGray
                }
                Arrow.NodeClass = UUID(uuidString: NodeClasses.Earthquake.rawValue)!
                Arrow.NodeID = Quake.QuakeID
                Arrow.LightMask = LightMasks3D.Sun.rawValue | LightMasks3D.Moon.rawValue
                let FinalScale = NodeScales3D.StaticArrow.rawValue * CGFloat(ScaleMultiplier)
                Arrow.scale = SCNVector3(FinalScale,
                                         FinalScale,
                                         FinalScale)
                YRotation = Quake.Latitude + 90.0
                XRotation = Quake.Longitude + 180.0
                let Encapsulate = SCNNode2()
                Encapsulate.addChildNode(Arrow)
                FinalNode = Encapsulate
                FinalNode.NodeClass = UUID(uuidString: NodeClasses.Earthquake.rawValue)!
                FinalNode.NodeID = Quake.QuakeID
                
            case .Pyramid:
                RadialOffset = 0.0
                FinalNode = SCNNode2(geometry: SCNPyramid(width: CGFloat(Quake3D.PyramidWidth.rawValue),
                                                          height: CGFloat(Quake3D.PyramidHeightMultiplier.rawValue * Percent),
                                                          length: CGFloat(Quake3D.PyramidLength.rawValue)))
                if IsCached
                {
                    FinalNode.geometry?.firstMaterial?.diffuse.contents = UIColor.lightGray
                }
                let FinalScale = NodeScales3D.PyramidEarthquake.rawValue * CGFloat(ScaleMultiplier)
                FinalNode.scale = SCNVector3(FinalScale, FinalScale, FinalScale)
                FinalNode.NodeClass = UUID(uuidString: NodeClasses.Earthquake.rawValue)!
                FinalNode.NodeID = Quake.QuakeID
                YRotation = Quake.Latitude + 90.0 + 180.0
                XRotation = Quake.Longitude + 180.0
                
            case .Cone:
                FinalNode = SCNNode2(geometry: SCNCone(topRadius: CGFloat(Quake3D.ConeTopRadius.rawValue),
                                                       bottomRadius: CGFloat(Quake3D.ConeBottomRadius.rawValue),
                                                       height: CGFloat(Quake3D.ConeHeightMultiplier.rawValue * Percent)))
                if IsCached
                {
                    FinalNode.geometry?.firstMaterial?.diffuse.contents = UIColor.lightGray
                }
                let FinalScale = NodeScales3D.ConeEarthquake.rawValue * CGFloat(ScaleMultiplier)
                FinalNode.scale = SCNVector3(FinalScale, FinalScale, FinalScale)
                FinalNode.NodeClass = UUID(uuidString: NodeClasses.Earthquake.rawValue)!
                FinalNode.NodeID = Quake.QuakeID
                YRotation = Quake.Latitude + 90.0 + 180.0
                XRotation = Quake.Longitude + 180.0
                
            case .Box:
                FinalNode = SCNNode2(geometry: SCNBox(width: CGFloat(Quake3D.QuakeBoxWidth.rawValue),
                                                      height: CGFloat(Quake3D.QuakeBoxHeight.rawValue * Percent),
                                                      length: CGFloat(Quake3D.QuakeBoxLength.rawValue),
                                                      chamferRadius: CGFloat(Quake3D.QuakeBoxChamfer.rawValue)))
                if IsCached
                {
                    FinalNode.geometry?.firstMaterial?.diffuse.contents = UIColor.lightGray
                }
                let FinalScale = NodeScales3D.BoxEarthquake.rawValue * CGFloat(ScaleMultiplier)
                FinalNode.scale = SCNVector3(FinalScale, FinalScale, FinalScale)
                FinalNode.NodeClass = UUID(uuidString: NodeClasses.Earthquake.rawValue)!
                FinalNode.NodeID = Quake.QuakeID
                YRotation = Quake.Latitude + 90.0
                XRotation = Quake.Longitude + 180.0
                
            case .Cylinder:
                FinalNode = SCNNode2(geometry: SCNCylinder(radius: CGFloat(Percent * Quake3D.QuakeCapsuleRadius.rawValue),
                                                           height: CGFloat(Quake3D.QuakeCapsuleHeight.rawValue * Percent)))
                if IsCached
                {
                    FinalNode.geometry?.firstMaterial?.diffuse.contents = UIColor.lightGray
                }
                let FinalScale = NodeScales3D.CylinderEarthquake.rawValue * CGFloat(ScaleMultiplier)
                FinalNode.scale = SCNVector3(FinalScale, FinalScale, FinalScale)
                FinalNode.NodeClass = UUID(uuidString: NodeClasses.Earthquake.rawValue)!
                FinalNode.NodeID = Quake.QuakeID
                YRotation = Quake.Latitude + 90.0
                XRotation = Quake.Longitude + 180.0
                
            case .Capsule:
                FinalNode = SCNNode2(geometry: SCNCapsule(capRadius: CGFloat(Percent * Quake3D.QuakeCapsuleRadius.rawValue),
                                                          height: CGFloat(Quake3D.QuakeCapsuleHeight.rawValue * Percent)))
                if IsCached
                {
                    FinalNode.geometry?.firstMaterial?.diffuse.contents = UIColor.lightGray
                }
                let FinalScale = NodeScales3D.CapsuleEarthquake.rawValue * CGFloat(ScaleMultiplier)
                FinalNode.scale = SCNVector3(FinalScale, FinalScale, FinalScale)
                FinalNode.NodeClass = UUID(uuidString: NodeClasses.Earthquake.rawValue)!
                FinalNode.NodeID = Quake.QuakeID
                YRotation = Quake.Latitude + 90.0
                XRotation = Quake.Longitude + 180.0
                
            case .Sphere:
                let ERadius = (Quake.GreatestMagnitude * Quake3D.SphereMultiplier.rawValue) * Quake3D.SphereConstant.rawValue
                let QSphere = SCNSphere(radius: CGFloat(ERadius))
                FinalNode = SCNNode2(geometry: QSphere)
                if IsCached
                {
                    FinalNode.geometry?.firstMaterial?.diffuse.contents = UIColor.lightGray
                }
                let FinalScale = NodeScales3D.SphereEarthquake.rawValue * CGFloat(ScaleMultiplier)
                FinalNode.scale = SCNVector3(FinalScale, FinalScale, FinalScale)
                FinalNode.NodeClass = UUID(uuidString: NodeClasses.Earthquake.rawValue)!
                FinalNode.NodeID = Quake.QuakeID
                
            case .PulsatingSphere:
                let ERRadius = (Quake.GreatestMagnitude * Quake3D.SphereMultiplier.rawValue) * Quake3D.PulsatingSphereConstant.rawValue
                let ScaleDuration: Double = Quake3D.PulsatingBase.rawValue +
                    (10 - Quake.GreatestMagnitude) * Quake3D.MagnitudeMultiplier.rawValue
                let QSphere = SCNSphere(radius: CGFloat(ERRadius))
                let ScaleUp = SCNAction.scale(to: CGFloat(Quake3D.PulsatingSphereMaxScale.rawValue), duration: ScaleDuration)
                let ScaleDown = SCNAction.scale(to: 1.0, duration: ScaleDuration)
                let ScaleGroup = SCNAction.sequence([ScaleUp, ScaleDown])
                let ScaleForever = SCNAction.repeatForever(ScaleGroup)
                FinalNode = SCNNode2(geometry: QSphere)
                if IsCached
                {
                    FinalNode.geometry?.firstMaterial?.diffuse.contents = UIColor.lightGray
                }
                FinalNode.NodeClass = UUID(uuidString: NodeClasses.Earthquake.rawValue)!
                FinalNode.NodeID = Quake.QuakeID
                FinalNode.runAction(ScaleForever)
                
            case .TetheredNumber:
                var IsInDay = true
                if let InDay = Solar.IsInDaylight(Quake.Latitude, Quake.Longitude)
                {
                    IsInDay = InDay
                }
                var IsRecentQuake = false
                let HighlightHow = Settings.GetEnum(ForKey: .EarthquakeStyles, EnumType: EarthquakeIndicators.self,
                                                    Default: .None)
                if HighlightHow != .None
                {
                    let HowRecent = Settings.GetEnum(ForKey: .RecentEarthquakeDefinition, EnumType: EarthquakeRecents.self,
                                                     Default: .Day1)
                    if let RecentSeconds = RecentMap[HowRecent]
                    {
                        if Quake.GetAge() <= RecentSeconds
                        {
                            IsRecentQuake = true
                        }
                    }
                }
                let BaseRadius = Quake3D.BaseDiscRadius.rawValue
                let QuakeColorMagnitude = GetMagnitudeRange(For: Quake.Magnitude)
                var QuakeColor = UIColor.yellow
                if let MagColor = Settings.GetMagnitudeColors()[QuakeColorMagnitude]
                {
                    QuakeColor = MagColor
                }
                let LocalPercent = Quake.Magnitude / 10.0
                let NodeHeight = CGFloat(Quake3D.QuakeCapsuleHeight.rawValue * LocalPercent)
                let PoleNode = SCNNode2(geometry: SCNCylinder(radius: CGFloat(LocalPercent * Quake3D.DiscPoleRadius.rawValue),
                                                              height: NodeHeight))
                let FinalScale = NodeScales3D.CylinderEarthquake.rawValue * CGFloat(ScaleMultiplier)
                PoleNode.scale = SCNVector3(FinalScale, FinalScale, FinalScale)
                PoleNode.NodeClass = UUID(uuidString: NodeClasses.Earthquake.rawValue)!
                PoleNode.NodeID = Quake.QuakeID
                //Move the pole such that most of it is visible.
                PoleNode.position = SCNVector3(0.0, -NodeHeight * 0.5, 0.0)
                PoleNode.SetState(ForDay: true, Color: QuakeColor, Emission: nil)
                PoleNode.SetState(ForDay: false, Color: QuakeColor, Emission: QuakeColor)
                PoleNode.IsInDaylight = IsInDay
                YRotation = Quake.Latitude + 90.0
                XRotation = Quake.Longitude + 180.0
                let RimRadius = CGFloat(BaseRadius * LocalPercent) + CGFloat(Quake3D.RimRadiusOffset.rawValue)
                let Rim = SCNNode2(geometry: SCNTorus(ringRadius: RimRadius,
                                                      pipeRadius: CGFloat(Quake3D.RimRadiusOffset.rawValue)))
                Rim.geometry?.firstMaterial?.diffuse.contents = QuakeColor
                Rim.SetState(ForDay: true, Color: QuakeColor, Emission: nil)
                Rim.SetState(ForDay: false, Color: QuakeColor, Emission: QuakeColor)
                Rim.IsInDaylight = IsInDay
                if IsRecentQuake
                {
                    for Angle in stride(from: 0, to: 360, by: Int(Quake3D.NewQuakeStrideAngle.rawValue))
                    {
                        let RNode = SCNNode2()
                        let RNodeShape = SCNSphere(radius: CGFloat(Quake3D.NewQuakeSphereRadius.rawValue))
                        RNode.geometry = RNodeShape
                        RNode.geometry?.firstMaterial?.diffuse.contents = UIColor.Gold
                        RNode.geometry?.firstMaterial?.specular.contents = UIColor.white
                        RNode.SetState(ForDay: true, Color: UIColor.systemRed, Emission: nil,
                                       Model: .physicallyBased,
                                       Metalness: Quake3D.DayMetalnessValue.rawValue,
                                       Roughness: Quake3D.DayRoughnessValue.rawValue)
                        RNode.SetState(ForDay: false, Color: UIColor.red, Emission: UIColor.systemPink)
                        RNode.IsInDaylight = IsInDay
                        let X = RimRadius * cos(CGFloat(Angle).Radians)
                        let Y = RimRadius * sin(CGFloat(Angle).Radians)
                        RNode.position = SCNVector3(X, 0.0, Y)
                        Rim.addChildNode(RNode)
                    }
                    var RotateSpeed = Quake3D.BaseDiscRotateSpeed.rawValue * (1.0 - LocalPercent)
                    if RotateSpeed < Quake3D.MinimumRotateSpeed.rawValue
                    {
                        RotateSpeed = Quake3D.MinimumRotateSpeed.rawValue
                    }
                    let RimRotate = SCNAction.rotate(by: CGFloat(180.0.Radians), around: SCNVector3(0.0, 1.0, 0.0),
                                                     duration: RotateSpeed)
                    let RotateForever = SCNAction.repeatForever(RimRotate)
                    Rim.runAction(RotateForever)
                }
                let Disc = SCNNode2(geometry: SCNCylinder(radius: CGFloat(BaseRadius * LocalPercent),
                                                          height: CGFloat(Quake3D.DiscThickness.rawValue)))
                Disc.geometry?.firstMaterial?.diffuse.contents = QuakeColor.withAlphaComponent(CGFloat(Quake3D.DiscAlphaValue.rawValue))
                let TextValue = "\(Quake.Magnitude.RoundedTo(1))"
                let MTextShape = SCNText(string: TextValue, extrusionDepth: CGFloat(Quake3D.DiscTextHeight.rawValue))
                let FontSize: CGFloat = CGFloat(Quake3D.BaseDiscFontSize.rawValue) +
                    (CGFloat(Quake3D.VariableDiscFontAdder.rawValue) * CGFloat(LocalPercent))
                MTextShape.font = UIFont.boldSystemFont(ofSize: FontSize)
                MTextShape.flatness = 0.0
                let MText = SCNNode2(geometry: MTextShape)
                let TextScale = Quake3D.DiscTextScale.rawValue + (Quake3D.DiscTextScale.rawValue * LocalPercent)
                MText.scale = SCNVector3(TextScale)
                MText.SetState(ForDay: true, Color: UIColor.black, Emission: nil)
                MText.SetState(ForDay: false, Color: UIColor.white, Emission: UIColor.white)
                MText.eulerAngles = SCNVector3(90.0.Radians, 180.0.Radians, 0.0)

                Disc.addChildNode(MText)
                Disc.NodeClass = UUID(uuidString: NodeClasses.Earthquake.rawValue)!
                Disc.NodeID = Quake.QuakeID
                Disc.position = SCNVector3(0.0, -NodeHeight, 0.0)
                Rim.position = SCNVector3(0.0, -NodeHeight, 0.0)
                let MTextWidth = abs(MText.boundingBox.max.x - MText.boundingBox.min.x) * 0.01
                let MTextHeight = abs(MText.boundingBox.max.y - MText.boundingBox.min.y) * 0.01
                MText.position = SCNVector3(MTextWidth, Float(Quake3D.DiscTextYOffset.rawValue), MTextHeight)
                
                FinalNode = SCNNode2()
                FinalNode.NodeClass = UUID(uuidString: NodeClasses.Earthquake.rawValue)!
                FinalNode.NodeID = Quake.QuakeID
                FinalNode.addChildNode(PoleNode)
                FinalNode.addChildNode(Disc)
                FinalNode.addChildNode(Rim)
                RadialOffset = 0.0
        }
        #endif
        
        let (X, Y, Z) = Geometry.ToECEF(Quake.Latitude, Quake.Longitude, Radius: Double(FinalRadius) + RadialOffset)
        FinalNode.name = GlobeNodeNames.EarthquakeNodes.rawValue
        FinalNode.SetLocation(Quake.Latitude, Quake.Longitude)
        FinalNode.NodeUsage = .Earthquake
        FinalNode.categoryBitMask = LightMasks3D.Sun.rawValue | LightMasks3D.Moon.rawValue
        FinalNode.position = SCNVector3(X, Y, Z)
        FinalNode.eulerAngles = SCNVector3(YRotation.Radians, XRotation.Radians, 0.0)
        return (FinalNode, MagNode, InfoNode)
    }
    
    /// Determines if a given earthquake happened in the number of days prior to the instance.
    /// - Parameter Quake: The earthquake to test against `InRange`.
    /// - Parameter InRange: The range of allowable earthquakes.
    /// - Returns: True if `Quake` is within the age range specified by `InRange`, false if not.
    func InAgeRange(_ Quake: Earthquake, InRange: EarthquakeAges) -> Bool
    {
        let Index = EarthquakeAges.allCases.firstIndex(of: InRange)! + 1
        let Seconds = Index * (60 * 60 * 24)
        let Delta = Date().timeIntervalSinceReferenceDate - Quake.Time.timeIntervalSinceReferenceDate
        return Int(Delta) < Seconds
    }
    
    /// Return a range enum for the passed earthquake magnitude.
    /// - Parameter For: The magnitude whose range will be returned.
    /// - Returns: Enum from `EarthquakeMagnitudes` that indicates it's range.
    func GetMagnitudeRange(For: Double) -> EarthquakeMagnitudes
    {
        let InitialValue = EarthquakeMagnitudes.allCases[0].rawValue
        let Modified = For - InitialValue
        if Modified < 0.0
        {
            return EarthquakeMagnitudes.allCases[0]
        }
        let IModified = Int(Modified)
        if IModified > EarthquakeMagnitudes.allCases.count - 1
        {
            return EarthquakeMagnitudes.allCases.last!
        }
        return EarthquakeMagnitudes.allCases[IModified]
    }
    
    /// Returns the ages in seconds of the oldest earthquake in the list.
    /// - Parameter InList: The list of earthquakes to seach.
    /// - Returns: The age of the oldest earthquake in seconds.
    func OldestEarthquakeOccurence(_ InList: [Earthquake]) -> Double
    {
        let Now = Date()
        var Oldest = Now
        for Quake in InList
        {
            if Quake.Time < Oldest
            {
                Oldest = Quake.Time
            }
        }
        return Now.timeIntervalSinceReferenceDate - Oldest.timeIntervalSinceReferenceDate
    }
    
    /// Returns the population of the closest city to the passed earthquake.
    /// - Parameter To: The earthquake whose closest city's population will be returned.
    /// - Parameter UseMetroPopulation: If true, the metropolitan population is returned.
    /// - Returns: The population of the closest earthquake to the passed city. If no population is
    ///            available (eg, the city does not have a listed population or there are no cities
    ///            being plotted), `0` is returned.
    func PopulationOfClosestCity(To Quake: Earthquake, UseMetroPopulation: Bool = true) -> Int
    {
        var ClosestCity: City2? = nil
        var Distance: Double = Double.greatestFiniteMagnitude
        for SomeCity in CitiesToPlot
        {
            let (QX, QY, QZ) = Geometry.ToECEF(Quake.Latitude, Quake.Longitude, Radius: Double(GlobeRadius.Primary.rawValue))
            let (CX, CY, CZ) = Geometry.ToECEF(SomeCity.Latitude, SomeCity.Longitude, Radius: Double(GlobeRadius.Primary.rawValue))
            let PDistance = Geometry.Distance3D(X1: QX, Y1: QY, Z1: QZ, X2: CX, Y2: CY, Z2: CZ)
            if PDistance < Distance
            {
                Distance = PDistance
                ClosestCity = SomeCity
            }
        }
        if let CloseCity = ClosestCity
        {
            return CloseCity.GetPopulation(UseMetroPopulation)
        }
        return 0
    }
    
    func NodesWithName(_ Name: String, In Parent: SCNNode) -> Int
    {
        var Count = 0
        for Child in Parent.childNodes
        {
            if Child.name == Name
            {
                Count = Count + 1
            }
        }
        return Count
    }
    
    /// Plot earthquakes as text indicating the magnitude of the earthquake.
    /// - Parameter Quake: The earthquake to plot.
    /// - Parameter Vertically: If true, text is plotted vertically.
    /// - Parameter AtHeight: If non-nil, the height of the text over the Earth.
    /// - Parameter Prefix: Prefix for the magnitude value. Defaults to "• M".
    /// - Returns: Node with extruded text indicating the earthquake.
    func PlotMagnitudes(_ Quake: Earthquake, Vertically: Bool = false, AtHeight: Double? = nil,
                        Prefix: String = "• M") -> SCNNode2
    {
        var Radius = Double(GlobeRadius.Primary.rawValue) + 0.5
        let Magnitude = "\(Prefix)\(Quake.GreatestMagnitude.RoundedTo(1))"
        
        let MagText = SCNText(string: Magnitude, extrusionDepth: CGFloat(Quake.GreatestMagnitude))
        let FontSize = CGFloat(18.0 + Quake.GreatestMagnitude)
        let EqFont = Settings.GetFont(.EarthquakeFontName, StoredFont("Avenir-Heavy", 18.0, UIColor.black))
        MagText.font = UIFont(name: EqFont.PostscriptName, size: FontSize)
        MagText.flatness = 0.1
        MagText.firstMaterial?.specular.contents = UIColor.white
        MagText.firstMaterial?.lightingModel = .physicallyBased
        let MagNode = SCNNode2(geometry: MagText)
        MagNode.SetLocation(Quake.Latitude, Quake.Longitude)
        MagNode.categoryBitMask = LightMasks3D.MetalSun.rawValue | LightMasks3D.MetalMoon.rawValue
        MagNode.scale = SCNVector3(NodeScales3D.EarthquakeText.rawValue,
                                   NodeScales3D.EarthquakeText.rawValue,
                                   NodeScales3D.EarthquakeText.rawValue)
        MagNode.name = GlobeNodeNames.EarthquakeNodes.rawValue
        var YOffset = CGFloat(MagNode.boundingBox.max.y - MagNode.boundingBox.min.y) * NodeScales3D.EarthquakeText.rawValue
        YOffset = CGFloat(MagNode.boundingBox.max.y) * NodeScales3D.EarthquakeText.rawValue * 3.5
        let XOffset = CGFloat((MagNode.boundingBox.max.y - MagNode.boundingBox.min.y) / 2.0) * NodeScales3D.EarthquakeText.rawValue -
        (CGFloat(MagNode.boundingBox.min.y) * NodeScales3D.EarthquakeText.rawValue)
        if let HeightOffset = AtHeight
        {
            Radius = Radius + HeightOffset
        }
        let (X, Y, Z) = Geometry.ToECEF(Quake.Latitude,
                                        Quake.Longitude,
                                        LatitudeOffset: Double(-YOffset),
                                        LongitudeOffset: Double(XOffset),
                                        Radius: Radius)
        MagNode.position = SCNVector3(X, Y, Z)
        
        var QuakeColor: UIColor = UIColor.red
        let MagRange = GetMagnitudeRange(For: Quake.GreatestMagnitude)
        let Colors = Settings.GetMagnitudeColors()
        for (Magnitude, Color) in Colors
        {
            if Magnitude == MagRange
            {
                QuakeColor = Color
            }
        }
        let Day: EventAttributes =
        { 
            let D = EventAttributes()
            D.ForEvent = .SwitchToDay
            D.Diffuse = QuakeColor
            D.Specular = UIColor(RGB: Colors3D.HourSpecular.rawValue)
            D.Emission = nil
            return D
        }()
        let Night: EventAttributes =
            {
                let N = EventAttributes()
                N.ForEvent = .SwitchToNight
                N.Diffuse = QuakeColor
                N.Specular = UIColor(RGB: Colors3D.HourSpecular.rawValue)
                N.Emission = QuakeColor.Darker()
                return N
            }()
        MagNode.AddEventAttributes(Event: .SwitchToDay, Attributes: Day)
        MagNode.AddEventAttributes(Event: .SwitchToNight, Attributes: Night)
        
        if Quake.IsCluster
        {
            let LowerShape = SCNBox(width: CGFloat(MagNode.boundingBox.max.x),
                                    height: 4.0,
                                    length: 1.0,
                                    chamferRadius: 0.0)
            let Lower = SCNNode2(geometry: LowerShape)
            Lower.categoryBitMask = LightMasks3D.Sun.rawValue | LightMasks3D.Moon.rawValue
            Lower.geometry?.firstMaterial?.diffuse.contents = Settings.GetColor(.CombinedEarthquakeColor, UIColor.systemRed)
            Lower.geometry?.firstMaterial?.specular.contents = UIColor.white
            let WidthOffset = MagNode.boundingBox.max.x / 2.0
            Lower.position = SCNVector3(MagNode.boundingBox.min.x + WidthOffset, 3.5, 0.0)
            MagNode.addChildNode(Lower)
            
            let UpperShape = SCNBox(width: CGFloat(MagNode.boundingBox.max.x), height: 4.0, length: 1.0,
                                    chamferRadius: 0.0)
            let Upper = SCNNode2(geometry: UpperShape)
            Upper.categoryBitMask = LightMasks3D.Sun.rawValue | LightMasks3D.Moon.rawValue
            Upper.geometry?.firstMaterial?.diffuse.contents = Settings.GetColor(.CombinedEarthquakeColor, UIColor.systemRed)
            Upper.geometry?.firstMaterial?.specular.contents = UIColor.white
            Upper.position = SCNVector3(MagNode.boundingBox.min.x + WidthOffset,
                                        MagNode.boundingBox.max.y + 3.5, 0.0)
            MagNode.addChildNode(Upper)
        }
        
        var YRotation = -Quake.Latitude
        var XRotation = Quake.Longitude
        var ZRotation = 0.0
        if Vertically
        {
            YRotation = Quake.Latitude
            XRotation = Quake.Longitude + 270.0
            YRotation = 0.0
            ZRotation = 0.0
        }
        MagNode.eulerAngles = SCNVector3(YRotation.Radians, XRotation.Radians, ZRotation.Radians)
        
        return MagNode
    }
    
    /// Visually highlight the passed earthquake.
    /// - Note: If the indicator is already present, it is not redrawn.
    /// - Parameter Quake: The earthquake to highlight.
    /// - Returns: An `SCNNode` to be used as an indicator of a recent earthquake.
    func HighlightEarthquake(_ Quake: Earthquake) -> SCNNode2
    {
        let Final = SCNNode2()
        Final.NodeID = Quake.QuakeID
        Final.NodeClass = UUID(uuidString: NodeClasses.Earthquake.rawValue)!
        if IndicatorAgeMap[Quake.Code] != nil
        {
            return Final
        }
        let IndicatorType = Settings.GetEnum(ForKey: .EarthquakeStyles, EnumType: EarthquakeIndicators.self,
                                             Default: .None)
        switch IndicatorType
        {
            case .AnimatedRing:
                let Radius = Double(GlobeRadius.Primary.rawValue) + 0.3
                let (X, Y, Z) = Geometry.ToECEF(Quake.Latitude, Quake.Longitude, Radius: Radius)
                let IndicatorShape = SCNTorus(ringRadius: 0.9, pipeRadius: 0.1)
                let Indicator = SCNNode2(geometry: IndicatorShape)
                #if true
                Indicator.geometry?.firstMaterial?.diffuse.contents = UIColor(RGB: 0xffa080)
                let Day: EventAttributes =
                    {
                        let D = EventAttributes()
                        D.ForEvent = .SwitchToDay
                        D.Diffuse = UIColor(RGB: 0xffa080)
                        D.Emission = nil
                        return D
                    }()
                let Night: EventAttributes =
                    {
                        let N = EventAttributes()
                        N.ForEvent = .SwitchToNight
                        N.Diffuse = UIColor(RGB: 0xffa080)
                        N.Emission = UIColor.red
                        return N
                    }()
                Indicator.CanSwitchState = true
                Indicator.AddEventAttributes(Event: .SwitchToDay, Attributes: Day)
                Indicator.AddEventAttributes(Event: .SwitchToNight, Attributes: Night)
                if let IsInDay = Solar.IsInDaylight(Quake.Latitude, Quake.Longitude)
                {
                    Indicator.IsInDaylight = IsInDay
                }
                #else
                let TextureType = Settings.GetEnum(ForKey: .EarthquakeTextures, EnumType: EarthquakeTextures.self, Default: .Gradient1)
                guard let TextureName = TextureMap[TextureType] else
                {
                    fatalError("Error getting texture \(TextureType)")
                }
                if TextureName.isEmpty
                {
                    let SolidColor = Settings.GetColor(.EarthquakeColor, UIColor.red)
                    Indicator.geometry?.firstMaterial?.diffuse.contents = SolidColor
                }
                else
                {
                    Indicator.geometry?.firstMaterial?.diffuse.contents = UIImage(named: TextureName)
                }
                Indicator.geometry?.firstMaterial?.specular.contents = UIColor.white
                #endif
                Indicator.categoryBitMask = LightMasks3D.MetalSun.rawValue | LightMasks3D.MetalMoon.rawValue
                
                let Rotate = SCNAction.rotateBy(x: CGFloat(0.0.Radians),
                                                y: CGFloat(360.0.Radians),
                                                z: CGFloat(0.0.Radians),
                                                duration: 1.0)
                let ScaleDuration = 1.0 - (Quake.GreatestMagnitude / 10.0)
                var ToScale = (0.3 * (1.0 - (Quake.GreatestMagnitude / 10.0)))
                ToScale = ToScale + Double(NodeScales3D.AnimatedRingBase.rawValue)
                let ScaleUp = SCNAction.scale(to: CGFloat(ToScale), duration: 1.0 + ScaleDuration)
                let ScaleDown = SCNAction.scale(to: 1.0, duration: 1.0 + ScaleDuration)
                let ScaleGroup = SCNAction.sequence([ScaleUp, ScaleDown])
                let ScaleForever = SCNAction.repeatForever(ScaleGroup)
                Indicator.runAction(ScaleForever)
                let Forever = SCNAction.repeatForever(Rotate)
                Indicator.runAction(Forever)
                let YRotation = Quake.Latitude + 90.0
                let XRotation = Quake.Longitude + 180.0
                let ZRotation = 0.0
                Final.eulerAngles = SCNVector3(YRotation.Radians, XRotation.Radians, ZRotation.Radians)
                Final.position = SCNVector3(X, Y, Z)
                Final.addChildNode(Indicator)
                Final.name = GlobeNodeNames.EarthquakeNodes.rawValue
                
            case .StaticRing:
                let Radius = Double(GlobeRadius.Primary.rawValue) + 0.3
                let (X, Y, Z) = Geometry.ToECEF(Quake.Latitude, Quake.Longitude, Radius: Radius)
                let IndicatorShape = SCNTorus(ringRadius: 0.9, pipeRadius: 0.1)
                let Indicator = SCNNode2(geometry: IndicatorShape)
                let StaticColor = Settings.GetColor(.EarthquakeColor, UIColor.red)
                Indicator.geometry?.firstMaterial?.diffuse.contents = StaticColor
                Indicator.geometry?.firstMaterial?.specular.contents = UIColor.white
                Indicator.categoryBitMask = LightMasks3D.MetalSun.rawValue | LightMasks3D.MetalMoon.rawValue
                let YRotation = Quake.Latitude + 90.0
                let XRotation = Quake.Longitude + 180.0
                let ZRotation = 0.0
                Final.eulerAngles = SCNVector3(YRotation.Radians, XRotation.Radians, ZRotation.Radians)
                Final.position = SCNVector3(X, Y, Z)
                Final.addChildNode(Indicator)
                Final.name = GlobeNodeNames.EarthquakeNodes.rawValue
                
            case .GlowingSphere:
                let Radius = Double(GlobeRadius.Primary.rawValue)
                let (X, Y, Z) = Geometry.ToECEF(Quake.Latitude, Quake.Longitude, Radius: Radius)
                let IndicatorShape = SCNSphere(radius: 0.75)
                let Indicator = SCNNode2(geometry: IndicatorShape)
                let Color = Settings.GetColor(.EarthquakeColor, UIColor.red).withAlphaComponent(0.45)
                Indicator.geometry?.firstMaterial?.diffuse.contents = Color
                Indicator.geometry?.firstMaterial?.specular.contents = UIColor.white
                Indicator.categoryBitMask = LightMasks3D.MetalSun.rawValue | LightMasks3D.MetalMoon.rawValue
                let YRotation = Quake.Latitude + 90.0
                let XRotation = Quake.Longitude + 180.0
                let ZRotation = 0.0
                Final.eulerAngles = SCNVector3(YRotation.Radians, XRotation.Radians, ZRotation.Radians)
                Final.position = SCNVector3(X, Y, Z)
                Final.addChildNode(Indicator)
                Final.name = GlobeNodeNames.EarthquakeNodes.rawValue
                
            case .RadiatingRings:
                let Radius = Double(GlobeRadius.Primary.rawValue)
                let (X, Y, Z) = Geometry.ToECEF(Quake.Latitude, Quake.Longitude, Radius: Radius)
                let IndicatorShape = SCNTorus(ringRadius: 0.9, pipeRadius: 0.15)
                let Indicator = SCNNode2(geometry: IndicatorShape)
                let InitialAlpha: CGFloat = 0.8
                Indicator.geometry?.firstMaterial?.diffuse.contents = UIColor(RGB: 0xffa080)

                let Day: EventAttributes =
                    {
                        let D = EventAttributes()
                        D.ForEvent = .SwitchToDay
                        D.Diffuse = UIColor(RGB: 0xffa080)
                        D.Specular = UIColor.white
                        D.Emission = nil
                        return D
                    }()
                Indicator.AddEventAttributes(Event: .SwitchToDay, Attributes: Day)
                let Night: EventAttributes =
                    {
                        let N = EventAttributes()
                        N.ForEvent = .SwitchToNight
                        N.Diffuse = UIColor(RGB: 0xffa080)
                        N.Specular = UIColor.white
                        N.Emission = UIColor(RGB: 0xffa080)
                        return N
                    }()
                Indicator.AddEventAttributes(Event: .SwitchToNight, Attributes: Night)
                Indicator.CanSwitchState = true
                if let IsInDay = Solar.IsInDaylight(Quake.Latitude, Quake.Longitude)
                {
                    Indicator.IsInDaylight = IsInDay
                }

                Indicator.geometry?.firstMaterial?.lightingModel = .lambert
                Indicator.categoryBitMask = LightMasks3D.Sun.rawValue | LightMasks3D.Moon.rawValue
                Indicator.scale = SCNVector3(NodeScales3D.RadiatingRings.rawValue,
                                             NodeScales3D.RadiatingRings.rawValue,
                                             NodeScales3D.RadiatingRings.rawValue)
                
                let ScaleDuration = 1.0 + (1.0 - (Quake.GreatestMagnitude / 10.0))
                let ToScale = Double(NodeScales3D.RadiatingRingBase.rawValue) + (0.3 * (1.0 - (Quake.GreatestMagnitude / 10.0)))
                let ScaleUp = SCNAction.scale(to: CGFloat(ToScale), duration: ScaleDuration)
                let FinalFade = SCNAction.fadeOut(duration: 0.1)
                let Wait2 = SCNAction.wait(duration: ScaleDuration - 0.1)
                let FadeSequence2 = SCNAction.sequence([Wait2, FinalFade])
                let Group = SCNAction.group([ScaleUp, FadeSequence2])
                let ResetAction = SCNAction.run
                {
                    Node in
                    Node.scale = SCNVector3(NodeScales3D.RadiatingRings.rawValue,
                                            NodeScales3D.RadiatingRings.rawValue,
                                            NodeScales3D.RadiatingRings.rawValue)
                    Node.opacity = InitialAlpha
                }
                let Sequence = SCNAction.sequence([Group, ResetAction])
                let Forever = SCNAction.repeatForever(Sequence)
                Indicator.runAction(Forever)
                
                let YRotation = Quake.Latitude + 90.0
                let XRotation = Quake.Longitude + 180.0
                let ZRotation = 0.0
                Final.eulerAngles = SCNVector3(YRotation.Radians, XRotation.Radians, ZRotation.Radians)
                Final.position = SCNVector3(X, Y, Z)
                Final.addChildNode(Indicator)
                Final.name = GlobeNodeNames.EarthquakeNodes.rawValue
                
            case .TriangleRingIn, .TriangleRingOut:
                let Radius = Double(GlobeRadius.Primary.rawValue) + 0.3
                let (X, Y, Z) = Geometry.ToECEF(Quake.Latitude, Quake.Longitude, Radius: Radius)
                let InnerRadius: CGFloat = 0.8
                let OuterRadius: CGFloat = 1.6
                let TRing = SCNTriangleRing(Count: 13, Inner: InnerRadius, Outer: OuterRadius, Extrusion: 0.15,
                                            Mask: LightMasks3D.MetalSun.rawValue | LightMasks3D.MetalMoon.rawValue)
                TRing.PointsOut = IndicatorType == .TriangleRingOut ? true: false
                TRing.Color = Settings.GetColor(.EarthquakeColor, UIColor.red)
                TRing.TriangleRotationDuration = 10.0 - Quake.GreatestMagnitude + 2.0
                TRing.position = SCNVector3(0.0, -OuterRadius / 4.0, 0.0)
                TRing.scale = SCNVector3(NodeScales3D.TriangleRing.rawValue,
                                         NodeScales3D.TriangleRing.rawValue,
                                         NodeScales3D.TriangleRing.rawValue)
                
                let YRotation = Quake.Latitude
                let XRotation = Quake.Longitude - 180.0
                let ZRotation = 0.0
                Final.eulerAngles = SCNVector3(YRotation.Radians, XRotation.Radians, ZRotation.Radians)
                Final.position = SCNVector3(X, Y, Z)
                Final.addChildNode(TRing)
                
                #if false
                let Rotate = SCNAction.rotateBy(x: CGFloat(0.0.Radians),
                                                y: CGFloat(0.0.Radians),
                                                z: CGFloat(360.0.Radians),
                                                duration: 5.0)
                let Forever = SCNAction.repeatForever(Rotate)
                //let TB = TRing.boundingBox
                //print("TB.width=\(TB.max.x - TB.min.x), TB.height=\(TB.max.y - TB.min.y)")
                //print("Original pivot point: \(TRing.pivot)")
                //let XPivot: CGFloat = 0.5//1.0 / (TB.max.x - TB.min.x) * 0.25
                //let YPivot: CGFloat = 0.5//1.0 / (TB.max.y - TB.min.y) * 0.5
                //TRing.pivot = SCNMatrix4MakeTranslation(XPivot, YPivot, 0.0)
                //TRing.runAction(Forever)
                #endif
                
                Final.name = GlobeNodeNames.EarthquakeNodes.rawValue
                
            case .None:
                return SCNNode2()
        }
        
        if !IndicatorAgeMap.contains(where: {$0.key == Quake.Code})
        {
            IndicatorAgeMap[Quake.Code] = Final
        }
        return Final
    }
}
