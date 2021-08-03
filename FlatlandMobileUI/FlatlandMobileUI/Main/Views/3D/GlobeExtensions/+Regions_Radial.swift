//
//  +Regions_Radial.swift
//  Flatland
//
//  Created by Stuart Rankin on 1/30/21.
//  Copyright © 2021 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit
import SceneKit

extension GlobeView
{
    /// Create a radial region.
    /// - Parameter From: The `UserRegion` from which a radial region is created.
    /// - Returns: A `RadialLayer` instance to apply to the `EarthNode`.
    private func DoMakeRadialRegion(From Region: UserRegion) -> RadialLayer
    {
        let NewRadial = RadialLayer()
        NewRadial.RegionID = Region.ID
        NewRadial.Overlay = CAShapeLayer()
        NewRadial.Overlay?.name = "Radial Surface"
        NewRadial.Overlay?.isGeometryFlipped = true
        NewRadial.Overlay?.frame = CGRect(origin: .zero,
                                          size: CGSize(width: Defaults.StandardMapWidth.rawValue,
                                                       height: Defaults.StandardMapHeight.rawValue))
        NewRadial.Overlay?.backgroundColor = UIColor.clear.cgColor
        let RadialPercent = Region.Radius / PhysicalConstants.EarthCircumference.rawValue
        let Radius = Defaults.StandardMapWidth.rawValue * RadialPercent
        let RegionOrigin = CGPoint(x: (Defaults.StandardMapWidth.rawValue / 2.0) - Radius,
                                   y: (Defaults.StandardMapHeight.rawValue / 2.0) - Radius)
        let Size = CGSize(width: Radius * 2.0, height: Radius * 2.0)
        let Path = CGMutablePath(ellipseIn: CGRect(origin: RegionOrigin, size: Size), transform: nil)
        NewRadial.Overlay?.strokeColor = UIColor.black.withAlphaComponent(RadialConstants.RegionAlpha.rawValue).cgColor
        NewRadial.Overlay?.lineWidth = RadialConstants.RegionBorderWidth.rawValue
        NewRadial.Overlay?.edgeAntialiasingMask = .layerTopEdge
        NewRadial.Overlay?.fillColor = Region.RegionColor.withAlphaComponent(RadialConstants.RegionAlpha.rawValue).cgColor
        NewRadial.Overlay?.path = Path
        
        NewRadial.ContainingNode = SCNNode2()
        let Geo = SCNSphere(radius: GlobeRadius.RegionLayer.rawValue + GetRegionLayerRadiusOffset())
        Geo.segmentCount = Int(RadialConstants.SegmentCount.rawValue)
        NewRadial.ContainingNode?.geometry = Geo
        NewRadial.ContainingNode?.name = "Radial Region Container"
        NewRadial.ContainingNode?.position = SCNVector3(0.0, 0.0, 0.0)
        NewRadial.ContainingNode?.castsShadow = false
        NewRadial.ContainingNode?.geometry?.firstMaterial?.blendMode = .alpha
        NewRadial.ContainingNode?.geometry?.firstMaterial?.diffuse.contents = NewRadial.Overlay!
        NewRadial.ContainingNode?.geometry?.firstMaterial?.selfIllumination.contents = NewRadial.Overlay!
        NewRadial.ContainingNode?.eulerAngles = SCNVector3(0.0, 0.0, 0.0)
        let XRotate = (-Region.Center.Latitude).Radians
        let YRotate = (Region.Center.Longitude).Radians
        NewRadial.ContainingNode?.eulerAngles = SCNVector3(CGFloat(XRotate), CGFloat(YRotate), 0.0)

        return NewRadial
    }
    
    /// Get an offset for radial layers' radii.
    /// - Returns: Offset value to use when creating layers for radial regions.
    func GetRegionLayerRadiusOffset() -> CGFloat
    {
        #if true
        return 0.0
        #else
        RadialRadiusOffset = RadialRadiusOffset + RadialConstants.RadialOffsetIncrement.rawValue
        Debug.Print("RadialRadiusOffset+base=\(RadialRadiusOffset + GlobeRadius.RegionLayer.rawValue)")
        return RadialRadiusOffset
        #endif
    }
    
    /// Return the radial region layer with the specfied ID.
    /// - Parameter ID: The ID of the radial layer to return.
    /// - Returns: The radial layer on success, nil if not found.
    func GetRadialRegion(ID: UUID) -> RadialLayer?
    {
        #if false
        for Radial in RadialContainer
        {
            if Radial.RegionID == ID
            {
                return Radial
            }
        }
        #endif
        return nil
    }
    
    /// Get a radial layer.
    /// - Parameter Region: The layer whose ID is the same as this ID in `Region` will be returned.
    /// - Returns: The specified layer on success, nil if not found.
    func GetRadialRegion(_ Region: UserRegion) -> RadialLayer?
    {
        return GetRadialRegion(ID: Region.ID)
    }
    
    /// Add a radial region.
    /// - Parameter Region: The region to add.
    func AddRadialRegion(_ Region: UserRegion)
    {
        #if false
        if GetRadialRegion(ID: Region.ID) != nil
        {
            Debug.Print("Region \(Region.ID.uuidString) already exists")
            return
        }
        let NewRadialRegion = DoMakeRadialRegion(From: Region)
        RadialContainer.append(NewRadialRegion)
        EarthNode?.addChildNode(NewRadialRegion.ContainingNode!)
        #endif
    }
    
    /// Remove the radial layer specified by `Region.ID`.
    /// - Parameter Region: The region whose ID is used to specify the region/layer to remove.
    func RemoveRadialRegion(_ Region: UserRegion)
    {
        RemoveRadialRegion(ID: Region.ID)
    }
    
    /// Remove the radial layer specified by the passed ID.
    /// - Parameter ID: The ID of the layer to remove. If not found, no action taken.
    func RemoveRadialRegion(ID: UUID)
    {
        #if false
        if let Region = GetRadialRegion(ID: ID)
        {
            if let Node = Region.ContainingNode
            {
                Node.removeAllActions()
                Node.removeAllAnimations()
                Node.removeFromParentNode()
                Node.geometry = nil
            }
        }
        RadialContainer = RadialContainer.filter({$0.RegionID != ID})
        #endif
    }
    
    /// Remove radial layers (and so radial regions) from the view.
    func RemoveRadialRegions()
    {
        #if false
        for RadialL in RadialContainer
        {
            RadialL.ContainingNode?.removeFromParentNode()
            RadialL.ContainingNode?.removeAllActions()
            RadialL.ContainingNode?.removeAllAnimations()
            RadialL.ContainingNode = nil
        }
        RadialContainer.removeAll()
        RadialRadiusOffset = 0.011
        #endif
    }
    
    /// "Update" the current radial layer with data from the passed region.
    /// - Note: The old layer is deleted and a new one created in its place.
    /// - Parameter With: The region whose data will be used to "update" the layer.
    func UpdateRadialRegion(With NewRegion: UserRegion)
    {
        RemoveRadialRegion(NewRegion)
        AddRadialRegion(NewRegion)
    }
    
    /// Plot a radial region.
    func PlotRadialRegion(_ Region: UserRegion)
    {
        if !Region.IsRectangular
        {
            AddRadialRegion(Region)
        }
    }
}
