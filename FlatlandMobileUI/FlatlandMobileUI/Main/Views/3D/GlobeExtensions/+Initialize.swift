//
//  +Initialize.swift
//  Flatland
//
//  Created by Stuart Rankin on 9/21/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//
import Foundation
import UIKit
import SceneKit

extension GlobeView
{
    /// Initialize the globe view.
    /// - Note: See: [Get camera position.](https://stackoverflow.com/questions/24768031/can-i-get-the-scnview-camera-position-when-using-allowscameracontrol)
    func InitializeView()
    {
        Settings.AddSubscriber(self)
        PreviousHourType = Settings.GetEnum(ForKey: .HourType, EnumType: HourTypes.self, Default: .None)
        #if DEBUG
        var DebugTypes = [DebugOptions3D]()
        Settings.QueryBool(.ShowSkeletons)
        {
            Show in
            if Show
            {
                DebugTypes.append(.Skeleton)
            }
        }
        Settings.QueryBool(.ShowBoundingBoxes)
        {
            Show in
            if Show
            {
                DebugTypes.append(.BoundingBoxes)
            }
        }
        Settings.QueryBool(.ShowWireframes)
        {
            Show in
            if Show
            {
                DebugTypes.append(.WireFrame)
            }
        }
        Settings.QueryBool(.ShowLightInfluences)
        {
            Show in
            if Show
            {
                DebugTypes.append(.LightInfluences)
            }
        }
        Settings.QueryBool(.ShowLightExtents)
        {
            Show in
            if Show
            {
                DebugTypes.append(.LightExtents)
            }
        }
        Settings.QueryBool(.ShowConstraints)
        {
            Show in
            if Show
            {
                DebugTypes.append(.Constraints)
            }
        }
        SetDebugOption(DebugTypes)
        #endif
        
        self.allowsCameraControl = true

        #if false
        /// Watch the camera to ensure we always have the camera's orientation.
        CameraObserver = self.observe(\.pointOfView?.position, options: [.new, .initial])
        {
            (Node, Change) in
            OperationQueue.current?.addOperation
            {
                let Location = Node.pointOfView!.position
                self.CameraPointOfView = Location
                self.CameraOrientation = Node.pointOfView!.orientation
                self.CameraRotation = Node.pointOfView!.rotation
            }
        }
        #endif
        
        //Monitor the camera's distance from the center of the Earth. Used to set the quality level of extruded
        //hour numerals.
        //See: https://stackoverflow.com/questions/24768031/can-i-get-the-scnview-camera-position-when-using-allowscameracontrol
        //Features.FeatureIsNotEnabled(.NonStockCamera)
        if true
        {
            if self.allowsCameraControl
            {
                self.CameraObserver = self.self.observe(\.pointOfView?.position, options: [.new, .initial])
                {
                    [weak self] (Node, Change) in
                    OperationQueue.current?.addOperation
                    {
                        if let Location = Node.pointOfView?.position
                        {
                            if Location.x == .nan || Location.y == .nan || Location.z == .nan
                            {
                                return
                            }
                            let Distance = sqrt((Location.x * Location.x) + (Location.y * Location.y) + (Location.z * Location.z))
                            if self?.PreviousCameraDistance == nil
                            {
                                self?.PreviousCameraDistance = Int(Distance)
                            }
                            else
                            {
        
                                if self?.PreviousCameraDistance != Int(Distance)
                                {
                                    self?.PreviousCameraDistance = Int(Distance)
                                    self?.HandleCameraLocationChanged(NewDistance: CGFloat(Distance))
                                }
                            }
                        }
                    }
                }
            }
        }
        
        self.autoenablesDefaultLighting = false
        self.scene = SCNScene()
        self.backgroundColor = UIColor.black//UIColor.clear
        switch Settings.GetEnum(ForKey: .AntialiasLevel, EnumType: SceneJitters.self, Default: .Jitter4X)
        {
            case .None:
                self.antialiasingMode = .none
                
            case .Jitter2X:
                self.antialiasingMode = .multisampling2X
                
            case .Jitter4X:
                self.antialiasingMode = .multisampling4X
                
            case .Jitter8X:
                self.antialiasingMode = .multisampling4X
                
            case .Jitter16X:
                self.antialiasingMode = .multisampling4X
        }
        self.isJitteringEnabled = Settings.GetBool(.EnableJittering)
        #if DEBUG
        self.showsStatistics = Settings.GetBool(.ShowStatistics)
        #else
        self.showsStatistics = false
        #endif
        
        #if true
        Features.FeatureEnabled(.NonStockCamera)
        {
            [weak self] Enabled in
            if Enabled
            {
                Debug.Print("Creating globe camera.")
                self?.CreateGlobeCamera()
            }
            else
            {
                Debug.Print("Creating old-style camera.")
                self?.CreateCamera()
            }
        }
//        CreateCamera()
//        CreateGlobeCamera()
        #endif

        SetupLights()
        
        SetEarthMap()
        if Settings.GetBool(.InAttractMode)
        {
            StopClock()
            AttractEarth()
        }
        else
        {
            StartClock()
        }
        UpdateEarthView()
        UpdateHourLongitudes(PreviousPrettyPercent ?? 0.0)
        StartDarknessClock()

        #if DEBUG
        if Settings.GetBool(.ShowAxes)
        {
            AddAxis()
        }
        if Settings.GetBool(.ShowKnownLocations)
        {
            PlotKnownLocations()
        }
        #endif
        ApplyInitialStencils()
        if Settings.GetBool(.ShowEarthquakeRegions)
        {
            PlotRegions()
        }
    }
    
    /// Start the darkness clock. The handler will be called to determine if a node is in night or dark and
    /// change attributes accordingly.
    func StartDarknessClock()
    {
        DarkClock = Timer.StartRepeating(withTimerInterval: HourConstants.DaylightCheckInterval.rawValue, RunFirst: true)
        {
            [weak self] _ in
            if self?.EarthNode == nil
            {
                Debug.Print("No EarthNode in \(#function)")
                return
            }
            self?.EarthNode!.ForEachChild
            {
                Node in
                if Node != nil
                {
                    if Node!.CanSwitchState && Node!.HasLocation()
                    {
                        let NodeLocation = GeoPoint(Node!.Latitude!, Node!.Longitude!)
                        NodeLocation.CurrentTime = Date()
                        if let SunIsVisible = Solar.IsInDaylight(Node!.Latitude!, Node!.Longitude!)
                        {
                            Node!.IsInDaylight = SunIsVisible
                        }
                    }
                }
            }
        }
    }
    
    /// Create the Flatland camera. This is different from the one that allowsCameraControl manipulates.
    func CreateCamera()
    {
        RemoveNodeWithName(GlobeNodeNames.FlatlandCameraNode.rawValue)
        Camera = SCNCamera()
        Camera.wantsHDR = Settings.GetBool(.UseHDRCamera)
        let FieldOfView = Settings.GetCGFloat(.FieldOfView, Defaults.FieldOfView)
        Camera.fieldOfView = FieldOfView
        Camera.zFar = Settings.GetDouble(.ZFar, Defaults.ZFar)
        Camera.zNear = Settings.GetDouble(.ZNear, Defaults.ZNear)
        
        let NewOrthoScale = Settings.GetCGFloat(.CameraOrthographicScale,
                                                CGFloat(Defaults.CameraOrthographicScale.rawValue))
        Camera.usesOrthographicProjection = true
        Camera.orthographicScale = Double(NewOrthoScale)
        
        CameraNode = SCNNode()
        CameraNode.name = GlobeNodeNames.BuiltInCameraNode.rawValue
        CameraNode.camera = Camera
        CameraNode.position = Settings.GetVector(.InitialCameraPosition, SCNVector3(0.0, 0.0, Defaults.InitialZ.rawValue))
        print(">>>> CameraNode.position=\(CameraNode.position)")
        print(">>>> Camera.fieldOfView=\(Camera.fieldOfView)")
        print(">>>> Camera.orthographicScale=\(Camera.orthographicScale)")
        self.scene?.rootNode.addChildNode(CameraNode)
        #if true
        FLCameraObserver = CameraNode.observe(\.position, options: [.new, .initial])
        {
            (Node, Change) in
            OperationQueue.current?.addOperation
            {
                print("Flatland Camera position=\(Node.position)")
            }
        }
        #endif
    }
}
