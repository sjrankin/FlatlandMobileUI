//
//  +Home.swift
//  Flatland
//
//  Created by Stuart Rankin on 10/16/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit
import SceneKit

extension GlobeView
{
    // MARK: - Plot home location functions.
    
    /// Plot the home location. Intended for use by external callers.
    func PlotHomeLocation()
    {
        PlotHomeLocation(On: EarthNode!, Radius: Double(GlobeRadius.Primary.rawValue))
    }
    
    /// Plot the home location. In order for a location to be plotted, it must be defined and the
    /// style setting needs to be set to non-`.Hide`.
    /// - Parameter On: The node to which the home location will be attached.
    /// - Parameter Radius: The radius of the attachment node.
    func PlotHomeLocation(On Surface: SCNNode2, Radius: Double)
    {
        HomeNode?.removeFromParentNode()
        HomeNode = nil
        HomeNodeHalo?.removeFromParentNode()
        HomeNodeHalo = nil
        
        if let LocalLongitude = Settings.GetDoubleNil(.UserHomeLongitude)
        {
            if let LocalLatitude = Settings.GetDoubleNil(.UserHomeLatitude)
            {
                let HomeColor = Settings.GetColor(.HomeColor, UIColor.systemTeal)
                NodeTables.AddHome(ID: NodeTables.HomeID, Name: "Home location",
                                   Location: GeoPoint(LocalLatitude, LocalLongitude))
                switch Settings.GetEnum(ForKey: .HomeShape, EnumType: HomeShapes.self, Default: .Hide)
                {
                    case .Hide:
                        NodeTables.RemoveUserHome()
                        break
                        
                    case .Arrow:
                        PlotArrow(Latitude: LocalLatitude, Longitude: LocalLongitude, Radius: Radius,
                                  ToSurface: Surface, IsCurrentLocation: true)
                        
                    case .Flag:
                        PlotHomeFlag(Latitude: LocalLatitude, Longitude: LocalLongitude, Radius: Radius,
                                     ToSurface: Surface, EmissiveColor: HomeColor)
                        
                    case .Pulsate:
                        PlotPulsatingHome(Latitude: LocalLatitude, Longitude: LocalLongitude, Radius: Radius,
                                          ToSurface: Surface, WithColor: HomeColor)
                        
                    case .Pin:
                        PlotPinHome(Latitude: LocalLatitude, Longitude: LocalLongitude, Radius: Radius,
                                    ToSurface: Surface)
                        
                    case .Star:
                        PlotStarHome(Latitude: LocalLatitude, Longitude: LocalLongitude, Radius: Radius,
                                     ToSurface: Surface)
                        
                    case .PedestalWithBase:
                        PlotPedestalWithBase(Latitude: LocalLatitude, Longitude: LocalLongitude, Radius: Radius,
                                             ToSurface: Surface)
                        
                    case .BouncingArrow:
                        PlotBouncingArrow(Latitude: LocalLatitude, Longitude: LocalLongitude, Radius: Radius,
                                          ToSurface: Surface)
                }
            }
        }
    }
    
    /// Draws a 3D "arrow" shape (a cone and a cylinder) pointing toward the center of the Earth.
    /// - Parameter Latitude: The latitude of the arrow.
    /// - Parameter Longitude: The longitude of the arrow.
    /// - Parameter Radius: The radius of the Earth. (The arrow is plotted above the radius by a
    ///                     constant to ensure the entire arrow is visible.)
    /// - Parameter ToSurface: The surface node where the arrow will be added.
    /// - Parameter IsCurrentLocation: Determines the shape and color of the arrow. If this value is
    ///                                `true`, a stem will be added to the arrow shape and the arrow
    ///                                head will be red with an animation transitioning to yellow and
    ///                                back. Otherwise, there will be no stem and the color is determined
    ///                                by the caller (see `WithColor').
    /// - Parameter WithColor: Ignored if `IsCurrentLocation` is true. Otherwise, this is the color of
    ///                        the arrow head shape.
    func PlotArrow(Latitude: Double, Longitude: Double, Radius: Double, ToSurface: SCNNode2,
                   IsCurrentLocation: Bool = false, WithColor: UIColor = UIColor.red)
    {
        let RadialOffset = IsCurrentLocation ? 0.25 : 0.1
        let (X, Y, Z) = Geometry.ToECEF(Latitude, Longitude, Radius: Radius + RadialOffset)
        var ConeTop: CGFloat = 0.0
        var ConeBottom: CGFloat = 0.0
        if IsCurrentLocation
        {
            ConeTop = 0.0
            ConeBottom = 0.15
        }
        else
        {
            ConeTop = 0.15
            ConeBottom = 0.0
        }
        let Cone = SCNCone(topRadius: ConeTop, bottomRadius: ConeBottom, height: 0.3)
        let ConeNode = SCNNode2(geometry: Cone)
        ConeNode.NodeID = NodeTables.HomeID
        ConeNode.NodeClass = UUID(uuidString: NodeClasses.HomeLocation.rawValue)!
        ConeNode.CanShowBoundingShape = false
        ConeNode.scale = SCNVector3(NodeScales3D.HomeArrowScale.rawValue,
                                    NodeScales3D.HomeArrowScale.rawValue,
                                    NodeScales3D.HomeArrowScale.rawValue)
        ConeNode.categoryBitMask = LightMasks3D.Sun.rawValue | LightMasks3D.Moon.rawValue
        ConeNode.geometry?.firstMaterial?.diffuse.contents = WithColor
        ConeNode.geometry?.firstMaterial?.specular.contents = UIColor.white
        if !IsCurrentLocation
        {
            #if true
            ConeNode.geometry?.firstMaterial?.selfIllumination.contents = WithColor
            #else
            ConeNode.geometry?.firstMaterial?.emission.contents = WithColor
            #endif
        }
        ConeNode.castsShadow = true
        
        if IsCurrentLocation
        {
            let ChangeDuration: Double = 30.0
            var HueValue = 0.0
            var HueIncrement = 0.01
            let ColorAction = SCNAction.customAction(duration: ChangeDuration)
            {
                (Node, ElapsedTime) in
                HueValue = HueValue + HueIncrement
                if HueValue > Double(63.0 / 360.0)
                {
                    HueIncrement = HueIncrement * -1.0
                    HueValue = HueValue + HueIncrement
                }
                else
                {
                    if HueValue < 0.0
                    {
                        HueIncrement = HueIncrement * -1.0
                        HueValue = 0.0
                    }
                }
                Node.geometry?.firstMaterial?.diffuse.contents = UIColor(hue: CGFloat(HueValue), saturation: 1.0, brightness: 1.0, alpha: 1.0)
            }
            let ColorForever = SCNAction.repeatForever(ColorAction)
            ConeNode.runAction(ColorForever)
        }
        
        HomeNode = SCNNode2()
        HomeNode?.SetLocation(Latitude, Longitude)
        HomeNode?.name = GlobeNodeNames.HomeNode.rawValue
        HomeNode?.addChildNode(ConeNode)
        HomeNode?.CanShowBoundingShape = true
        HomeNode?.CanSwitchState = true
        let Day: EventAttributes =
            {
                let D = EventAttributes()
                D.ForEvent = .SwitchToDay
                D.Diffuse = WithColor
                D.Specular = UIColor.white
                D.Emission = nil
                return D
            }()
        HomeNode?.AddEventAttributes(Event: .SwitchToDay, Attributes: Day)
        let Night: EventAttributes =
            {
                let N = EventAttributes()
                N.ForEvent = .SwitchToNight
                N.Diffuse = WithColor
                N.Specular = UIColor.white
                N.Emission = WithColor
                return N
            }()
        HomeNode?.AddEventAttributes(Event: .SwitchToNight, Attributes: Night)
        
        if IsCurrentLocation
        {
            let Cylinder = SCNCylinder(radius: 0.04, height: 0.5)
            let CylinderNode = SCNNode2(geometry: Cylinder)
            CylinderNode.NodeID = NodeTables.HomeID
            CylinderNode.NodeClass = UUID(uuidString: NodeClasses.HomeLocation.rawValue)!
            CylinderNode.CanShowBoundingShape = true
            CylinderNode.scale = SCNVector3(NodeScales3D.HomeArrowScale.rawValue,
                                            NodeScales3D.HomeArrowScale.rawValue,
                                            NodeScales3D.HomeArrowScale.rawValue)
            CylinderNode.categoryBitMask = LightMasks3D.Sun.rawValue | LightMasks3D.Moon.rawValue
            CylinderNode.geometry?.firstMaterial?.diffuse.contents = UIColor(red: 1.0, green: 0.6, blue: 0.6, alpha: 1.0)
            CylinderNode.geometry?.firstMaterial?.specular.contents = UIColor.white
            CylinderNode.castsShadow = true
            CylinderNode.position = SCNVector3(0.0, -0.4, 0.0)
            HomeNode?.addChildNode(CylinderNode)
        }
        
        HomeNode?.position = SCNVector3(X, Y, Z)
        
        let YRotation = Latitude + 90.0
        let XRotation = Longitude + 180.0
        HomeNode?.eulerAngles = SCNVector3(YRotation.Radians, XRotation.Radians, 0.0)
        
        HomeNode?.NodeID = NodeTables.HomeID
        HomeNode?.NodeClass = UUID(uuidString: NodeClasses.HomeLocation.rawValue)!
        
        ToSurface.addChildNode(HomeNode!)
    }
    
    /// Plot the home location as a pulsating sphere.
    /// - Parameter Latitude: The latitude of the arrow.
    /// - Parameter Longitude: The longitude of the arrow.
    /// - Parameter Radius: The radius of the Earth. (The arrow is plotted above the radius by a
    ///                     constant to ensure the entire arrow is visible.)
    /// - Parameter ToSurface: The surface node where the arrow will be added.
    /// - Parameter WithColor: The color of the sphere.
    func PlotPulsatingHome(Latitude: Double, Longitude: Double, Radius: Double, ToSurface: SCNNode2,
                           WithColor: UIColor = UIColor.magenta)
    {
        let (X, Y, Z) = Geometry.ToECEF(Latitude, Longitude, Radius: Radius + 0.1)
        
        let Sphere = SCNSphere(radius: 0.4)
        
        HomeNode = SCNNode2(geometry: Sphere)
        HomeNode?.name = GlobeNodeNames.HomeNode.rawValue
        HomeNode?.NodeID = NodeTables.HomeID
        HomeNode?.NodeClass = UUID(uuidString: NodeClasses.Miscellaneous.rawValue)!
        HomeNode?.categoryBitMask = LightMasks3D.Sun.rawValue | LightMasks3D.Moon.rawValue
        HomeNode?.geometry?.firstMaterial?.diffuse.contents = WithColor
        HomeNode?.geometry?.firstMaterial?.selfIllumination.contents = WithColor
        HomeNode?.geometry?.firstMaterial?.specular.contents = UIColor.white
        HomeNode?.castsShadow = true
        HomeNode?.position = SCNVector3(X, Y, Z)
        
        HomeNode?.CanSwitchState = true
        let Day: EventAttributes =
            {
                let D = EventAttributes()
                D.ForEvent = .SwitchToDay
                D.Diffuse = WithColor
                D.Specular = UIColor.white
                D.Emission = nil
                return D
            }()
        HomeNode?.AddEventAttributes(Event: .SwitchToDay, Attributes: Day)
        let Night: EventAttributes =
            {
                let N = EventAttributes()
                N.ForEvent = .SwitchToNight
                N.Diffuse = WithColor
                N.Specular = UIColor.white
                N.Emission = WithColor
                return N
            }()
        HomeNode?.AddEventAttributes(Event: .SwitchToNight, Attributes: Night)
        
        let PulseOut = SCNAction.scale(to: NodeScales3D.PulsatingHomeMaxScale.rawValue, duration: 1.0)
        let PulseIn = SCNAction.scale(to: NodeScales3D.PulsatingHomeMinScale.rawValue, duration: 1.0)
        let PulseSequence = SCNAction.sequence([PulseOut, PulseIn])
        let Forever = SCNAction.repeatForever(PulseSequence)
        HomeNode?.runAction(Forever)
        
        ToSurface.addChildNode(HomeNode!)
        
        let SphereHalo = SCNSphere(radius: 0.40)
        HomeNodeHalo = SCNNode2(geometry: SphereHalo)
        HomeNodeHalo?.NodeID = NodeTables.HomeID
        HomeNodeHalo?.NodeClass = UUID(uuidString: NodeClasses.Miscellaneous.rawValue)!
        HomeNodeHalo?.categoryBitMask = LightMasks3D.Sun.rawValue | LightMasks3D.Moon.rawValue
        HomeNodeHalo?.geometry?.firstMaterial?.diffuse.contents = UIColor.white.withAlphaComponent(0.2)
        #if true
        HomeNodeHalo?.geometry?.firstMaterial?.selfIllumination.contents = UIColor.yellow.withAlphaComponent(0.2)
        #else
        HomeNodeHalo?.geometry?.firstMaterial?.emission.contents = UIColor.yellow.withAlphaComponent(0.2)
        #endif
        HomeNodeHalo?.position = SCNVector3(X, Y, Z)
        HomeNodeHalo?.castsShadow = false
        
        ToSurface.addChildNode(HomeNodeHalo!)
    }
    
    /// Plot a location using a bouncing, rotating arrow.
    /// - Parameter Latitude: The latitude of the arrow.
    /// - Parameter Longitude: The longitude of the arrow.
    /// - Parameter Radius: The radius of the Earth.
    /// - Parameter ToSurface: The surface node where the arrow will be added.
    func PlotBouncingArrow(Latitude: Double, Longitude: Double, Radius: Double, ToSurface: SCNNode2)
    {
        let (X, Y, Z) = Geometry.ToECEF(Latitude, Longitude, Radius: Radius + 0.3)
        let Arrow = SCN3DArrow(Length: 2.0, Width: 0.85, Color: UIColor.systemTeal,
                               StemColor: UIColor.systemBlue)
        Arrow.LightMask = LightMasks3D.Sun.rawValue | LightMasks3D.Moon.rawValue
        Arrow.scale = SCNVector3(NodeScales3D.BouncingArrowScale.rawValue,
                                 NodeScales3D.BouncingArrowScale.rawValue,
                                 NodeScales3D.BouncingArrowScale.rawValue)
        
        let BounceDistance: CGFloat = 0.5
        let BounceDuration = 1.0
        let BounceAway = SCNAction.move(by: SCNVector3(0.0, -BounceDistance, 0.0), duration: BounceDuration)
        BounceAway.timingMode = .easeOut
        let BounceTo = SCNAction.move(by: SCNVector3(0.0, BounceDistance, 0.0), duration: BounceDuration)
        BounceTo.timingMode = .easeIn
        let BounceSequence = SCNAction.sequence([BounceAway, BounceTo])
        let MoveForever = SCNAction.repeatForever(BounceSequence)
        Arrow.runAction(MoveForever)
        
        HomeNode = SCNNode2()
        HomeNode?.name = GlobeNodeNames.HomeNode.rawValue
        HomeNode?.castsShadow = true
        HomeNode?.addChildNode(Arrow)
        HomeNode?.position = SCNVector3(X, Y, Z)
        HomeNode?.categoryBitMask = LightMasks3D.Sun.rawValue | LightMasks3D.Moon.rawValue
        
        HomeNode?.CanSwitchState = true
        let Day: EventAttributes =
            {
                let D = EventAttributes()
                D.ForEvent = .SwitchToDay
                D.Diffuse = UIColor.orange
                D.Specular = UIColor.white
                D.Emission = nil
                return D
            }()
        HomeNode?.AddEventAttributes(Event: .SwitchToDay, Attributes: Day)
        let Night: EventAttributes =
            {
                let N = EventAttributes()
                N.ForEvent = .SwitchToNight
                N.Diffuse = UIColor.orange
                N.Specular = UIColor.white
                N.Emission = UIColor.orange
                return N
            }()
        HomeNode?.AddEventAttributes(Event: .SwitchToNight, Attributes: Night)
        
        let YRotation = Latitude + 90.0
        let XRotation = Longitude + 180.0
        HomeNode!.eulerAngles = SCNVector3(YRotation.Radians, XRotation.Radians, 0.0)
        
        ToSurface.addChildNode(HomeNode!)
    }
    
    /// Plot a location using a star shape.
    /// - Parameter Latitude: The latitude of the arrow.
    /// - Parameter Longitude: The longitude of the arrow.
    /// - Parameter Radius: The radius of the Earth.
    /// - Parameter ToSurface: The surface node where the arrow will be added.
    func PlotStarHome(Latitude: Double, Longitude: Double, Radius: Double, ToSurface: SCNNode2)
    {
        let (X, Y, Z) = Geometry.ToECEF(Latitude, Longitude, Radius: Radius)
        let OuterStar: ShapeAttributes =
            {
               let A = ShapeAttributes()
                A.AttributesChange = true
                let Size: Sizes =
                    {
                        let S = Sizes()
                        S.VertexCount = Int(FlatConstants.HomeStarVertexCount.rawValue)
                        S.Height = FlatConstants.HomeStarHeight.rawValue
                        S.Base = FlatConstants.HomeStarBase.rawValue
                        S.ZHeight = FlatConstants.HomeStarZ.rawValue
                        return S
                    }()
                A.ShapeSize = Size
                A.Class = UUID(uuidString: NodeClasses.HomeLocation.rawValue)!
                A.ID = NodeTables.HomeID
                A.ShowBoundingShapes = true
                A.Latitude = Latitude
                A.Longitude = Longitude
                A.Position = SCNVector3(0.0, 0.0, 0.0)
                A.LightMask = LightMasks3D.Sun.rawValue | LightMasks3D.Moon.rawValue
                A.CastsShadow = true
                let Day: TimeState =
                    {
                       let D = TimeState()
                        D.Color = UIColor.systemYellow
                        return D
                    }()
                A.DayState = Day
                let Night: TimeState =
                    {
                        let N = TimeState()
                        N.Color = UIColor.systemYellow
                            N.Emission = UIColor.systemYellow
                        return N
                    }()
                A.NightState = Night
                return A
            }()
        let InnerStar: ShapeAttributes =
            {
                let A = ShapeAttributes()
                A.AttributesChange = true
                let Size: Sizes =
                    {
                        let S = Sizes()
                        S.VertexCount = Int(FlatConstants.HomeStarVertexCount.rawValue)
                        S.Height = FlatConstants.SmallStarHeight.rawValue
                        S.Base = FlatConstants.SmallStarBase.rawValue
                        S.ZHeight = FlatConstants.SmallStarZ.rawValue
                        return S
                    }()
                A.ShapeSize = Size
                A.Class = UUID(uuidString: NodeClasses.HomeLocation.rawValue)!
                A.ID = NodeTables.HomeID
                A.ShowBoundingShapes = true
                A.Latitude = Latitude
                A.Longitude = Longitude
                A.Position = SCNVector3(0.0, 0.0, 0.0)
                A.LightMask = LightMasks3D.Sun.rawValue | LightMasks3D.Moon.rawValue
                A.CastsShadow = true
                let Day: TimeState =
                    {
                        let D = TimeState()
                        D.Color = UIColor.white
                        return D
                    }()
                A.DayState = Day
                let Night: TimeState =
                    {
                        let N = TimeState()
                        N.Color = UIColor.white
                        N.Emission = UIColor.white
                        return N
                    }()
                A.NightState = Night
                return A
            }()
        let Base: ShapeAttributes =
            {
               let A = ShapeAttributes()
                A.AttributesChange = true
                A.CastsShadow = true
                A.Class = UUID(uuidString: NodeClasses.HomeLocation.rawValue)!
                A.ID = NodeTables.HomeID
                A.ShowBoundingShapes = true
                A.Latitude = Latitude
                A.Longitude = Longitude
                A.Position = SCNVector3(X, Y, Z)
                A.EulerX = Latitude.Radians
                A.EulerY = (Longitude + 180.0).Radians
                A.EulerZ = 0.0
                return A
            }()
        let Composite = CompositeComponents()
        Composite.Attributes[.Star] = OuterStar
        Composite.Attributes[.InnerStar] = InnerStar
        let Star = ShapeManager.Create(.EmbeddedStar, Composite: Composite, BaseAttributes: Base)
        self.HomeNode = Star
        self.HomeNode?.name = GlobeNodeNames.HomeNode.rawValue
        ToSurface.addChildNode(Star)
    }
    
    /// Create a ball on a pedestal shape to indicate home location.
    /// - Parameter Latitude: The latitude of the arrow.
    /// - Parameter Longitude: The longitude of the arrow.
    /// - Parameter Radius: The radius of the Earth.
    /// - Parameter ToSurface: The surface node where the arrow will be added.
    func PlotPedestalWithBase(Latitude: Double, Longitude: Double, Radius: Double, ToSurface: SCNNode2)
    {
        let (X, Y, Z) = Geometry.ToECEF(Latitude, Longitude, Radius: Radius)
        
        let HomeNode = SCNNode2()
        HomeNode.name = GlobeNodeNames.HomeNode.rawValue
        HomeNode.castsShadow = true
        HomeNode.NodeClass = UUID(uuidString: NodeClasses.HomeLocation.rawValue)!
        HomeNode.NodeID = NodeTables.HomeID
        HomeNode.position = SCNVector3(X, Y, Z)
        
        let Base = SCNNode2(geometry: SCNStar.Geometry(VertexCount: 7,
                                                       Height: FlatConstants.HomeStarHeight.rawValue,
                                                       Base: FlatConstants.HomeStarBase.rawValue,
                                                       ZHeight: FlatConstants.HomeStarZ.rawValue))
        Base.castsShadow = true
        Base.name = NodeNames2D.HomeNode.rawValue
        Base.geometry?.firstMaterial?.diffuse.contents = UIColor(HexString: "#d0d0d0")
        Base.categoryBitMask = LightMasks3D.Sun.rawValue | LightMasks3D.Moon.rawValue
        Base.geometry?.firstMaterial?.lightingModel = .physicallyBased
        Base.geometry?.firstMaterial?.metalness.contents = 1.0
        Base.geometry?.firstMaterial?.roughness.contents = 0.5
        Base.eulerAngles = SCNVector3(CGFloat(90.0.Radians), 0.0, 0.0)
        Base.position = SCNVector3(0.0, 0.0, 0.0)
        let BaseRotate = SCNAction.rotateBy(x: 0.0, y: 1.0, z: 0.0, duration: 1.0)
        let BaseRotateForever = SCNAction.repeatForever(BaseRotate)
        Base.runAction(BaseRotateForever)
        Base.CanSwitchState = true
        let Day: EventAttributes =
            {
                let D = EventAttributes()
                D.ForEvent = .SwitchToDay
                D.Diffuse = UIColor(HexString: "#d0d0d0")
                D.Specular = UIColor.white
                D.Metalness = 1.0
                D.Roughness = 0.5
                D.LightModel = .physicallyBased
                D.Emission = nil
                return D
            }()
        Base.AddEventAttributes(Event: .SwitchToDay, Attributes: Day)
        let Night: EventAttributes =
            {
                let N = EventAttributes()
                N.ForEvent = .SwitchToNight
                N.Diffuse = UIColor(HexString: "#d0d0d0")
                N.Specular = UIColor.white
                N.Emission = UIColor(HexString: "#d0d0d0")
                N.Metalness = 0.0
                N.Roughness = 0.0
                N.LightModel = .phong
                return N
            }()
        Base.AddEventAttributes(Event: .SwitchToNight, Attributes: Night)
        Base.SetLocation(Latitude, Longitude)
        
        let Pedestal = SCNNode2(geometry: SCNCylinder(radius: 0.07, height: 0.6))
        Pedestal.castsShadow = true
        Pedestal.geometry?.firstMaterial?.diffuse.contents = UIColor.systemGreen
        Pedestal.geometry?.firstMaterial?.specular.contents = UIColor.white
        Pedestal.categoryBitMask = LightMasks3D.Sun.rawValue | LightMasks3D.Moon.rawValue
        Pedestal.geometry?.firstMaterial?.lightingModel = .physicallyBased
        Pedestal.geometry?.firstMaterial?.metalness.contents = 1.0
        Pedestal.geometry?.firstMaterial?.roughness.contents = 0.5
        Pedestal.position = SCNVector3(0.0, -0.2, 0.0)
        
        let Sphere = SCNNode2(geometry: SCNSphere(radius: 0.15))
        Sphere.castsShadow = true
        Sphere.geometry?.firstMaterial?.diffuse.contents = UIColor(HexString: "#ffd700")
        Sphere.categoryBitMask = LightMasks3D.Sun.rawValue | LightMasks3D.Moon.rawValue
        Sphere.geometry?.firstMaterial?.lightingModel = .physicallyBased
        Sphere.geometry?.firstMaterial?.metalness.contents = 1.0
        Sphere.geometry?.firstMaterial?.roughness.contents = 0.5
        Sphere.position = SCNVector3(0.0, -0.4, 0.0)
        Sphere.CanSwitchState = true
        /*
        Sphere.SetState(ForDay: true, Color: UIColor(HexString: "#ffd700")!, Emission: nil,
                        Model: .physicallyBased, Metalness: nil, Roughness: nil)
        Sphere.SetState(ForDay: false, Color: UIColor(HexString: "#ffd700")!, Emission: UIColor(HexString: "#ffd700")!,
                        Model: .physicallyBased, Metalness: nil, Roughness: nil)
 */
        let SphereDay: EventAttributes =
            {
                let D = EventAttributes()
                D.ForEvent = .SwitchToDay
                D.Diffuse = UIColor(HexString: "#ffd700")
                D.Specular = UIColor.white
                D.Emission = nil
                D.LightModel = .phong
                D.Metalness = 0.0
                D.Roughness = 0.0
                return D
            }()
        Sphere.AddEventAttributes(Event: .SwitchToDay, Attributes: SphereDay)
        let SphereNight: EventAttributes =
            {
                let N = EventAttributes()
                N.ForEvent = .SwitchToNight
                N.Diffuse = UIColor(HexString: "#ffd700")
                N.Specular = UIColor.white
                N.Emission = UIColor(HexString: "#ffd700")
                N.Metalness = 1.0
                N.Roughness = 0.5
                N.LightModel = .physicallyBased
                return N
            }()
        Sphere.AddEventAttributes(Event: .SwitchToNight, Attributes: SphereNight)
        Sphere.SetLocation(Latitude, Longitude)

        HomeNode.CanSwitchState = true
        HomeNode.SetLocation(Latitude, Longitude)
        HomeNode.IsInDaylight = Solar.IsInDaylight(Latitude, Longitude)!
        HomeNode.addChildNode(Sphere)
        HomeNode.addChildNode(Base)
        HomeNode.addChildNode(Pedestal)
        HomeNode.eulerAngles = SCNVector3(CGFloat(Latitude + 90.0).Radians, CGFloat(Longitude + 180.0).Radians, 0.0)
        self.HomeNode = HomeNode
        ToSurface.addChildNode(HomeNode)
    }
    
    /// Plot a location using a 3D pin shape.
    /// - Parameter Latitude: The latitude of the pin.
    /// - Parameter Longitude: The longitude of the pin.
    /// - Parameter Radius: The radius of the Earth.
    /// - Parameter ToSurface: The surface node where the pin will be added.
    func PlotPinHome(Latitude: Double, Longitude: Double, Radius: Double, ToSurface: SCNNode2)
    {
        let (X, Y, Z) = Geometry.ToECEF(Latitude, Longitude, Radius: Radius + 0.9)
        let Pin = SCNPin(KnobHeight: 2.0, KnobRadius: 1.0, PinHeight: 1.4, PinRadius: 0.15,
                         KnobColor: UIColor.Gold, PinColor: UIColor.gray)
        Pin.scale = SCNVector3(NodeScales3D.PinScale.rawValue,
                               NodeScales3D.PinScale.rawValue,
                               NodeScales3D.PinScale.rawValue)
        Pin.LightMask = LightMasks3D.Sun.rawValue | LightMasks3D.Moon.rawValue
        
        HomeNode = SCNNode2()
        HomeNode?.name = GlobeNodeNames.HomeNode.rawValue
        HomeNode?.NodeClass = UUID(uuidString: NodeClasses.HomeLocation.rawValue)!
        HomeNode?.NodeID = NodeTables.HomeID
        HomeNode?.castsShadow = true
        HomeNode?.addChildNode(Pin)
        HomeNode?.position = SCNVector3(X, Y, Z)
        
        let YRotation = Latitude + 90.0
        let XRotation = Longitude + 180.0
        HomeNode!.eulerAngles = SCNVector3(YRotation.Radians, XRotation.Radians, 0.0)
        
        ToSurface.addChildNode(HomeNode!)
    }
    
    /// Plot a location using a home flag.
    /// - Note: The "background" to the home icon has an emissive color so it will glow even
    ///         at night time to show the location.
    /// - Parameter Latitude: The latitude of the arrow.
    /// - Parameter Longitude: The longitude of the arrow.
    /// - Parameter Radius: The radius of the Earth. (The arrow is plotted above the radius by a
    ///                     constant to ensure the entire arrow is visible.)
    /// - Parameter ToSurface: The surface node where the arrow will be added.
    /// - Parameter EmissiveColor: The color the home icon will glow.
    func PlotHomeFlag(Latitude: Double, Longitude: Double, Radius: Double, ToSurface: SCNNode2,
                      EmissiveColor: UIColor = UIColor.white)
    {
        let Pole = SCNCylinder(radius: 0.04, height: 4.5)
        let PoleNode = SCNNode2(geometry: Pole)
        PoleNode.categoryBitMask = LightMasks3D.Sun.rawValue | LightMasks3D.Moon.rawValue
        PoleNode.geometry?.firstMaterial?.diffuse.contents = UIColor.brown
        
        let FlagX = 0.6
        let FlagY = -2.0
        
        let FlagInterior = SCNBox(width: 0.035, height: 0.5, length: 1.1, chamferRadius: 0.0)
        let FlagInteriorNode = SCNNode2(geometry: FlagInterior)
        FlagInteriorNode.categoryBitMask = LightMasks3D.Sun.rawValue | LightMasks3D.Moon.rawValue
        FlagInteriorNode.geometry?.firstMaterial?.diffuse.contents = EmissiveColor
        FlagInteriorNode.geometry?.firstMaterial?.specular.contents = UIColor.white
        #if false
        FlagInteriorNode.geometry?.firstMaterial?.selfIllumination.contents = EmissiveColor
        #else
        FlagInteriorNode.geometry?.firstMaterial?.emission.contents = EmissiveColor
        #endif
        FlagInteriorNode.position = SCNVector3(FlagX, FlagY, 0.0)
        FlagInteriorNode.eulerAngles = SCNVector3(0.0, 90.0.Radians, 0.0)
        
        let FlagFace = SCNBox(width: 0.04, height: 0.6, length: 1.2, chamferRadius: 0.0)
        let FlagFaceNode = SCNNode2(geometry: FlagFace)
        FlagFaceNode.categoryBitMask = LightMasks3D.Sun.rawValue | LightMasks3D.Moon.rawValue
        FlagFaceNode.position = SCNVector3(FlagX, FlagY, 0.0)
        let FlagName = "GreenHomeFlag"
        let FlagImage = UIImage(named: FlagName)
        FlagFaceNode.geometry?.firstMaterial?.diffuse.contents = FlagImage
        FlagFaceNode.geometry?.firstMaterial?.specular.contents = UIColor.white
        FlagFaceNode.geometry?.firstMaterial?.lightingModel = .lambert
        FlagFaceNode.eulerAngles = SCNVector3(180.0.Radians, 90.0.Radians, 0.0)
        
        HomeNode = SCNNode2()
        HomeNode?.name = GlobeNodeNames.HomeNode.rawValue
        HomeNode?.castsShadow = true
        HomeNode?.addChildNode(PoleNode)
        HomeNode?.addChildNode(FlagFaceNode)
        HomeNode?.addChildNode(FlagInteriorNode)
        
        let (X, Y, Z) = Geometry.ToECEF(Latitude, Longitude, Radius: Radius)
        HomeNode?.position = SCNVector3(X, Y, Z)
        
        let YRotation = Latitude + 90.0
        let XRotation = Longitude + 180.0
        HomeNode?.eulerAngles = SCNVector3(YRotation.Radians, XRotation.Radians, 0.0)
        HomeNode?.name = GlobeNodeNames.HomeNode.rawValue
        HomeNode?.NodeID = NodeTables.HomeID
        HomeNode?.NodeClass = UUID(uuidString: NodeClasses.HomeLocation.rawValue)
        ToSurface.addChildNode(HomeNode!)
    }
}
