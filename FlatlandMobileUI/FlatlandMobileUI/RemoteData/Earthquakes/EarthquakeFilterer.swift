//
//  EarthquakeFilterer.swift
//  EarthquakeFilterer
//
//  Created by Stuart Rankin on 7/18/21.
//

import Foundation
import UIKit

/// Filters earthquakes as per user settings.
class EarthquakeFilterer
{
    /// Determines if an earthquake is in a region.
    /// - Parameter Quake: The quake to check against the passed region.
    /// - Parameter Region: The region to test the passed earhquake against.
    /// - Returns: True if the location of `Quake` is in `Region`, false if not.
    private static func QuakeInRegion(_ Quake: Earthquake, _ Region: UserRegion) -> Bool
    {
        if Quake.Longitude < Region.UpperLeft.Longitude
        {
            return false
        }
        if Quake.Longitude > Region.LowerRight.Longitude
        {
            return false
        }
        if Quake.Latitude < Region.UpperLeft.Latitude
        {
            return false
        }
        if Quake.Latitude > Region.LowerRight.Latitude
        {
            return false
        }
        return true
    }
    
    /// Converts the passed number of seconds to days.
    /// - Parameter Seconds: The number of seconds to convert to days.
    /// - Returns: Seconds converted to days.
    private static func AgeInDays(_ Seconds: Double) -> Double
    {
        let Days = Seconds / Double(24 * 60 * 60)
        return Days
    }
    
    /// Determines if the passed earthquake can be displayed based on user-set filters.
    /// - Parameter Quake: The earthquake to determine whether it can be shown or not.
    /// - Parameter Filters: List of filters against which the quake is compared.
    /// - Parameter AlwaysIf: A magnitude value which if a given earthquake's magnitude is greater than or
    ///                       equal to, is always included.
    /// - Returns: True if the earthquake can be displayed (meets the filter criteria), false if not.
    private static func ApplyEarthquakeFilters(_ Quake: Earthquake, _ Filters: [UserRegion],
                                               AlwaysIf GreaterThan: Double = 6.0) -> Bool
    {
        for Filter in Filters
        {
            if Filter.IsFallback
            {
                continue
            }
            if QuakeInRegion(Quake, Filter)
            {
                var MagnitudeOK = false
                if Quake.Magnitude >= Filter.MinimumMagnitude && Quake.Magnitude <= Filter.MaximumMagnitude
                {
                    MagnitudeOK = true
                }
                if Quake.Magnitude >= GreaterThan
                {
                    MagnitudeOK = true
                }
                let Days = AgeInDays(Quake.GetAge())
                let AgeOK = Int(Days) <= Filter.Age
                if AgeOK && MagnitudeOK
                {
                    return true
                }
            }
        }
        let FallBack = GetFallback(From: Filters)
        if Quake.Magnitude >= FallBack.MinimumMagnitude && Quake.Magnitude <= FallBack.MaximumMagnitude
        {
            let Days = AgeInDays(Quake.GetAge())
            if Days <= Double(FallBack.Age)
            {
                return true
            }
        }
        
        return false
    }
    
    /// Returns the fallback region.
    /// - Parameter From: The array of earthquake filters to search for the fallback filter.
    /// - Returns: The fallback region in the passed list. If one does not exist, a default fallback
    ///            filter is generated and returned.
    private static func GetFallback(From: [UserRegion]) -> UserRegion
    {
        for Filter in From
        {
            if Filter.IsFallback
            {
                return Filter
            }
        }
        return UserRegion(FallBack: true)
    }
    
    /// Returns the current set of earthquake regions set by the user.
    /// - Returns: Array of earthquake regions.
    private static func GetCurrentFilters() -> [UserRegion]
    {
        var Regions = Settings.GetEarthquakeRegions()
        if Regions.count < 1
        {
            Regions.append(UserRegion(FallBack: true))
        }
        return Regions
    }
    
    /// Filter the list of earthquakes against the current set of user-defined filters.
    /// - Parameter Quakes: Array of earthquakes to filter against.
    /// - Returns: Array of filtered earthquakes.
    public static func FilterList(_ Quakes: [Earthquake]) -> [Earthquake]
    {
        var NewList = [Earthquake]()
        let Filters = GetCurrentFilters()
        for Quake in Quakes
        {
            if ApplyEarthquakeFilters(Quake, Filters)
            {
                NewList.append(Quake)
            }
        }
        NewList = USGS.CombineEarthquakes2(NewList)
        return NewList
    }
    
    public static func SameEarthquakes(_ OldList: [Earthquake], _ NewList: [Earthquake]) -> Bool
    {
        if OldList.count != NewList.count
        {
            return false
        }
        
        return true
        
    }
}
