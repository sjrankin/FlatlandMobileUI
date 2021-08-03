//
//  +LocationSettings.swift
//  +LocationSettings
//
//  Created by Stuart Rankin on 7/19/21. Adapted from Flatland View.
//

import Foundation
import UIKit

extension Settings
{
    // MARK: - Location settings handling.
    
    /// Determines if both the local latitude and local longitude have been set.
    /// - Returns: True if the device location has been set, false if not.
    public static func HaveLocalLocation() -> Bool
    {
        if GetDoubleNil(.UserHomeLatitude) == nil
        {
            return false
        }
        if GetDoubleNil(.UserHomeLongitude) == nil
        {
            return false
        }
        return true
    }
    
    /// Save a list of user locations.
    /// - Note: User locations are saved at `SettingTypes.UserLocations`.
    /// - Parameter List: List of location information to save.
    public static func SetLocations(_ List: [(ID: UUID, Coordinates: GeoPoint, Name: String,
                                              Color: UIColor)])
    {
        if List.count == 0
        {
            UserDefaults.standard.set("", forKey: SettingKeys.UserLocations.rawValue)
            return
        }
        var LocationList = ""
        for (ID, Location, Name, Color) in List
        {
            var Item = ID.uuidString + ","
            Item.append("\(Location.Latitude),\(Location.Longitude),")
            Item.append("\(Name),")
            let ColorName = Color.Hex
            Item.append("\(ColorName);")
            LocationList.append(Item)
        }
        UserDefaults.standard.set(LocationList, forKey: "UserLocations")
        NotifySubscribers(Setting: .UserLocations, OldValue: nil, NewValue: nil)
    }
    
    /// Get the list of user locations.
    /// - Note: User locations are saved at `SettingTypes.UserLocations`.
    /// - Returns: List of user location information.
    public static func GetLocations() -> [(ID: UUID, Coordinates: GeoPoint, Name: String,
                                           Color: UIColor)]
    {
        var Results = [(ID: UUID, Coordinates: GeoPoint, Name: String, Color: UIColor)]()
        if let Raw = UserDefaults.standard.string(forKey: "UserLocations")
        {
            let Locations = Raw.split(separator: ";", omittingEmptySubsequences: true)
            for Where in Locations
            {
                var ID: UUID = UUID()
                var Lat: Double = 0.0
                var Lon: Double = 0.0
                var Name: String = ""
                var Color: UIColor = UIColor.red
                let Raw = String(Where)
                let Parts = Raw.split(separator: ",", omittingEmptySubsequences: true)
                if Parts.count == 5
                {
                    for Index in 0 ..< Parts.count
                    {
                        let Part = String(Parts[Index]).trimmingCharacters(in: CharacterSet.whitespaces)
                        switch Index
                        {
                            case 0:
                                ID = UUID(uuidString: Part)!
                                
                            case 1:
                                Lat = Double(Part)!
                                
                            case 2:
                                Lon = Double(Part)!
                                
                            case 3:
                                Name = Part
                                
                            case 4:
                                if let ProcessedColor = UIColor(HexString: Part)
                                {
                                    Color = ProcessedColor
                                }
                                else
                                {
                                    Color = UIColor.red
                                }
                                
                            default:
                                break
                        }
                    }
                }
                Results.append((ID: ID, GeoPoint(Lat, Lon), Name: Name, Color: Color))
            }
        }
        else
        {
            return []
        }
        return Results
    }
}
