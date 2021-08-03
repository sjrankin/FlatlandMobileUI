//
//  +UserCamera.swift
//  Flatland
//
//  Created by Stuart Rankin on 7/5/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit
import SceneKit

/// Extension methods for `GlobeView` to implement our own camera control (due to limitations of the built-in
/// camera control).
extension GlobeView
{
    // MARK: - Flatland's Camera
    
    #if false
    /// Create the user camera.
    /// - Parameter At: The initial location of the camera. Defaults to `SCNVector3(0.0, 0.0, 16.0)`.
    func CreateUserCamera(At Position: SCNVector3 = SCNVector3(0.0, 0.0, 16.0))
    {
        FlatlandCamera = SCNCamera()
        FlatlandCamera?.wantsHDR = Settings.GetBool(.UseHDRCamera)
        FlatlandCamera?.fieldOfView = CGFloat(Settings.GetDouble(.FieldOfView, 90.0))
        FlatlandCamera?.usesOrthographicProjection = true
        FlatlandCamera?.orthographicScale = Settings.GetDouble(.OrthographicScale, 14.0)
        FlatlandCamera?.zFar = 500
        FlatlandCamera?.zNear = 0.1
        FlatlandCameraNode = SCNNode()
        FlatlandCameraNode?.camera = FlatlandCamera
        FlatlandCameraNode?.position = Position
        FlatlandCameraLocation = Position
        FlatlandCameraNode?.name = GlobeNodeNames.BuiltInCameraNode.rawValue
        FlatlandCameraNode?.look(at: SCNVector3(0.0, 0.0, 0.0))
        self.MainScene?.rootNode.addChildNode(FlatlandCameraNode!)
    }
    
    /// Update the user camera with presumably new user-changeable settings.
    func UpdateUserCamera()
    {
        if self.MainScene == nil
        {
            return
        }
        for Node in self.MainScene!.rootNode.childNodes
        {
            if Node.name == GlobeNodeNames.BuiltInCameraNode.rawValue
            {
                Node.camera?.wantsHDR = Settings.GetBool(.UseHDRCamera)
                Node.camera?.fieldOfView = CGFloat(Settings.GetDouble(.FieldOfView, 90.0))
                Node.camera?.orthographicScale = Settings.GetDouble(.OrthographicScale, 14.0)
            }
        }
    }
    
    /// Move the user camera to the passed location.
    /// - Parameter To: The new position for the camera.
    /// - Parameter Duration: The duration of the animation to use to move the camera. If `0.0`, no
    ///                       animation is performed and the camera is moved immediately.
    func MoveCamera(To Position: SCNVector3, Duration: Double = 0.0)
    {
        //print("New camera position: \(Position)")
        if Duration == 0.0
        {
            FlatlandCameraNode?.position = Position
            FlatlandCameraLocation = Position
        }
        else
        {
            let Move = SCNAction.move(to: Position, duration: Duration)
            FlatlandCameraNode?.runAction(Move)
            {
                self.FlatlandCameraLocation = Position
            }
        }
    }
    
    func SpinDownDragging(LastEvent: NSEvent, PreviousEvent: NSEvent)
    {
    }
    
    // MARK: - Mouse event handling.
    
    override func scrollWheel(with event: NSEvent)
    {
        super.scrollWheel(with: event)
        //print("Mouse scrolling: Y: \(event.scrollingDeltaY), X: \(event.scrollingDeltaX)")
    }
    
    /// When the user pressed the left mouse button, clear previous mouse locations and stop any ongoing
    /// camera animation.
    override func mouseDown(with event: NSEvent)
    {
        super.mouseDown(with: event)
        FlatlandCameraNode?.removeAllActions()
        MouseLocations.Clear()
        MouseLocations.Enqueue(event)
    }
    
    /// When the user released the left mouse button, spin down the animation of the Earth's motion unless
    /// there are not enough previous mouse locations to use.
    override func mouseUp(with event: NSEvent)
    {
        super.mouseUp(with: event)
        if MouseLocations.Count <= 1
        {
            return
        }
        //Need to spin down the motion of the Earth along its last vector.
        let Last = MouseLocations.Dequeue()
        let Previous = MouseLocations.Dequeue()
        SpinDownDragging(LastEvent: Last!, PreviousEvent: Previous!)
    }
    
    /// When the mouse is dragged, drag the camera with it. Accumulate locations to be used for when the user
    /// stops dragging the mouse.
    override func mouseDragged(with event: NSEvent)
    {
        super.mouseDragged(with: event)
        let dx = event.deltaX
        let dy = event.deltaY
        let dz = event.deltaZ
        //print("Left mouse dragged: \(dx),\(dy),\(dz)")
        MouseLocations.Enqueue(event)
        let NewPosition = SCNVector3(FlatlandCameraLocation.x + dx,
                                     FlatlandCameraLocation.y + dy,
                                     FlatlandCameraLocation.z + dz)
        MoveCamera(To: NewPosition)
    }
    #endif
}
