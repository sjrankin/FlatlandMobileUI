//
//  +LocationAttributes.swift
//  +LocationAttributes
//
//  Created by Stuart Rankin on 7/19/21. Adapted from Flatland View.
//

import Foundation
import UIKit

extension Settings
{
    // MARK: - Settings related to attributes of locations.
    
    /// Returns the default city group color.
    /// - Parameter For: The city group for which the default color will be returned.
    /// - Returns: Color for the specified city group.
    public static func DefaultCityGroupColor(For: CityGroups) -> UIColor
    {
        switch For
        {
            case .AfricanCities:
                return UIColor.blue
                
            case .AsianCities:
                return UIColor.brown
                
            case .EuropeanCities:
                return UIColor.magenta
                
            case .NorthAmericanCities:
                return UIColor.green
                
            case .SouthAmericanCities:
                return UIColor.cyan
                
            case .WorldCities:
                return UIColor.red
                
            case .CapitalCities:
                return UIColor.yellow
        }
    }
    
    /// Determines if the specific longitude line should be drawn.
    /// - Parameter Longitude: The line whose drawing status will be returned.
    /// - Returns: True if the line should be drawn, false if not.
    public static func DrawLongitudeLine(_ Longitude: Latitudes) -> Bool
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
    public static func DrawLatitudeLine(_ Latitude: Longitudes) -> Bool
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
