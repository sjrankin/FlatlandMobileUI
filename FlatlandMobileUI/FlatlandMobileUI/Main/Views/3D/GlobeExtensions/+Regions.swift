//
//  +Regions.swift
//  Flatland
//
//  Created by Stuart Rankin on 1/17/21.
//  Copyright © 2021 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit
import SceneKit
import CoreGraphics

extension GlobeView
{
    // MARK: - Region plotting functions.

    /// Remove all regions from the region layer.
    func RemoveRegions()
    {
        if let Node = RegionNode
        {
            RegionLayer = nil
            InitializeRegionNode(Node)
        }
        RemoveRadialRegions()
    }
    
    /// Initialize the region node. This is the spherical node on which earthquake regions (or
    /// any other region) are rendered.
    /// - Important: The `blendMode` **must** be set to `.alpha` (and the `blendMode` of the EarthNode
    ///              set to `.replace`) in order for the blending to work correctly.
    /// - Parameter Node: The node to initialize.
    func InitializeRegionNode(_ Node: SCNNode2)
    {
        RegionLayer = CAShapeLayer()
        RegionLayer?.name = GlobeNodeNames.RegionNode.rawValue
        RegionLayer?.isGeometryFlipped = true
        RegionLayer?.frame = CGRect(origin: CGPoint.zero, size: CGSize(width: 3600, height: 1800))
        RegionLayer?.backgroundColor = UIColor.clear.cgColor
        Node.geometry?.firstMaterial?.diffuse.contents = RegionLayer
        Node.geometry?.firstMaterial?.blendMode = .alpha
    }
    
    /// Plot all regions on the region layer.
    /// - Note: For now, only earthquake regions are displayed.
    func PlotRegions(_ Caller: String? = nil)
    {
        if let CallerName = Caller
        {
            Debug.Print("PlotRegions called by \(CallerName)")
        }
        if RegionNode == nil
        {
            let RegionNodeShape = SCNSphere(radius: GlobeRadius.RegionLayer.rawValue)
            RegionNodeShape.segmentCount = 500
            RegionNode = SCNNode2(geometry: RegionNodeShape)
            RegionNode?.name = GlobeNodeNames.RegionNode.rawValue
            RegionNode?.position = SCNVector3(0.0, 0.0, 0.0)
            RegionNode?.castsShadow = false
            InitializeRegionNode(RegionNode!)
            EarthNode?.addChildNode(RegionNode!)
        }
        else
        {
            RemoveRegions()
        }
        let QuakeRegions = Settings.GetEarthquakeRegions()
        for Region in QuakeRegions
        {
            if Region.IsFallback
            {
                continue
            }
            PlotRegion(Region, On: RegionLayer!)
        }
    }
    
    /// The function that does the actual plotting of regions.
    /// - Parameter Region: The region to plot.
    func DoPlotRegion(_ Region: UserRegion, To Layer: CAShapeLayer)
    {
        if Region.IsRectangular
        {
            let RegionBox = CAShapeLayer()
            RegionBox.borderWidth = 1.0
            RegionBox.borderColor = UIColor.black.withAlphaComponent(0.5).cgColor
            RegionBox.backgroundColor = Region.RegionColor.withAlphaComponent(0.5).cgColor
            let UpperLeft = ConvertRegionPoint(Region.UpperLeft)
            let LowerRight = ConvertRegionPoint(Region.LowerRight)
            let Size = CGSize(width: abs(LowerRight.x - UpperLeft.x), height: abs(LowerRight.y - UpperLeft.y))
            RegionBox.frame = CGRect(origin: UpperLeft, size: Size)
            Layer.addSublayer(RegionBox)
        }
        /*
        else
        {
            PlotRadialRegion(Region)
        }
        */
    }
    
    /// Plot a region on the region layer.
    /// - Note: Depending on where the region is, more than one "region" may be plotted.
    /// - Parameter Region: The region to plot.
    func PlotRegion(_ Region: UserRegion, On Layer: CAShapeLayer)
    {
        switch GetRegionType(Region)
        {
            case .No:
                DoPlotRegion(Region, To: Layer)
                
            case .OverDateLine:
                let (East, West) = SplitRegionAlongDateLine(Region)
                DoPlotRegion(East, To: Layer)
                DoPlotRegion(West, To: Layer)
                
            default:
                return
        }
    }
    
    #if false
    // MARK: - Transient regions.
    
    /// Initialize the transient region node. This is the spherical node on which earthquake regions (or
    /// any other region) are rendered.
    /// - Important: The `blendMode` **must** be set to `.alpha` (and the `blendMode` of the EarthNode
    ///              set to `.replace`) in order for the blending to work correctly.
    /// - Note: This layer is intended for use for displaying transient regions when the user is creating new
    ///         regions via the map.
    /// - Parameter Node: The node to initialize.
    func InitializeTransientRegionNode(_ Node: SCNNode2)
    {
        TransientRegionLayer = CAShapeLayer()
        TransientRegionLayer?.name = GlobeNodeNames.RegionNode.rawValue
        TransientRegionLayer?.isGeometryFlipped = true
        TransientRegionLayer?.frame = CGRect(origin: CGPoint.zero, size: CGSize(width: 3600, height: 1800))
        TransientRegionLayer?.backgroundColor = UIColor.clear.cgColor
        Node.geometry?.firstMaterial?.diffuse.contents = TransientRegionLayer
        Node.geometry?.firstMaterial?.blendMode = .alpha
    }
    
    /// Plot transient regions.
    func PlotTransientRegions()
    {
        if TransientRegionNode == nil
        {
            let RegionNodeShape = SCNSphere(radius: GlobeRadius.RegionLayer.rawValue + 0.05)
            RegionNodeShape.segmentCount = 500
            TransientRegionNode = SCNNode2(geometry: RegionNodeShape)
            TransientRegionNode?.name = GlobeNodeNames.TransientRegionNode.rawValue
            TransientRegionNode?.position = SCNVector3(0.0, 0.0, 0.0)
            TransientRegionNode?.castsShadow = false
            InitializeTransientRegionNode(TransientRegionNode!)
            EarthNode?.addChildNode(TransientRegionNode!)
        }
        else
        {
            TransientRegionLayer?.sublayers?.removeAll()
        }
        for Region in TransientRegions
        {
            PlotRegion(Region, On: TransientRegionLayer!)
        }
    }
    
    /// Remove all transient regions.
    func ClearTransientRegions()
    {
        TransientRegionLayer?.sublayers?.removeAll()
        TransientRegions.removeAll()
    }
    
    /// Remove the specified transient region.
    /// - Parameter ID: The ID of the region to remove.
    func ClearTransientRegion(ID: UUID)
    {
        TransientRegions = TransientRegions.filter({$0.TransientID != ID})
        PlotTransientRegions()
    }
    
    /// Plot a transient region.
    /// - Parameter Point1: Upper-left (north west) point of the region.
    /// - Parameter Point2: Lower-right (south east) point of the region.
    /// - Parameter Color: The color of the region.
    /// - Parameter ID: The ID of the region.
    func PlotTransientRegion(Point1: GeoPoint, Point2: GeoPoint, Color: UIColor, ID: UUID)
    {
        let TRegion = UserRegion()
        TRegion.TransientID = ID
        TRegion.IsTransient = true
        TRegion.UpperLeft = Point1
        TRegion.LowerRight = Point2
        TRegion.RegionColor = Color
        TransientRegions.append(TRegion)
        PlotTransientRegions()
    }
    
    /// Plot a polar transient region.
    /// - Parameter NorthPole: If true, the region is centered on the north pole. If false, the region is
    ///                        centered on the south pole.
    /// - Parameter Double: Radius of the region.
    /// - Parameter Color: The color of the region.
    /// - Parameter ID: The ID of the transient region.
    func PlotTransientRegion(NorthPole: Bool, Radius: Double, Color: UIColor, ID: UUID)
    {
        let TRegion = UserRegion()
        TRegion.TransientID = ID
        TRegion.IsTransient = true
        TRegion.RegionColor = Color
        TRegion.Radius = Radius
        TransientRegions.append(TRegion)
        PlotTransientRegions()
    }
    
    /// Update a transient region.
    /// - Note: If the transient region is not found, no action is taken.
    /// - Parameter ID: The ID of the transient region to update. Must match a previously set transient
    ///                 region (see `PlotTransientRegion`).
    /// - Parameter Point1: Upper-left (north west) point of the region.
    /// - Parameter Point2: Lower-right (south east) point of the region.
    /// - Parameter Color: The color of the transient region. If nil, the color remains unchanged.
    func UpdateTransientRegion(ID: UUID, Point1: GeoPoint, Point2: GeoPoint, Color: UIColor? = nil)
    {
        for TRegion in TransientRegions
        {
            if TRegion.TransientID == ID
            {
                if let NewColor = Color
                {
                    TRegion.RegionColor = NewColor
                    TRegion.UpperLeft = Point1
                    TRegion.LowerRight = Point2
                    PlotTransientRegions()
                }
                return
            }
        }
    }
    
    /// Update a polar transient region.
    /// - Note: If the transient region is not found, no action is taken.
    /// - Parameter ID: The ID of the transient region to update. Must match a previously set transient
    ///                 region (see `PlotTransientRegion`).
    /// - Parameter NorthPole: Determines the pole where the region is drawn.
    /// - Parameter Radius: The radius of the region.
    /// - Parameter Color: The color of the region.
    func UpdateTransientRegion(ID: UUID, NorthPole: Bool, Radius: Double, Color: UIColor)
    {
        for TRegion in TransientRegions
        {
            if TRegion.TransientID == ID
            {
                TRegion.RegionColor = Color
                TRegion.Radius = Radius
                PlotTransientRegions()
            }
            else
            {
                print("Could not find transient region \(ID.uuidString)")
            }
        }
    }
    #endif
    
    // MARK: - Utility functions
    
    /// Convert the passed point to a coordinate in a rectangle whose dimensions are passed.
    /// - Parameter Point: The point to convert.
    /// - Parameter Width: The width of the target rectangle. Defaults to `3600`.
    /// - Parameter Height: The height of the target rectangle. Defaults to `1800`.
    /// - Returns: Point with the equivalent location in the virtual passed rectangle for the
    ///            geographical point in `Point`.
    func ConvertRegionPoint(_ Point: GeoPoint, Width: Int = 3600, Height: Int = 1800) -> CGPoint
    {
        var WLat = Point.Latitude
        if WLat >= 0.0
        {
            WLat = 90.0 - WLat
        }
        else
        {
            WLat = 90.0 + abs(WLat)
        }
        let LatPercent = WLat / 180.0
        let FinalY = LatPercent * Double(Height)
        
        var WLon = Point.Longitude
        WLon = WLon + 180.0
        let LonPercent = WLon / 360.0
        let FinalX = LonPercent * Double(Width)
        
        return CGPoint(x: FinalX, y: FinalY)
    }
    
    /// Converts the passed distance to map units (eg, pixels) based on the size of the map. Intended for use
    /// only for distance from a pole.
    /// - Note: Distances are assumed to be in kilometers.
    /// - Parameter Distance: Number of kilometers to convert to map units.
    /// - Parameter Width: Width of the map in pixels. Defaults to `3600`.
    /// - Parameter Height: Height of the map in pixels. Defaults to `1800`.
    /// - Returns: Number of map units (pixels) equivalent to the number of kilometers.
    func ConvertedDistance(_ Distance: Double, Width: Int = 3600, Height: Int = 1800) -> Double
    {
        let Circumference = PhysicalConstants.HalfEarthCircumference.rawValue
        let Ratio = Distance / Circumference
        return Double(Height) * Ratio
    }
    
    /// Split the passed region into two, separated by the international date line (a simplified
    /// version of the date line).
    /// - Note: This function assumes the region straddles the date line (180°E).
    /// - Parameter Region: The region to split.
    /// - Returns: Tuple of an eastern region and a western region.
    func SplitRegionAlongDateLine(_ Region: UserRegion) -> (East: UserRegion, West: UserRegion)
    {
        let East = UserRegion()
        East.RegionColor = Region.RegionColor
        let West = UserRegion()
        West.RegionColor = Region.RegionColor
        
        East.UpperLeft.Latitude = Region.UpperLeft.Latitude
        East.UpperLeft.Longitude = Region.UpperLeft.Longitude
        East.LowerRight.Latitude = Region.LowerRight.Latitude
        East.LowerRight.Longitude = 180.0
        
        West.UpperLeft.Latitude = Region.UpperLeft.Latitude
        West.UpperLeft.Longitude = -180.0
        West.LowerRight.Latitude = Region.LowerRight.Latitude
        West.LowerRight.Longitude = Region.LowerRight.Longitude
        
        return (East, West)
    }
    
    /// Determines if a region is a special case requiring extra processing.
    /// - Parameter Region: The region to test.
    /// - Returns: The type of region.
    func GetRegionType(_ Region: UserRegion) -> SpecialCaseRegions
    {
        if Region.InRegion(Latitude: 90.0, Longitude: 0.0)
        {
            return .OverNorthPole
        }
        if Region.InRegion(Latitude: -90.0, Longitude: 0.0)
        {
            return .OverSouthPole
        }
        if Region.UpperLeft.Longitude > 0.0 && Region.LowerRight.Longitude < 0.0
        {
            return .OverDateLine
        }
        return .No
    }
}

/// Determines special case regions.
enum SpecialCaseRegions
{
    /// Not a special case.
    case No
    /// The region straddles the international date line.
    case OverDateLine
    /// The region is over the south pole.
    case OverSouthPole
    /// The region is over the north pole.
    case OverNorthPole
}
