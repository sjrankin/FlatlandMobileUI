//
//  +NewCamera.swift
//  Flatland
//
//  Created by Stuart Rankin on 4/5/21.
//  Copyright © 2021 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit
import SceneKit

extension GlobeView
{
    func CreateGlobeCamera()
    {
        self.allowsCameraControl = false
        AnchorNode = SCNNode2()
        AnchorNode?.position = SCNVector3(0.0, 0.0, 0.0)
        AnchorNode?.name = "Camera Anchor Node"
        self.scene?.rootNode.addChildNode(AnchorNode!)
        let YRotate: CGFloat = 0.0//CGFloat(90.0 + Sun.Declination(For: Date()))
        AnchorNode?.eulerAngles = SCNVector3(0.0, YRotate.Radians, 0.0)
        
        GlobeCamera = SCNCamera()
        GlobeCamera?.fieldOfView = 10.0//Settings.GetCGFloat(.CameraFieldOfView, Defaults.FieldOfView)
        print("ZFar=\(Settings.GetDouble(.ZFar, Defaults.ZFar))")
        GlobeCamera?.zFar = Settings.GetDouble(.ZFar, Defaults.ZFar)
        GlobeCamera?.zNear = Settings.GetDouble(.ZNear, Defaults.ZNear)
        GlobeCamera?.wantsHDR = Settings.GetBool(.UseHDRCamera)
        
        GlobeCameraNode = SCNNode()
        GlobeCameraNode?.name = "Globe Camera Node"
        GlobeCameraNode?.camera = GlobeCamera
        let InitialLocation = Settings.GetVector(.InitialCameraPosition, SCNVector3(0.0, 0.0, 175.0))
        print("InitialLocation=\(InitialLocation)")
        GlobeCameraNode?.position = InitialLocation
        AnchorNode?.addChildNode(GlobeCameraNode!)
    }
    
    /// Run the camera in attract mode.
    func CameraAttract()
    {
        let RotateZ = SCNAction.rotateBy(x: 0.0, y: 0.0, z: CGFloat(-90.0.Radians), duration: 3.0)
        AnchorNode?.runAction(RotateZ)
        let Orient = SCNAction.rotateTo(x: CGFloat(10.0).Radians, y: CGFloat(0.0).Radians, z: CGFloat(0.0).Radians,
                                        duration: 5.0)
        GlobeCameraNode?.runAction(Orient)
        let ZoomIn = SCNAction.move(to: SCNVector3(0.0, 0.0, 50.0), duration: 4.0)
        GlobeCameraNode?.runAction(ZoomIn)
        {
            let RotateX = SCNAction.rotateBy(x: CGFloat(-180.0).Radians, y: 0.0, z: 0.0, duration: 30.0)
            let RotateXForever = SCNAction.repeatForever(RotateX)
            self.AnchorNode?.runAction(RotateXForever)
        }
    }
}
