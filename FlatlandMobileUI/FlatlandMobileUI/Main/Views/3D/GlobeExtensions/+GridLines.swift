//
//  +GridLines.swift
//  Flatland
//
//  Created by Stuart Rankin on 6/4/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

extension GlobeView
{
    // MARK: - 3D grid lines
    
    /// Draw an image with grid lines on it that can be used as a texture on top of a global image.
    /// - Note:
    ///    - This function draws the minor grid lines. It calls another function to draw the
    ///      major grid lines on top of the minor grid lines.
    ///    - If required, minor grid lines are drawn first so the major grid lines will overlap them
    ///      and will always be visible (since major grid lines are more important than minor grid
    ///      lines).
    ///    - All grid line generation is a complete rewrite from the iOS version as iOS has functions
    ///      not present in macOS.
    /// - TODO: Back port the macOS code to iOS (assuming it will work on iOS).
    /// - Parameter Width: Width of the image to return.
    /// - Parameter Height: Height of the image to return.
    /// - Returns: Image of the specified size with the grid lines drawn as per user settings.
    func MakeGridLines(Width: CGFloat, Height: CGFloat) -> UIImage
    {
        let LineColor = Settings.GetColor(.GridLineColor, UIColor.red)
        let MinorLineColor = Settings.GetColor(.MinorGridLineColor, UIColor.yellow)
        let Base = UIImage(Color: UIColor.clear, Size: CGSize(width: Width, height: Height))
        let Line = UIBezierPath()
        if Settings.GetBool(.Show3DMinorGrid)
        {
            let Gap = Settings.GetDouble(.MinorGrid3DGap, Defaults.MinorGridGap)
            for Longitude in stride(from: 0.0, to : 360.0, by: Gap)
            {
                let X = Width * CGFloat(Longitude / 360.0)
                Line.move(to: CGPoint(x: X, y: 0.0))
                Line.addLine(to: CGPoint(x: X, y: Height))
            }
            for Latitude in stride(from: 0.0, to: 360.0, by: Gap)
            {
                let Y = Height * CGFloat(Latitude / 360.0)
                Line.move(to: CGPoint(x: 0.0, y: Y))
                Line.addLine(to: CGPoint(x: Width, y: Y))
            }
            Line.lineWidth = CGFloat(Defaults.GridLineWidth.rawValue)
            MinorLineColor.withAlphaComponent(1.0).setStroke()
            Line.stroke()
        }
        
        //Draw the major grid lines on top of the minor grid lines. This is done in three lines of
        //code rather than one as an aid for debugging.
        var Final = Base
        DrawMajorGridLines(On: &Final, Width: Width, Height: Height, LineColor: LineColor)
        return Final
    }
    
    /// Draw the major grid lines.
    /// - Note: Major grid lines are the prime and anti-prime meridians, polar circles, tropical
    ///         circles, and equator.
    /// - Parameter On: The base image on which the grid lines will be drawn.
    /// - Parameter Width: The width of the image.
    /// - Parameter Height: The height of the image.
    /// - Parameter LineColor: The color of the line. Defaults to `UIColor.yellow`.
    /// - Returns: Image (based on `On`) with the appropriate grid lines drawn.
    func DrawMajorGridLines(On Image: inout UIImage, Width: CGFloat, Height: CGFloat,
                            LineColor: UIColor = UIColor.yellow)
    {
        let Line = UIBezierPath()
        
        for Longitude in Latitudes.allCases
        {
            if DrawLongitudeLine(Longitude)
            {
                let Y = Height * CGFloat(Longitude.rawValue)
                Line.move(to: CGPoint(x: 0, y: Y))
                Line.addLine(to: CGPoint(x: Width, y: Y))
            }
        }
        
        for Latitude in Longitudes.allCases
        {
            if DrawLatitudeLine(Latitude)
            {
                let X = Width * CGFloat(Latitude.rawValue)
                Line.move(to: CGPoint(x: X, y: 0))
                Line.addLine(to: CGPoint(x: X, y: Height))
            }
        }
        
        Line.lineWidth = CGFloat(Defaults.GridLineWidth.rawValue)
        LineColor.withAlphaComponent(1.0).setStroke()
        Line.stroke()
    }
    
    /// Determines if the specific longitude line should be drawn.
    /// - Parameter Longitude: The line whose drawing status will be returned.
    /// - Returns: True if the line should be drawn, false if not.
    func DrawLongitudeLine(_ Longitude: Latitudes) -> Bool
    {
        switch Longitude
        {
            case .AntarcticCircle, .ArcticCircle:
                return Settings.GetBool(.Show3DPolarCircles)
            
            case .Equator:
                return Settings.GetBool(.Show3DEquator)
            
            case .TropicOfCancer, .TropicOfCapricorn:
                return Settings.GetBool(.Show3DTropics)
        }
    }
    
    /// Determines if the specific latitude line should be drawn.
    /// - Parameter Latitude: The line whose drawing status will be returned.
    /// - Returns: True if the line should be drawn, false if not.
    func DrawLatitudeLine(_ Latitude: Longitudes) -> Bool
    {
        switch Latitude
        {
            case .PrimeMeridian, .OtherPrimeMeridian:
                return Settings.GetBool(.Show3DPrimeMeridians)
            
            case .AntiPrimeMeridian, .OtherAntiPrimeMeridian:
                return Settings.GetBool(.Show3DPrimeMeridians)
        }
    }
}
