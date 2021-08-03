//
//  +EarthquakeSettings.swift
//  +EarthquakeSettings
//
//  Created by Stuart Rankin on 7/19/21. Adapted from Flatland View.
//

import Foundation
import UIKit

extension Settings
{
    // MARK: - Earthquake-related setting handling.
    
    /// Load earthquake regions.
    /// - Returns: Array of previously stored user regions. Empty if no regions available.
    public static func GetEarthquakeRegions() -> [UserRegion]
    {
        var Regions = [UserRegion]()
        let Raw = UserDefaults.standard.string(forKey: SettingKeys.EarthquakeRegions.rawValue)
        if let Parts = Raw?.split(separator: "∫", omittingEmptySubsequences: true)
        {
            for Part in Parts
            {
                if let Region = UserRegion.Decode(Raw: String(Part))
                {
                    Regions.append(Region)
                }
            }
        }
        return Regions
    }
    
    /// Save earthquake regions.
    /// - Parameter Regions: Array of earthquake regions to save.
    public static func SetEarthquakeRegions(_ Regions: [UserRegion])
    {
        var Final: String = ""
        for Region in Regions
        {
            Final.append("\(Region)")
            Final.append("∫")
        }
        UserDefaults.standard.setValue(Final, forKey: SettingKeys.EarthquakeRegions.rawValue)
        NotifySubscribers(Setting: .EarthquakeRegions, OldValue: nil, NewValue: Regions as Any)
    }
    
    /// Parse a single entry in the stored earthquake magnitude level to color.
    /// - Parameter Mag: Raw magnitude value.
    /// - Parameter Color: Raw color value.
    /// - Parameter FinalMag: On success, the magnitude level. On failure, undefined.
    /// - Parameter FinalColor: On success, the color for the associated magnitude. On failure, undefined.
    /// - Returns: True if `Mag` and `Color` are well-defined, false otherwise. If false is returned,
    ///            `FinalMag` and `FinalColor` are undefined.
    private static func IsValidMagColor(_ Mag: String, _ Color: String, _ FinalMag: inout Double,
                                        _ FinalColor: inout UIColor) -> Bool
    {
        let SomeDouble = Double(Mag)
        let SomeColor = UIColor(HexString: Color)
        if SomeDouble == nil || SomeColor == nil
        {
            return false
        }
        FinalMag = SomeDouble!
        FinalColor = SomeColor!
        return true
    }
    
    /// Get a dictionary of earthquake magnitudes to colors.
    /// - Returns: Dictionary of colors to earthquake magnitude levels.
    public static func GetMagnitudeColors() -> [EarthquakeMagnitudes: UIColor]
    {
        if let Raw = UserDefaults.standard.string(forKey: SettingKeys.EarthquakeMagnitudeColors.rawValue)
        {
            let Parts = Raw.split(separator: ";", omittingEmptySubsequences: true)
            if Parts.count == 6
            {
                var ColorDict = [EarthquakeMagnitudes: UIColor]()
                for Part in Parts
                {
                    let SubParts = String(Part).split(separator: ",", omittingEmptySubsequences: true)
                    if SubParts.count != 2
                    {
                        SetMagnitudeColors(DefaultMagnitudeColors(), Notify: false)
                        return DefaultMagnitudeColors()
                    }
                    var FinalMag: Double = 0.0
                    var FinalColor: UIColor = UIColor.white
                    if !IsValidMagColor(String(SubParts[0]), String(SubParts[1]), &FinalMag, &FinalColor)
                    {
                        SetMagnitudeColors(DefaultMagnitudeColors(), Notify: false)
                        return DefaultMagnitudeColors()
                    }
                    let MagIndex = EarthquakeMagnitudes(rawValue: FinalMag)!
                    ColorDict[MagIndex] = FinalColor
                }
                return ColorDict
            }
        }
        SetMagnitudeColors(DefaultMagnitudeColors(), Notify: false)
        return DefaultMagnitudeColors()
    }
    
    /// Returns a dictionary of default colors for earthquake magnitudes.
    /// - Returns: Dictionary of colors to earthquake magnitude levels.
    public static func DefaultMagnitudeColors() -> [EarthquakeMagnitudes: UIColor]
    {
        let ColorDict: [EarthquakeMagnitudes: UIColor] =
        [
            .Mag4: UIColor(HexString: "#FEFCBF")!,
            .Mag5: UIColor(HexString: "#FEFB00")!,
            .Mag6: UIColor(HexString: "#FFD478")!,
            .Mag7: UIColor(HexString: "#FF9300")!,
            .Mag8: UIColor(HexString: "#FF2F92")!,
            .Mag9: UIColor(HexString: "#FF2400")!
        ]
        return ColorDict
    }
    
    /// Save a set of colors associated with earthquake magnitude levels.
    /// - Parameter MagColors: A dictionary of colors for magnitude levels.
    /// - Parameter Notify: If true, subscribers are notified of changes. Defaults to `true`.
    public static func SetMagnitudeColors(_ MagColors: [EarthquakeMagnitudes: UIColor], Notify: Bool = true)
    {
        var Final = ""
        for (Mag, Color) in MagColors
        {
            Final.append("\(Mag.rawValue),\(Color.Hex);")
        }
        UserDefaults.standard.set(Final, forKey: SettingKeys.EarthquakeMagnitudeColors.rawValue)
        if Notify
        {
            NotifySubscribers(Setting: .EarthquakeMagnitudeColors, OldValue: nil, NewValue: MagColors)
        }
    }
    
    /// List of columns excluded in insert statements.
    private static let ExcludedColumns = ["PKID", "ID"]
    
    public static func MakeInsertStatement(_ From: [(String, String)]) -> String
    {
        var ColumnList = ""
        var ValueList = ""
        for (Name, Value) in From
        {
            if ExcludedColumns.contains(Name)
            {
                continue
            }
            ColumnList.append(Name)
            ColumnList.append(",")
            ValueList.append(Value)
            ValueList.append(",")
        }
        ColumnList = String(ColumnList.dropLast(1))
        ValueList = String(ValueList.dropLast(1))
        let Final = "INSERT INTO \(QuakeTableNames.Historic.rawValue) (\(ColumnList)) VALUES(\(ValueList));"
        return Final
    }
    
    public static func CompressQuakes(_ Quakes: [Earthquake]) -> [Earthquake]
    {
        class QuakeSet
        {
            init(_ Code: String, _ Quake: Earthquake)
            {
                self.Code = Code
                QuakeList.append(Quake)
            }
            
            var Code: String = ""
            var QuakeList = [Earthquake]()
        }
        
        var Unique = [QuakeSet]()
        for Quake in Quakes
        {
            let Saved = Unique.filter({$0.Code == Quake.Code})
            if Saved.count == 0
            {
                Unique.append(QuakeSet(Quake.Code, Quake))
            }
        }
        
        var Final = [Earthquake]()
        
        for Uni in Unique
        {
            if Uni.QuakeList.count < 1
            {
                fatalError("Missing earthquakes in \(Uni.Code)")
            }
            if Uni.QuakeList.count > 1
            {
                var Seq = -1
                var SeqQuake: Earthquake? = nil
                for UQuake in Uni.QuakeList
                {
                    if UQuake.Sequence > Seq
                    {
                        SeqQuake = UQuake
                        Seq = UQuake.Sequence
                    }
                }
                if let Latest = SeqQuake
                {
                    Final.append(Latest)
                }
            }
            else
            {
                Final.append(Uni.QuakeList.first!)
            }
        }
        
        return Final
    }
    
    /// Cache the list of earthquakes in settings.
    /// - Note: Cached earthquakes are used at start-up to show the user something rather than
    ///         have no earthquakes show up at all until the USGS sends data.
    /// - Parameter QuakeList: List of earthquakes to cache.
    public static func CacheEarthquakes(_ QuakeList: [Earthquake])
    {
#if false
        var Working = ""
        for Quake in QuakeList
        {
            Working.append(Quake.Serialize())
            Working.append("\n")
        }
        SetString(.CachedEarthquakes, Working)
#endif
        
        let Compressed = CompressQuakes(QuakeList)
        for Quake in Compressed
        {
            let QuakeData = Earthquake.GetFieldData(Quake)
            let InsertStatement = MakeInsertStatement(QuakeData)
            Settings.SaveQuake(Code: Quake.Code, WithInsert: InsertStatement)
        }
    }
    
    /// Returns an array of earthquakes from the set of cached earthquakes in settings.
    /// - Returns: Array of earthquakes from cached data.
    public static func GetCachedEarthquakes() -> [Earthquake]
    {
        var DeCached = [Earthquake]()
#if true
        return DBIF.QuakesInDB
#else
        if let Raw = GetString(.CachedEarthquakes)
        {
            let Parts = Raw.split(separator: "\n", omittingEmptySubsequences: true)
            for Part in Parts
            {
                let Serialized = String(Part)
                if let Quake = Earthquake.Deserialize(Serialized)
                {
                    DeCached.append(Quake)
                }
            }
        }
        return DeCached
#endif
    }
}
