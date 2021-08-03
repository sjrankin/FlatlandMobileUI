//
//  UserRegion.swift
//  UserRegion
//
//  Created by Stuart Rankin on 7/20/21. Adapted from Flatland View.
//

import Foundation
import UIKit

/// Contains one user region. This is a region defined by the user to have different, user-specified
/// local parameters for displaying earthquakes or other regions the user wants to define.
class UserRegion: CustomStringConvertible, Hashable
{
    /// Create an empty user region.
    init()
    {
        IsFallback = false
        AlwaysInvisible = false
        IsEnabled = true
        UpperLeft = GeoPoint(45.0, 120.0)
        LowerRight = GeoPoint(40.0, 125.0)
        _ID = UUID()
    }
    
    /// Create the fallback user region.
    init(FallBack: Bool)
    {
        IsFallback = true
        IsEnabled = true
        AlwaysInvisible = true
        MinimumMagnitude = 5.0
        MaximumMagnitude = 10.0
        UpperLeft = GeoPoint(90.0, -180.0)
        LowerRight = GeoPoint(-90.0, 180.0)
        RegionName = "World Fallback"
        RegionColor = UIColor.clear
        BorderWidth = 0.0
        Notification = .None
        SoundName = .None
        NotifyOnNewEarthquakes = false
        IsRectangular = true
        Age = 5
        _ID = UUID()
    }
    
    /// Returns the string value of the region. Used for serialization.
    /// - Note: Transient region data not serialized.
    var description: String
    {
        get
        {
            var Value = "\(RegionName)"
            Value.append("\t")
            Value.append("\(RegionColor.Hex)")
            Value.append("\t")
            Value.append("\(BorderWidth)")
            Value.append("\t")
            Value.append("\(UpperLeft)")
            Value.append("\t")
            Value.append("\(LowerRight)")
            Value.append("\t")
            Value.append("\(MinimumMagnitude)")
            Value.append("\t")
            Value.append("\(MaximumMagnitude)")
            Value.append("\t")
            Value.append("\(Age)")
            Value.append("\t")
            Value.append("\(Notification.rawValue)")
            Value.append("\t")
            Value.append("\(SoundName.rawValue)")
            Value.append("\t")
            Value.append("\(IsFallback)")
            Value.append("\t")
            Value.append("\(IsEnabled)")
            Value.append("\t")
            Value.append("\(NotifyOnNewEarthquakes)")
            Value.append("\t")
            Value.append("\(IsRectangular)")
            Value.append("\t")
            Value.append("\(Center)")
            Value.append("\t")
            Value.append("\(Radius)")
            return Value
        }
    }
    
    /// Flag that indicates the region is transient - usually for when regions are created on the fly.
    var IsTransient: Bool = false
    
    /// ID of the transient region. Defaults to `UUID.Empty`.
    var TransientID: UUID = UUID.Empty
    
    /// Enabled flag.
    var IsEnabled: Bool = true
    
    /// If true, this is the fallback region, which is the entire world. Defaults to false.
    var IsFallback: Bool = false
    
    /// If true, the region never has its area plotted on the map. Defaults to false.
    var AlwaysInvisible: Bool = false
    
    /// The minimum magnitude to display.
    var MinimumMagnitude: Double = 5.0
    
    /// The maximum magnitude to display.
    var MaximumMagnitude: Double = 10.0
    
    /// Holds the upper left point.
    private var _UpperLeft: GeoPoint? = nil
    {
        didSet
        {
            if let UL = _UpperLeft
            {
                if let LR = _LowerRight
                {
                    //Check to see if the region straddles the date line.
                    DoesStraddleDateLine(UL, LR)
                }
            }
        }
    }
    /// Upper-left corner of the region.
    var UpperLeft: GeoPoint
    {
        get
        {
            if let SomePoint = _UpperLeft
            {
                return SomePoint
            }
            else
            {
                return GeoPoint(0.0, 0.0)
            }
        }
        set
        {
            _UpperLeft = newValue
        }
    }
    
    /// Holds the lower right point.
    private var _LowerRight: GeoPoint? = nil
    {
        didSet
        {
            if let LR = _LowerRight
            {
                if let UL = _UpperLeft
                {
                    //Check to see if the region straddles the date line.
                    DoesStraddleDateLine(UL, LR)
                }
            }
        }
    }
    /// Lower-right corner of the region.
    var LowerRight: GeoPoint
    {
        get
        {
            if let SomePoint = _LowerRight
            {
                return SomePoint
            }
            else
            {
                return GeoPoint(0.0, 0.0)
            }
        }
        set
        {
            _LowerRight = newValue
        }
    }
    
    /// Database ID of the region.
    var RegionPK: Int = 0
    
    /// The name of the region.
    var RegionName: String = ""
    
    /// The color of the border of the region.
    var RegionColor: UIColor = UIColor.red
    
    /// The width of the earthquake region.
    var BorderWidth: Double = 0.0
    
    /// How to display notifications.
    var Notification: EarthquakeNotifications = .None
    
    /// Sound to play (depending on the value in `Notification`).
    var SoundName: NotificationSounds = .None
    
    /// How many days in the past to display earthquakes.
    var Age: Int = 5
    
    /// Notify on new earthquakes.
    var NotifyOnNewEarthquakes: Bool = false
    
    /// Shape is rectangular. If false, shape is circular.
    var IsRectangular: Bool = true
    
    /// Center of the circular region.
    var Center: GeoPoint = GeoPoint(0.0, 0.0)
    
    /// Radius of the circular region.
    var Radius: Double = 0.0
    
    /// Holds the straddles date line flag.
    private var _CrossesDateLine: Bool = false
    /// Returns a flag indicating whether the region straddles the date line (`true`) or not (`false`).
    var CrossesDateLine: Bool
    {
        get
        {
            return _CrossesDateLine
        }
    }
    
    /// Returns a flag indicating whether the region crosses the equator.
    /// - Returns: True if the region straddles the equator, false if not.
    var CrossesEquator: Bool
    {
        get
        {
            return DoesStraddleEquator(UpperLeft, LowerRight)
        }
    }
    
    /// Determines if the region specified in the passed points straddles the date line.
    /// - Note: The results are stored in `_CrossesDateLine`.
    /// - Parameter UL: The upper-left (north west) corner of the region.
    /// - Parameter LR: The lower-right (south east) corner of the region.
    func DoesStraddleDateLine(_ UL: GeoPoint, _ LR: GeoPoint)
    {
        if UL.Longitude >= 0.0 && LR.Longitude < 0.0
        {
            _CrossesDateLine = true
            return
        }
        _CrossesDateLine = false
    }
    
    /// Determines if the region in the passed points straddles the equator.
    /// - Note: Unlike `DoesStraddleDateLine`, the results are returned.
    /// - Parameter UL: The upper-left (north west) corner of the region.
    /// - Parameter LR: The lower-right (south east) corner of the region.
    /// - Returns: True if the region straddles the equator, false if not.
    func DoesStraddleEquator(_ UL: GeoPoint, _ LR: GeoPoint) -> Bool
    {
        let ULSign = UL.Latitude < 0.0 ? -1 : 1
        let LRSign = LR.Latitude < 0.0 ? -1 : 1
        switch (ULSign, LRSign)
        {
            case (0, 0):
                return false
                
            case (-1, 0):
                return true
                
            case (0, -1):
                return true
                
            case (-1, -1):
                return false
                
            default:
                return true
        }
    }
    
    /// Returns the east sub-region for regions that straddle the international date line.
    /// - Returns: Tuple of the upper-left (north west) corner and lower-right (south east) corner of the
    ///            eastern sub-region. If the region does *not* straddle the date line, nil is returned.
    public func EastSubRegion() -> (UpperLeft: GeoPoint, LowerRight: GeoPoint)?
    {
        if !CrossesDateLine
        {
            return nil
        }
        let UL = GeoPoint(UpperLeft.Latitude, UpperLeft.Longitude)
        let LR = GeoPoint(LowerRight.Latitude, 180.0)
        return (UL, LR)
    }
    
    /// Returns the west sub-region for regions that straddle the international date line.
    /// - Returns: Tuple of the upper-left (north west) corner and lower-right (south east) corner of the
    ///            western sub-region. If the region does *not* straddle the date line, nil is returned.
    public func WestSubRegion() -> (UpperLeft: GeoPoint, LowerRight: GeoPoint)?
    {
        if !CrossesDateLine
        {
            return nil
        }
        let UL = GeoPoint(UpperLeft.Latitude, -180.0)
        let LR = GeoPoint(LowerRight.Latitude, LowerRight.Longitude)
        return (UL, LR)
    }
    
    /// Decode a serialized user region.
    /// - Parameter Raw: The raw, user earthquake region.
    /// - Returns: A populated `UserRegion` class on success, nil on error.
    public static func Decode(Raw: String) -> UserRegion?
    {
        let Parts = Raw.split(separator: "\t", omittingEmptySubsequences: true)
        if Parts.count != 16
        {
            return nil
        }
        let Region = UserRegion()
        for Index in 0 ..< Parts.count
        {
            let Part = String(Parts[Index])
            switch Index
            {
                case 0:
                    Region.RegionName = Part
                    
                case 1:
                    Region.RegionColor = UIColor(HexString: Part)!
                    
                case 2:
                    Region.BorderWidth = Double(Part)!
                    
                case 3:
                    if let UL = GeoPoint(Raw: Part)
                    {
                        Region.UpperLeft = UL
                    }
                    else
                    {
                        return nil
                    }
                    
                case 4:
                    if let LR = GeoPoint(Raw: Part)
                    {
                        Region.LowerRight = LR
                    }
                    else
                    {
                        return nil
                    }
                    
                case 5:
                    Region.MinimumMagnitude = Double(Part)!
                    
                case 6:
                    Region.MaximumMagnitude = Double(Part)!
                    
                case 7:
                    Region.Age = abs(Int(Part)!)
                    
                case 8:
                    Region.Notification = EarthquakeNotifications(rawValue: Part)!
                    
                case 9:
                    Region.SoundName = NotificationSounds(rawValue: Part)!
                    
                case 10:
                    Region.IsFallback = Bool(Part)!
                    
                case 11:
                    Region.IsEnabled = Bool(Part)!
                    
                case 12:
                    Region.NotifyOnNewEarthquakes = Bool(Part)!
                    
                case 13:
                    Region.IsRectangular = Bool(Part)!
                    
                case 14:
                    if let Cntr = GeoPoint(Raw: Part)
                    {
                        Region.Center = Cntr
                    }
                    else
                    {
                        return nil
                    }
                    
                case 15:
                    Region.Radius = Double(Part)!
                    
                default:
                    return nil
            }
        }
        return Region
    }
    
    /// Holds the instance ID of the region.
    private var _ID: UUID!
    /// Get or set the instance ID of the region.
    public var ID: UUID
    {
        get
        {
            return _ID
        }
        set
        {
            _ID = newValue
        }
    }
    
    /// Determines if the passed point is within the passed rectangular region.
    /// - Parameter Latitude: The latitude of the point to determine whether it is in the region or not.
    /// - Parameter Longitude: The longitude of the point to determine whether it is in the region or not.
    /// - Parameter UpperLeft: The upper-left (north east) point of the region.
    /// - Parameter LowerRight: The lower-right (south west) point of the region.
    /// - Returns: True if the passed point is in the passed region, false if not.
    private func PointInBounds(Latitude: Double, Longitude: Double, UpperLeft: GeoPoint, LowerRight: GeoPoint) -> Bool
    {
        if Latitude < LowerRight.Latitude
        {
            return false
        }
        if Latitude > UpperLeft.Latitude
        {
            return false
        }
        if Longitude < UpperLeft.Longitude
        {
            return false
        }
        if Longitude > LowerRight.Longitude
        {
            return false
        }
        return true
    }
    
    /// Determines if the passed coordinate is within the defined region.
    /// - Note: Rectangular regions that straddle the (virtual) international date line will take extra processing
    ///         as the region must be split into eastern and western sub-regions and each sub-region checked
    ///         separately.
    /// - Parameter Latitude: The latitude of the point to test.
    /// - Parameter Longitude: The longitude of the point to test.
    /// - Returns: True if the passed point is in the region, false if not.
    public func InRegion(Latitude: Double, Longitude: Double) -> Bool
    {
        if IsRectangular
        {
            if CrossesDateLine
            {
                if let (EastUL, EastLR) = EastSubRegion()
                {
                    if let (WestUL, WestLR) = WestSubRegion()
                    {
                        let InEasternSubRegion = PointInBounds(Latitude: Latitude, Longitude: Longitude, UpperLeft: EastUL, LowerRight: EastLR)
                        let InWesternSubRegion = PointInBounds(Latitude: Latitude, Longitude: Longitude, UpperLeft: WestUL, LowerRight: WestLR)
                        let IsInRegion = InEasternSubRegion || InWesternSubRegion
                        return IsInRegion
                    }
                }
                return false
            }
            return PointInBounds(Latitude: Latitude, Longitude: Longitude, UpperLeft: UpperLeft, LowerRight: LowerRight)
        }
        else
        {
            let Distance = Geometry.HaversineDistance(Latitude1: Latitude,
                                                      Longitude1: Longitude,
                                                      Latitude2: Center.Latitude,
                                                      Longitude2: Center.Longitude) / 1000.0
            return Distance <= Radius
        }
    }
    
    static func == (lhs: UserRegion, rhs: UserRegion) -> Bool
    {
        return lhs.ID == rhs.ID
    }
    
    func hash(into hasher: inout Hasher)
    {
        hasher.combine(ID)
    }
}


