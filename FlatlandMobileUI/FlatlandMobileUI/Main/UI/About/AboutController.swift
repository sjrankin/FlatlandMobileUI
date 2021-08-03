//
//  AboutController.swift
//  Flatland
//
//  Created by Stuart Rankin on 6/4/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit
import SceneKit

class AboutController: UIViewController, SCNSceneRendererDelegate
{
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.view.layer.backgroundColor = UIColor.systemGray.cgColor
        
        InitializeAboutView()
    }
    
    /// Initialize the view.
    func InitializeAboutView()
    {
        AboutWorld.allowsCameraControl = false
        AboutWorld.autoenablesDefaultLighting = false
        AboutWorld.scene = SCNScene()
        AboutWorld.backgroundColor = UIColor.black
        #if false
        AboutWorld.showsStatistics = true
        #endif
        
        let Camera = SCNCamera()
        #if false
        Camera.fieldOfView = 10.0
        Camera.usesOrthographicProjection = false
        #else
        Camera.usesOrthographicProjection = true
        Camera.orthographicScale = 15
        Camera.fieldOfView = 90
        #endif
        Camera.zFar = 1000
        Camera.zNear = 0.1
        CameraNode = SCNNode()
        CameraNode.name = "Camera Node"
        CameraNode.camera = Camera
        //The camera's position is higher up in the scene to help show the shadows.
        CameraNode.position = SCNVector3(0.0, 10.0, 100.0)//18.0)
        
        let Light = SCNLight()
        Light.type = .directional
        Light.intensity = 800
        Light.castsShadow = true
        Light.shadowColor = UIColor.black.withAlphaComponent(0.80)
        Light.shadowMode = .forward
        Light.shadowRadius = 3.0
        Light.color = UIColor.white
        Light.zNear = 0.1
        Light.zFar = 1000.0
        LightNode = SCNNode()
        LightNode.name = "Sunlight"
        LightNode.light = Light
        LightNode.position = SCNVector3(0.0, 0.0, 80.0)
        
        let MoonLight = SCNLight()
        MoonLight.type = .directional
        MoonLight.intensity = 300
        MoonLight.castsShadow = true
        MoonLight.shadowColor = UIColor.black.withAlphaComponent(0.80)
        MoonLight.shadowMode = .forward
        MoonLight.shadowRadius = 6.0
        MoonLight.color = UIColor.cyan
        MoonLight.zNear = 0.1
        MoonLight.zFar = 1000.0
        MoonNode = SCNNode()
        MoonNode.name = "Moonlight"
        MoonNode.light = MoonLight
        MoonNode.position = SCNVector3(0.0, 0.0, -100.0)
        MoonNode.eulerAngles = SCNVector3(180.0 * CGFloat.pi / 180.0, 0.0, 0.0)
        
        AboutWorld.scene?.rootNode.addChildNode(CameraNode)
        AboutWorld.scene?.rootNode.addChildNode(LightNode)
        AboutWorld.scene?.rootNode.addChildNode(MoonNode)
        
        DrawWorld()
        StartEarthClock()
        //Make sure the camera is pointed to the Earth.
        CameraNode.look(at: SCNVector3(0.0, 0.0, 0.0))
    }
    
    var CameraNode = SCNNode()
    var LightNode = SCNNode()
    var MoonNode = SCNNode()
    
    func StartEarthClock()
    {
        let SomeTimer = Timer.scheduledTimer(timeInterval: 1.0,
                                             target: self,
                                             selector: #selector(UpdateAboutEarth),
                                             userInfo: nil,
                                             repeats: true)
        SomeTimer.tolerance = 0.1
    }
    
    @objc func UpdateAboutEarth()
    {
        let Now = Date()
        let TZ = TimeZone(abbreviation: "UTC")
        var Cal = Calendar(identifier: .gregorian)
        Cal.timeZone = TZ!
        let Hour = Cal.component(.hour, from: Now)
        let Minute = Cal.component(.minute, from: Now)
        let Second = Cal.component(.second, from: Now)
        let ElapsedSeconds = Second + (Minute * 60) + (Hour * 60 * 60)
        let Percent = Double(ElapsedSeconds) / Double(Date.SecondsIn(.Day))
        let PrettyPercent = Double(Int(Percent * 1000.0)) / 1000.0
        UpdateEarth(With: PrettyPercent)
    }
    
    func UpdateEarth(With Percent: Double)
    {
        let Degrees = 180.0 - (360.0) * Percent
        let Radians = Degrees.Radians
        let Rotate = SCNAction.rotateTo(x: 0.0, y: CGFloat(-Radians), z: 0.0, duration: 1.0)
        EarthNode?.runAction(Rotate)
    }
    
    /// Draw the world. Depending on the user, draw a spherical or cubical world.
    func DrawWorld()
    {
        if CurrentView == ViewTypes.Globe3D
        {
            DrawGlobeWorld()
        }
        else
        {
            DrawAboutCube()
        }
    }
    
    /// Force a map onto the about globe. This is intended mainly for debug but can be used for other purposes
    /// if needed.
    /// - Parameter Image: The image to draw on the about globe.
    func ForceMap(_ Image: UIImage)
    {
        EarthNode?.geometry?.firstMaterial?.diffuse.contents = Image
    }
    
    /// Draw a spherical world.
    func DrawGlobeWorld()
    {
        EarthNode?.removeAllActions()
        EarthNode?.removeFromParentNode()
        EarthNode = nil
        SystemNode?.removeAllActions()
        SystemNode?.removeFromParentNode()
        SystemNode = nil
        
        let Surface = SCNSphere(radius: 10.0)
        Surface.segmentCount = Settings.GetInt(.SphereSegmentCount, IfZero: 100)
        let BaseMap = UIImage(named: "AboutMap")
        if BaseMap == nil
        {
            fatalError("Error retrieving base map in About.")
        }
        EarthNode = SCNNode(geometry: Surface)
        EarthNode?.name = "Spherical Earth"
        EarthNode?.castsShadow = true
        EarthNode?.position = SCNVector3(0.0, 0.0, 0.0)
        EarthNode?.geometry?.firstMaterial?.diffuse.contents = BaseMap!
        EarthNode?.geometry?.firstMaterial?.lightingModel = .blinn
        SystemNode = SCNNode()
        AboutWorld.prepare([EarthNode!], completionHandler:
                            {
                                success in
                                if success
                                {
                                    self.SystemNode!.addChildNode(self.EarthNode!)
                                    self.AboutWorld.scene?.rootNode.addChildNode(self.SystemNode!)
                                }
                            })
        
        let Declination = Sun.Declination(For: Date())
        SystemNode!.eulerAngles = SCNVector3(Declination.Radians, 0.0, 0.0)
        AddAboutText()
    }
    
    /// Draws a cubical Earth for no other reason than being silly.
    func DrawAboutCube()
    {
        EarthNode?.removeAllActions()
        EarthNode?.removeFromParentNode()
        SystemNode?.removeAllActions()
        SystemNode?.removeFromParentNode()
        
        let EarthCube = SCNBox(width: 10.0, height: 10.0, length: 10.0, chamferRadius: 0.5)
        EarthNode = SCNNode(geometry: EarthCube)
        EarthNode?.name = "Cubic Earth"
        EarthNode?.castsShadow = true
        
        EarthNode?.position = SCNVector3(0.0, 0.0, 0.0)
        EarthNode?.geometry?.materials.removeAll()
        EarthNode?.geometry?.materials.append(MapManager.CubicImageMaterial(.nx)!)
        EarthNode?.geometry?.materials.append(MapManager.CubicImageMaterial(.pz)!)
        EarthNode?.geometry?.materials.append(MapManager.CubicImageMaterial(.px)!)
        EarthNode?.geometry?.materials.append(MapManager.CubicImageMaterial(.nz)!)
        EarthNode?.geometry?.materials.append(MapManager.CubicImageMaterial(.pym90)!)
        EarthNode?.geometry?.materials.append(MapManager.CubicImageMaterial(.ny90)!)
        EarthNode?.geometry?.firstMaterial?.specular.contents = UIColor.clear
        EarthNode?.geometry?.firstMaterial?.lightingModel = .blinn
        
        let Declination = Sun.Declination(For: Date())
        SystemNode = SCNNode()
        SystemNode?.eulerAngles = SCNVector3(Declination.Radians, 0.0, 0.0)
        
        AboutWorld.prepare([EarthNode!], completionHandler:
                            {
                                success in
                                if success
                                {
                                    self.SystemNode?.addChildNode(self.EarthNode!)
                                    self.AboutWorld.scene?.rootNode.addChildNode(self.SystemNode!)
                                }
                            }
        )
    }
    
    /// Draw the version string that orbits the Earth.
    func AddAboutText()
    {
        if TextAdded
        {
            return
        }
        TextAdded = true
        let NameNodes = Utility.MakeFloatingWord2(Radius: 12.0, Word: "Flatland", SpacingConstant: 25.0,
                                                  Latitude: 10.0, Longitude: 0.0, Extrusion: 5.0,
                                                  TextFont: UIFont(name: "Copperplate", size: 32),
                                                  TextColor: UIColor.systemRed,
                                                  TextSpecular: UIColor.systemOrange)
        let VersionData = Versioning.MakeVersionString() + ", Build \(Versioning.Build) (\(Versioning.BuildDate))"
        let VersionNodes = Utility.MakeFloatingWord2(Radius: 12.0, Word: VersionData,
                                                     SpacingConstant: 25.0,
                                                     Latitude: 0.0, Longitude: 0.0, Extrusion: 4.0,
                                                     TextFont: UIFont(name: "Avenir-Heavy", size: 24),
                                                     TextColor: UIColor.systemYellow,
                                                     TextSpecular: UIColor.white)
        let CopyrightNodes = Utility.MakeFloatingWord2(Radius: 12.0, Word: Versioning.CopyrightText(), Latitude: -10.0, Longitude: 0.0,
                                                       Extrusion: 3.0, TextFont: UIFont(name: "Avenir-Heavy", size: 24),
                                                       TextColor: UIColor.systemTeal,
                                                       TextSpecular: UIColor.white)
        let TextNode = SCNNode()
        TextNode.name = "About Text"
        NameNodes.forEach({TextNode.addChildNode($0)})
        VersionNodes.forEach({TextNode.addChildNode($0)})
        CopyrightNodes.forEach({TextNode.addChildNode($0)})
        TextNode.position = SCNVector3(0.0, 0.0, 0.0)
        AboutWorld.scene?.rootNode.addChildNode(TextNode)
        let Rotation = SCNAction.rotateBy(x: 0.0, y: -CGFloat.pi / 180.0, z: 0.0, duration: 0.05)
        let Forever = SCNAction.repeatForever(Rotation)
        TextNode.runAction(Forever)
    }
    
    var TextAdded = false
    var EarthNode: SCNNode? = nil
    var SystemNode: SCNNode? = nil
    var HourNode: SCNNode? = nil
    
    @IBAction func HandleViewTypePressed(_ sender: Any)
    {
        if let Button = sender as? UIBarButtonItem
        {
            if CurrentView == .Globe3D
            {
                CurrentView = .CubicWorld
            }
            else
            {
                CurrentView = .Globe3D
            }
            if CurrentView == .Globe3D
            {
                Button.setBackgroundImage(UIImage(systemName: "cube"),
                                          for: .normal,
                                          barMetrics: UIBarMetrics.compact)
            }
            else
            {
                Button.setBackgroundImage(UIImage(systemName: "globe"),
                                          for: .normal,
                                          barMetrics: UIBarMetrics.compact)
            }
            DrawWorld()
        }
    }
    
    @IBAction func HandleSnapshot(_ sender: Any)
    {
        let Snapshot = AboutWorld.snapshot()
        PhotoLibrary.Initialize()
        UIImageWriteToSavedPhotosAlbum(Snapshot, nil, nil, nil)
    }
    
    var CurrentView = ViewTypes.Globe3D
    
    @IBOutlet weak var ViewTypeButton: UIBarButtonItem!
    @IBOutlet weak var AboutWorld: SCNView!
}
