//
//  GlobeProtocol.swift
//  Flatland
//
//  Created by Stuart Rankin on 6/4/20. Adapted from Flatland View.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit
import SceneKit

/// Protocol for the 3D Globe Node.
protocol GlobeProtocol: AnyObject
{
    /// Plot a satellite.
    /// - Parameter Satellite: The satellite to plot.
    /// - Parameter At: Where to plot the satellite.
    func PlotSatellite(Satellite: Satellites, At: GeoPoint)
    
    /// Move the globe to the specified location.
    /// - Parameter Latitude: Latitude of the location.
    /// - Parameter Longitude: Longitude of the location.
    /// - Parameter UpdateOpacity: Determines whether the opacity of Earth nodes is changed.
    func MoveMapTo(Latitude: Double, Longitude: Double, UpdateOpacity: Bool)
    
    /// Reset the globe to the timer.
    func LockMapToTimer()
    
    /// Set the euler angles for the node whose edit ID is passed.
    /// - Parameter EditID: The edit ID of the node to change.
    /// - Parameter Angles: New euler angles.
    func SetNodeEulerAngles(EditID: UUID, _ Angles: SCNVector3)
    
    /// Get the euler angles for the node whose edit ID is passed.
    /// - Parameter EditID: The edit ID of the node whose euler angles are returned.
    /// - Returns: Euler angles for the node whose edit ID is `EditID`, nil if not found.
    func GetNodeEulerAngles(EditID: UUID) -> SCNVector3?
    
    /// Set the location of the node whose edit ID is passed. The node is moved by this call.
    /// - Parameter EditID: The edit ID of the node to change.
    /// - Parameter Latitude: The new latitude value for the node.
    /// - Parameter Longitude: The new longitude value for the node.
    func SetNodeLocation(EditID: UUID, _ Latitude: Double, _ Longitude: Double)
    
    /// Get the location of the node whose edit ID is passed.
    /// - Parameter EditID: The edit ID of the node whose location is returned.
    /// - Returns: Tuple of the latitude and longitude of the node. Nil if not found.
    func GetNodeLocation(EditID: UUID) -> (Latitude: Double, Longitude: Double)?
}
