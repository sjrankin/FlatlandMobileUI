//
//  GlobeView.swift
//  Flatland
//
//  Created by Stuart Rankin on 6/4/20. Adapted from Flatland View.
//  Copyright © 2020, 2021 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit
import SceneKit

#if false
/// Provide the main 3D view for Flatland.
class GlobeViewOld: SCNView, FlatlandEventProtocol, StencilPipelineProtocol
{
    public weak var MainDelegate: MainProtocol? = nil
    
    /// Initializer.
    /// - Parameter frame: The frame of the SCNView.
    override init(frame: CGRect)
    {
        print("GlobeView(\(frame))")
        super.init(frame: frame,
                   options: [SCNView.Option.preferredRenderingAPI.rawValue :
                                SCNRenderingAPI.metal])
        InitializeView()
    }
    
    /// Initializer.
    /// - Parameter frame: The frame of the SCNView.
    /// - Parameter ForWidget: Determines if the view will live in a SwiftUI widget or not.
    init(frame: CGRect, ForWidget: Bool)
    {
        super.init(frame: frame)
        SetWidgetMode(ForWidget)
        InitializeView()
    }
    
    /// Initializer.
    /// - Parameter coder: See Apple documentation.
    required init?(coder: NSCoder)
    {
        super.init(coder: coder)
        InitializeView()
    }
    
    /// Set the widget mode.
    /// - Note:
    ///   - Widget mode is intended for use in macOS 11+ widgets only.
    ///   - When widget mode is on, the following items are not shown:
    ///     - Earthquakes (indicators, magnitudes, new quakes, etc).
    ///     - Satellites
    ///     - Debug information
    ///     - Status bar
    ///     - The view cannot be manipulated by the user.
    /// - Parameter IsOn: If true, widget mode is enabled, which removed a great deal of functionality
    ///                   and imagery from the view.
    func SetWidgetMode(_ IsOn: Bool = false)
    {
        InWidgetMode = IsOn
    }
    
    /// Widget mode flag. Set to `true` set widget mode.
    @IBInspectable var InWidgetMode: Bool = false
    {
        didSet
        {
            if !InWidgetMode
            {
                ClearEarthquakes()
                ApplyAllStencils(Except: [.Earthquakes])
                self.allowsCameraControl = false
                self.showsStatistics = false
                //MainDelegate?.HideStatusBar()
                //MainDelegate?.HideDebugGrid()
                //RemoveMousePointer()
            }
            else
            {
                PlotEarthquakes()
                ApplyAllStencils(Caller: "InWidgetMode")
                self.allowsCameraControl = true
                #if DEBUG
                self.showsStatistics = true
                //MainDelegate?.ShowDebugGrid()
                #endif
                if Settings.GetBool(.ShowStatusBar)
                {
                    //MainDelegate?.ShowStatusBar()
                }
            }
        }
    }
    
    /// Handle new time from the world clock.
    /// - Parameter WorldDate: Contains the new date and time.
    func NewWorldClockTime(WorldDate: Date)
    {
    }
    
    /// Hide the globe view.
    public func Hide()
    {
        if EarthClock != nil
        {
            EarthClock?.invalidate()
            EarthClock = nil
        }
        self.isHidden = true
        StopClock()
    }
    
    /// Show the globe view.
    public func Show()
    {
        StartClock()
        SetAttractMode()
        self.isHidden = false
    }
    
    /// Remove all nodes with the specified name from the scene's root node.
    /// - Note: Nodes are removed only from the specified node - see `FromParent`.
    /// - Parameter Name: The name of the node to remove. *Must match exactly.*
    /// - Parameter FromParent: If nil, nodes are removed from the scene's root node. If not nil, the nodes
    ///                         are removed from `FromParent`.
    func RemoveNodeWithName(_ Name: String, FromParent: SCNNode? = nil)
    {
        if let Parent = FromParent
        {
            for Node in Parent.childNodes
            {
                Node.removeAllActions()
                Node.removeAllAnimations()
                Node.removeFromParentNode()
                Node.geometry = nil
            }
            return
        }
        if let Nodes = self.scene?.rootNode.childNodes
        {
            for Node in Nodes
            {
                if Node.name == Name
                {
                    Node.removeAllActions()
                    Node.removeAllAnimations()
                    Node.removeFromParentNode()
                    Node.geometry = nil
                }
            }
        }
    }
    
    /// Return the total number of nodes in the system node.
    /// - Returns: Nodes in the system node.
    func TotalNodeCount() -> Int
    {
        if let CountFrom = SystemNode
        {
            return CountNodes(In: CountFrom)
        }
        return 0
    }
    
    /// Returns the number of child nodes in the passed node.
    /// - Parameter In: The node whose count of children and descents will be returned.
    /// - Returns: Number of child and descent nodes of the passed node.
    func CountNodes(In: SCNNode) -> Int
    {
        var Count = In.childNodes.count
        for Node in In.childNodes
        {
            Count = Count + CountNodes(In: Node)
        }
        return Count
    }
    
    #if DEBUG
    /// Set debug options for the visual debugging of the 3D globe.
    /// - Note: See [SCNDebugOptions](https://docs.microsoft.com/en-us/dotnet/api/scenekit.scndebugoptions?view=xamarin-ios-sdk-12)
    /// - Parameter Options: Array of options to use. If empty, all debug options disabled. If `.AllOff` is present
    ///                      (regardless of the presence of any other option), all debug options disabled.
    func SetDebugOption(_ Options: [DebugOptions3D])
    {
        let DoDebug = Settings.GetBool(.Enable3DDebugging)
        let DebugMap = Settings.GetEnum(ForKey: .Debug3DMap, EnumType: Debug_MapTypes.self)
        if DoDebug && DebugMap == .Globe
        {
            if Options.count == 0 || Options.contains(.AllOff)
            {
                self.debugOptions = []
                return
            }
            var DOptions: UInt = 0
            for Option in Options
            {
                DOptions = DOptions + Option.rawValue
            }
            self.debugOptions = SCNDebugOptions(rawValue: DOptions)
        }
        else
        {
            RemoveAxis() 
            self.debugOptions = []
        }
    }
    #endif
    
    /// Sets the HDR flag of the camera depending on user settings.
    func SetHDR()
    {
        Camera.wantsHDR = Settings.GetBool(.UseHDRCamera)
    }
    
    func SetDisplayLanguage()
    {
        
    }
    
    /// Stop the rotational clock.
    func StopClock()
    {
        EarthClock?.invalidate()
        EarthClock = nil
    }
    
    /// Start the rotational clock.
    func StartClock()
    {
        EarthClock = Timer.scheduledTimer(withTimeInterval: Defaults.EarthClockTick.rawValue, repeats: true)
        {
            [weak self] _ in
            let Now = Date()
            let TZ = TimeZone(abbreviation: "UTC")
            var Cal = Calendar(identifier: .gregorian)
            Cal.timeZone = TZ!
            let Hour = Cal.component(.hour, from: Now)
            let Minute = Cal.component(.minute, from: Now)
            let Second = Cal.component(.second, from: Now)
            let ElapsedSeconds = Second + (Minute * 60) + (Hour * 60 * 60)
            let Percent = Double(ElapsedSeconds) / Double(Date.SecondsIn(.Day))
            
            if self?.PreviousPrettyPercent == nil
            {
                self?.PreviousPrettyPercent = 0.0
            }
            else
            {
                self?.PreviousPrettyPercent = self?.PrettyPercent
            }
            self?.PrettyPercent = Double(Int(Percent * 1000.0)) / 1000.0
            
            #if DEBUG
            if Settings.GetBool(.Debug_EnableClockControl)
            {
                if Settings.EnumIs(.Globe, .Debug_ClockDebugMap, EnumType: Debug_MapTypes.self)
                {
                    if Settings.GetBool(.Debug_ClockActionFreeze)
                    {
                        if let Previous = self?.PreviousPrettyPercent
                        {
                            self?.PrettyPercent = Previous
                        }
                        else
                        {
                            self?.PrettyPercent = 0.0
                        }
                    }
                    if Settings.GetBool(.Debug_ClockActionFreezeAtTime)
                    {
                        let FreezeTime = Settings.GetDate(.Debug_ClockActionFreezeTime, Date())
                        if FreezeTime.IsOnOrLater(Than: Date())
                        {
                            if let Previous = self?.PreviousPrettyPercent
                            {
                                self?.PrettyPercent = Previous
                            }
                            else
                            {
                                self?.PrettyPercent = 0.0
                            }
                        }
                    }
                    if Settings.GetBool(.Debug_ClockActionSetClockAngle)
                    {
                        let Angle = Settings.GetDouble(.Debug_ClockActionClockAngle)
                        self?.PrettyPercent = Angle / 360.0
                    }
                    if Settings.GetBool(.Debug_ClockUseTimeMultiplier)
                    {
                        
                    }
                }
            }
            #endif
            
            if !(self?.DecoupleClock)!
            {
                self?.UpdateEarth(With: (self?.PrettyPercent)!)
            }
        }
    }
    
    #if DEBUG
    /// Holds the current debug time.
    var DebugTime: Date = Date()
    /// Holds the current stop time.
    var StopTime: Date = Date()
    
    /// Set the debug time.
    /// - Parameter NewTime: The new time for the debug clock.
    func SetDebugTime(_ NewTime: Date)
    {
        DebugTime = NewTime
    }
    
    /// Set the stop time.
    /// - Parameter NewTime: The time when to stop updating the clock.
    func SetStopTime(_ NewTime: Date)
    {
        StopTime = NewTime
    }
    #endif
    
    /// Contains the base map of the 3D view.
    var GlobalBaseMap: UIImage? = nil
    
    var PreviousHourType: HourTypes = .None
    
    /// Change the transparency of the land and sea nodes to what is in user settings.
    func UpdateSurfaceTransparency()
    {
        let Alpha = 1.0 - Settings.GetDouble(.GlobeTransparencyLevel)
        EarthNode?.opacity = CGFloat(Alpha)
        SeaNode?.opacity = CGFloat(Alpha)
        HourNode?.opacity = CGFloat(Alpha)
        LineNode?.opacity = CGFloat(Alpha)
    }
    
    /// Set the camera lock.
    /// - Parameter IsLocked: The lock value for the camera.
    /// - Parameter ResetPosition: If true, the camera is reset before being locked.
    func SetCameraLock(_ IsLocked: Bool, ResetPosition: Bool = false)
    {
        if IsLocked
        {
            if ResetPosition
            {
                ResetCamera()
            }
        }
        self.allowsCameraControl = !IsLocked
    }
    
    //var Pop: NSPopover? = nil
    
    var PreviousNode: SCNNode2? = nil
    var PreviousNodeID: UUID? = nil
    
    // MARK: - GlobeProtocol functions
    
    func PlotSatellite(Satellite: Satellites, At: GeoPoint)
    {
        #if false
        let SatelliteAltitude = 10.5 * (At.Altitude / 6378.1)
        let (X, Y, Z) = ToECEF(At.Latitude, At.Longitude, Radius: SatelliteAltitude)
        #endif
    }
    
    func SetNodeEulerAngles(EditID: UUID, _ Angles: SCNVector3)
    {
        for Node in EarthNode!.childNodes
        {
            if let ActualNode = Node as? SCNNode2
            {
                if let ActualNodeEditID = ActualNode.EditID
                {
                    if ActualNodeEditID == EditID
                    {
                        ActualNode.eulerAngles = Angles
                    }
                }
            }
        }
    }
    
    func GetNodeEulerAngles(EditID: UUID) -> SCNVector3?
    {
        for Node in EarthNode!.childNodes
        {
            if let ActualNode = Node as? SCNNode2
            {
                if let ActualNodeEditID = ActualNode.EditID
                {
                    if ActualNodeEditID == EditID
                    {
                    return ActualNode.eulerAngles
                    }
                }
            }
        }
        return nil
    }
    
    func SetNodeLocation(EditID: UUID, _ Latitude: Double, _ Longitude: Double)
    {
        for Node in EarthNode!.childNodes
        {
            if let ActualNode = Node as? SCNNode2
            {
                if let ActualNodeEditID = ActualNode.EditID
                {
                    if ActualNodeEditID == EditID
                    {
                        ActualNode.Latitude = Latitude
                        ActualNode.Longitude = Longitude
                        let (X, Y, Z) = Geometry.ToECEF(Latitude, Longitude, Radius: Double(GlobeRadius.Primary.rawValue))
                        ActualNode.position = SCNVector3(X, Y, Z)
                    }
                }
            }
        }
    }
    
    func GetNodeLocation(EditID: UUID) -> (Latitude: Double, Longitude: Double)?
    {
        for Node in EarthNode!.childNodes
        {
            if let ActualNode = Node as? SCNNode2
            {
                if let ActualNodeEditID = ActualNode.EditID
                {
                    if ActualNodeEditID == EditID
                    {
                    if ActualNode.Latitude == nil && ActualNode.Longitude == nil
                    {
                        return nil
                    }
                    return (ActualNode.Latitude!, ActualNode.Longitude!)
                    }
                }
            }
        }
        return nil
    }
    
    /// Kill all available timers. Called when the program is shutting down.
    func KillTimers()
    {
        EarthClock?.invalidate()
        DarkClock?.invalidate()
    }
    
    // MARK: - Stencil pipeline protocol functions
    
    /// Used to prevent stenciled maps from fighting to be displayed. Helps to enforce serialization.
    var StageSynchronization: NSObject = NSObject()
    
    /// Handle a new stencil map stage available.
    /// - Parameter Image: If nil, take no action. If not nil, display on the map layer of the main shape.
    /// - Parameter Stage: Used mainly for debug purposes - if not nil, contains the stage the the stenciling
    ///                    pipeline just completed. If nil, the image is undefined and should not be used.
    /// - Parameter Time: Duration from the start of the execution of the pipeline to the finish of the stage
    ///                   just completed.
    func StageCompleted(_ Image: UIImage?, _ Stage: StencilStages?, _ Time: Double?)
    {
        objc_sync_enter(StageSynchronization)
        defer{objc_sync_exit(StageSynchronization)}

        if Stage == nil || Time == nil
        {
            return
        }
        if let StenciledImage = Image
        {
            OperationQueue.main.addOperation
            {
                self.EarthNode?.geometry?.firstMaterial?.diffuse.contents = StenciledImage
            }
        }
    }
    
    /// Called when the stenciling pipeline is completed.
    /// - Notes: `Final` is saved in `InitialStenciledMap` to cache it for when earthquakes need to redraw
    ///          the map asynchronously.
    /// - Parameter Time: The duration for the stenciling pipeline to execute with all passed stages.
    /// - Parameter Final: The final image created.
    func StencilPipelineCompleted(Time: Double, Final: UIImage?)
    {
        if self.InitialStenciledMap == nil
        {
            if let FinalImage = Final
            {
                self.InitialStenciledMap = FinalImage
            }
        }
    }
    
    /// Called at the start of the pipeline execution.
    /// - Parameter Time: The starting time of the execution.
    func StencilPipelineStarted(Time: Double)
    {
    }
    
    func StencilPipelineCompleted2(_ Context: StencilContext)
    {
        if self.InitialStenciledMap == nil
        {
            if let Final = Context.CompletedImage
            {
                self.InitialStenciledMap = Final
            }
        }
    }
    
    func StencilStageCompleted2(_ Context: StencilContext, _ Stage: StencilStages?)
    {
        objc_sync_enter(StageSynchronization)
        defer{objc_sync_exit(StageSynchronization)}
        if Stage == nil
        {
            return
        }
        if let Working = Context.WorkingImage
        {
            OperationQueue.main.addOperation
            {
                self.EarthNode?.geometry?.firstMaterial?.diffuse.contents = Working
            }
        }
    }
    
    // MARK: - Variables for extensions.
    
    /// List of hours in Japanese Kanji.
    let JapaneseHours = [0: "〇", 1: "一", 2: "二", 3: "三", 4: "四", 5: "五", 6: "六", 7: "七", 8: "八", 9: "九",
                         10: "十", 11: "十一", 12: "十二", 13: "十三", 14: "十四", 15: "十五", 16: "十六", 17: "十七",
                         18: "十八", 19: "十九", 20: "二十", 21: "二十一", 22: "二十二", 23: "二十三", 24: "二十四"]
    
    var NorthPoleFlag: SCNNode2? = nil
    var SouthPoleFlag: SCNNode2? = nil
    var NorthPolePole: SCNNode2? = nil
    var SouthPolePole: SCNNode2? = nil
    var HomeNode: SCNNode2? = nil
    var HomeNodeHalo: SCNNode2? = nil
    var PlottedCities = [SCNNode2?]()
    var WHSNodeList = [SCNNode2?]()
    var GridImage: UIImage? = nil
    var EarthquakeList = [Earthquake]()
    var CitiesToPlot = [City2]()
    
    let TextureMap: [EarthquakeTextures: String] =
        [
            .SolidColor: "",
            .CheckerBoardTransparent: "CheckerboardTextureTransparent",
            .Checkerboard: "CheckerboardTexture",
            .DiagonalLines: "DiagonalLineTexture",
            .Gradient1: "EarthquakeHighlight",
            .Gradient2: "EarthquakeHighlight2",
            .RedCheckerboard: "RedCheckerboardTextureTransparent",
            .TransparentDiagonalLines: "DiagonalLineTextureTransparent"
        ]
    
    let RecentMap: [EarthquakeRecents: Double] =
        [
            .Day05: 12.0 * 60.0 * 60.0,
            .Day1: 24.0 * 60.0 * 60.0,
            .Day2: 2.0 * 24.0 * 60.0 * 60.0,
            .Day3: 3.0 * 24.0 * 60.0 * 60.0,
            .Day7: 7.0 * 24.0 * 60.0 * 60.0,
            .Day10: 10.0 * 24.0 * 60.0 * 60.0,
        ]
    
    var IndicatorAgeMap = [String: SCNNode2]()
    
    var StencilLayers = [GlobeLayers: SCNNode]()
    var MakeLayerLock = NSObject()
    
    var ClassID = UUID()
    
    /// Dark clock timer.
    var DarkClock: Timer!

    let LongitudeIncrement = 0.19
    let LatitudeIncrement = 0.23
    public var CameraObserver: NSKeyValueObservation? = nil
    public var FLCameraObserver: NSKeyValueObservation? = nil
    var OldPointOfView: SCNVector3? = nil
    var Camera: SCNCamera = SCNCamera()
    
    var AmbientLightNode: SCNNode? = nil
    var MetalSunLight = SCNLight()
    var MetalMoonLight = SCNLight()
    var MetalSunNode = SCNNode()
    var MetalMoonNode = SCNNode()
    var SunLight = SCNLight()
    var CameraNode = SCNNode()
    var LightNode = SCNNode()
    var GridLight1 = SCNLight()
    var GridLightNode1 = SCNNode()
    var GridLight2 = SCNLight()
    var GridLightNode2 = SCNNode()
    var MoonNode: SCNNode? = nil
    
    // MARK: - User camera variables.
    
    var CameraPointOfView: SCNVector3? = nil
    var CameraOrientation: SCNQuaternion? = nil
    var CameraRotation: SCNVector4? = nil
    var FlatlandCamera: SCNCamera? = nil
    var FlatlandCameraNode: SCNNode? = nil
    //var FlatlandCameraLocation = SCNVector3(0.0, 0.0, Defaults.InitialZ.rawValue)
    
    var DebugXAxis: SCNNode2? = nil
    var DebugYAxis: SCNNode2? = nil
    var DebugZAxis: SCNNode2? = nil
    
    var InitialStenciledMap: UIImage? = nil
    
    // MARK: - World clock management.
    
    /// If true, the clock is decoupled from the Earth and no ration occurs.
    var DecoupleClock = false
    var ClockMultiplier: Double = 1.0
    var PreviousPrettyPercent: Double? = nil
    var PrettyPercent = 0.0
    var EarthClock: Timer? = nil
    var PreviousLongitudePercent: Double? = nil
    
    var PreviousHourFlatnessLevel: CGFloat? = nil
    var PreviousCityFlatnessLevel: CGFloat? = nil
    var PreviousCameraDistance: Int? = nil
    let FlatnessDistanceMap: [(FlatLevel: CGFloat, Min: Int, Max: Int)] =
        [
            (0.001, 0, 60),
            (0.005, 61, 80),
            (0.01, 81, 100),
            (0.05, 101, 109),
            (0.08, 110, 120),
            (0.1, 121, 150),
            (0.3, 151, 200),
            (0.5, 201, 500),
            (1.0, 501, 10000)
        ]
    
    var RotationAccumulator: CGFloat = 0.0
    /// Holds most nodes.
    var SystemNode: SCNNode2? = nil
    /// Holds nodes used to draw 3D lines.
    var LineNode: SCNNode? = nil
    /// Holds the main Earth node.
    var EarthNode: SCNNode2? = nil
    /// Holds the main sea node.
    var SeaNode: SCNNode2? = nil
    /// Holds all of the hour nodes.
    var HourNode: SCNNode2? = nil
    /// Holds all of the regions.
    var RegionNode: SCNNode2? = nil
    var RegionLayer: CAShapeLayer? = nil
    var PlottedEarthquakes = Set<String>()
    
    var WallClockTimer: Timer? = nil
    var WallStartAngle: Double = 0.0
    var WallScaleMultiplier: Double = 1.0
    var WallLetterColor: UIColor = UIColor.red
    var LastWallClockTime: String? = nil
    
    var PreviousMemory: Int64? = nil
    var CumulativeMemory: Int64 = 0
    
    // MARK: - Globe camera variables.
    var GlobeCameraNode: SCNNode? = nil
    var GlobeCamera: SCNCamera? = nil
    var AnchorNode: SCNNode2? = nil
    
    var AboutTextPlotted: Bool = false
}


#endif
